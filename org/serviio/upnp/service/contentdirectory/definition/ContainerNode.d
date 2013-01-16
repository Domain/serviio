module org.serviio.upnp.service.contentdirectory.definition.ContainerNode;

import java.lang.String;
import java.lang.Integer;
import java.lang.reflect.Constructor;
import java.util.ArrayList;
import java.util.List;
import org.serviio.library.entities.AccessGroup;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.BrowseItemsHolder;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObject;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.command.Command;
import org.serviio.upnp.service.contentdirectory.command.CommandExecutionException;
import org.serviio.upnp.service.contentdirectory.definition.DefinitionNode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class ContainerNode : DefinitionNode
{
  private static immutable Logger log = LoggerFactory.getLogger!(ContainerNode)();

  protected List!(DefinitionNode) childNodes = new ArrayList!(DefinitionNode)();

  public this(ObjectClassType objectClass, DefinitionNode parent, String cacheRegion)
  {
    super(objectClass, parent, cacheRegion);
  }

  public BrowseItemsHolder!(DirectoryObject) retrieveContainerItems(String containerId, ObjectType objectType, int startIndex, int count, Profile rendererProfile, AccessGroup userProfile)
  {
    BrowseItemsHolder!(DirectoryObject) resultHolder = new BrowseItemsHolder!(DirectoryObject)();
    int[] totalFound = new int[1];
    int[] returned = new int[1];
    if (count == 0) {
      count = 2147483647;
    }
    List!(DirectoryObject) items = findContainerItems(containerId, objectType, Integer.valueOf(startIndex), Integer.valueOf(count), returned, totalFound, rendererProfile, userProfile);
    resultHolder.setItems(items.size() < count ? items : items.subList(0, count));
    resultHolder.setTotalMatched(totalFound[0]);
    return resultHolder;
  }

  public int retrieveContainerItemsCount(String containerId, ObjectType objectType, AccessGroup userProfile)
  {
    int totalFound = 0;
    Definition def = Definition.instance();
    foreach (DefinitionNode childNode ; childNodes) {
      if (( cast(StaticDefinitionNode)childNode !is null )) {
        String childNodeId = (cast(StaticDefinitionNode)childNode).getId();
        if ((!def.isDisabledContainer(childNodeId)) && (objectType.supportsContainers())) {
          if (def.isOnlyShowContentsOfContainer(childNodeId)) {
            if (( cast(StaticContainerNode)childNode !is null )) {
              StaticContainerNode disabledContainerNode = cast(StaticContainerNode)childNode;

              totalFound += disabledContainerNode.retrieveContainerItemsCount(disabledContainerNode.getId(), objectType, userProfile);
            }
          }
          else totalFound++;
        }
      }
      else
      {
        int count = executeCountAction(containerId, objectType, (cast(ActionNode)childNode).getCommandClass(), userProfile, (cast(ActionNode)childNode).getIdPrefix());
        totalFound += count;
      }
    }
    return totalFound;
  }

  override public void validate()
  {
    super.validate();
    if (containerClass is null)
      throw new ContentDirectoryDefinitionException("Container class not provided in definition.");
  }

  protected List!(DirectoryObject) findContainerItems(String containerId, ObjectType objectType, Integer startIndex, Integer requestedCount, int[] returned, int[] totalFound, Profile rendererProfile, AccessGroup userProfile)
  {
    List!(DirectoryObject) items = new ArrayList!(DirectoryObject)();
    Definition def = Definition.instance();
    foreach (DefinitionNode node ; childNodes) {
      if (( cast(StaticContainerNode)node !is null )) {
        StaticContainerNode staticContainer = cast(StaticContainerNode)node;
        if ((staticContainer.isBrowsable()) && 
          (!def.isDisabledContainer(staticContainer.getId())) && (objectType.supportsContainers())) {
          if (returned[0] < requestedCount.intValue()) {
            if (def.isEnabledContainer(staticContainer.getId()))
            {
              if (startIndex.intValue() <= totalFound[0])
              {
                items.add(staticContainer.retrieveDirectoryObject(staticContainer.getId(), objectType, rendererProfile, userProfile));
                returned[0] += 1;
              }
              totalFound[0] += 1;
            }
            else {
              items.addAll(staticContainer.findContainerItems(staticContainer.getId(), objectType, startIndex, requestedCount, returned, totalFound, rendererProfile, userProfile));
            }

          }
          else if (def.isEnabledContainer(staticContainer.getId())) {
            totalFound[0] += 1;
          }
          else {
            totalFound[0] += staticContainer.retrieveContainerItemsCount(staticContainer.getId(), objectType, userProfile);
          }
        }

      }
      else
      {
        int from = startIndex.intValue() <= returned[0] ? 0 : startIndex.intValue() - returned[0];

        BrowseItemsHolder!(DirectoryObject) holder = executeListAction(containerId, objectType, (cast(ActionNode)node).getCommandClass(), node.getContainerClass(), node.getItemClass(), rendererProfile, userProfile, (cast(ActionNode)node).getIdPrefix(), from, requestedCount.intValue() - returned[0]);

        if (holder !is null) {
          totalFound[0] += holder.getTotalMatched();
          returned[0] += holder.getReturnedSize();
          items.addAll(holder.getItems());
        }
      }
    }
    return items;
  }

  
protected Command!(T) instantiateCommand(T : DirectoryObject)(String containerId, ObjectType objectType, String commandClass, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup userProfile, String idPrefix, int startIndex, int count)
  {
    try
    {
      Class!(Object) clazz = Class.forName(commandClass);
      if (Command.class_.isAssignableFrom(clazz)) {
        Constructor!(Object) c = clazz.getConstructor(cast(Class[])[ String.class_, ObjectType.class_, ObjectClassType.class_, ObjectClassType.class_, Profile.class_, AccessGroup.class_, String.class_, Integer.TYPE, Integer.TYPE ]);
        return cast(Command!(T))c.newInstance(cast(Object[])[ containerId, objectType, containerClassType, itemClassType, rendererProfile, userProfile, idPrefix, Integer.valueOf(startIndex), Integer.valueOf(count) ]);
      }

      log.error(String.format("Cannot instantiate Command %s because it doesn't implement Command interface", cast(Object[])[ commandClass ]));
    }
    catch (Exception e)
    {
      log.error(String.format("Cannot instantiate Command %s: %s", cast(Object[])[ commandClass, e.getMessage() ]));
    }
    return null;
  }

  protected int executeCountAction(T : DirectoryObject)(String containerId, ObjectType objectType, String commandClass, AccessGroup userProfile, String idPrefix)
  {
    Command!(T) command = instantiateCommand(containerId, objectType, commandClass, null, null, null, userProfile, idPrefix, 0, 0);
    try {
      return command.retrieveItemCount();
    } catch (CommandExecutionException e) {
      log.error(String.format("Cannot retrieve results of action count command: %s", cast(Object[])[ e.getMessage() ]), e);
    }return 0;
  }

  protected BrowseItemsHolder!(T) executeListAction(T : DirectoryObject)(String containerId, ObjectType objectType, String commandClass, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup userProfile, String idPrefix, int startIndex, int count)
  {
    ObjectClassType filteredContainerClassType = containerClassType;
    if (rendererProfile.getContentDirectoryDefinitionFilter() !is null) {
      filteredContainerClassType = rendererProfile.getContentDirectoryDefinitionFilter().filterContainerClassType(containerClassType, containerId);
    }
    Command!(T) command = instantiateCommand(containerId, objectType, commandClass, filteredContainerClassType, itemClassType, rendererProfile, userProfile, idPrefix, startIndex, count);
    try {
      return command.retrieveItemList();
    } catch (CommandExecutionException e) {
      log.error(String.format("Cannot retrieve results of action command: %s", cast(Object[])[ e.getMessage() ]), e);
      throw new RuntimeException(e);
    }
  }

  public List!(DefinitionNode) getChildNodes()
  {
    return childNodes;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.definition.ContainerNode
 * JD-Core Version:    0.6.2
 */