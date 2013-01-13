module org.serviio.upnp.service.contentdirectory.definition.ActionNode;

import org.serviio.library.entities.AccessGroup;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.BrowseItemsHolder;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObject;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.command.Command;
import org.serviio.upnp.service.contentdirectory.command.CommandExecutionException;
import org.serviio.util.ObjectValidator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ActionNode : ContainerNode
{
  private static final Logger log = LoggerFactory.getLogger!(ActionNode);
  private String commandClass;
  private String idPrefix;
  private bool recursive;

  public this(String commandClassName, String idPrefix, ObjectClassType containerClass, ObjectClassType itemClass, DefinitionNode parent, String cacheRegion, bool recursive)
  {
    super(containerClass, parent, cacheRegion);
    this.itemClass = itemClass;
    commandClass = commandClassName;
    this.idPrefix = idPrefix;
    this.recursive = recursive;
  }

  public DirectoryObject retrieveDirectoryObject(String objectId, ObjectType objectType, Profile rendererProfile, AccessGroup userProfile)
  {
    return executeRetrieveItemAction(objectId, objectType, rendererProfile, userProfile);
  }

  public void validate()
  {
    if ((containerClass is null) && (itemClass is null)) {
      throw new ContentDirectoryDefinitionException("Container class or Item class must be provided in definition.");
    }
    if (ObjectValidator.isEmpty(commandClass)) {
      throw new ContentDirectoryDefinitionException("Action Command not provided.");
    }
    if (ObjectValidator.isEmpty(idPrefix)) {
      throw new ContentDirectoryDefinitionException("Action idPrefix not provided.");
    }
    if ((recursive) && (!childNodes.isEmpty()))
      throw new ContentDirectoryDefinitionException("Recursive Actions cannot include any children nodes.");
  }

  public BrowseItemsHolder!(DirectoryObject) retrieveContainerItems(String containerId, ObjectType objectType, int startIndex, int count, Profile rendererProfile, AccessGroup userProfile)
  {
    if (count == 0) {
      count = 2147483647;
    }
    if (recursive)
    {
      BrowseItemsHolder!(DirectoryObject) holder = executeListAction(containerId, objectType, getCommandClass(), getContainerClass(), getItemClass(), rendererProfile, userProfile, getIdPrefix(), startIndex, count);

      return holder;
    }
    return super.retrieveContainerItems(containerId, objectType, startIndex, count, rendererProfile, userProfile);
  }

  public int retrieveContainerItemsCount(String containerId, ObjectType objectType, AccessGroup userProfile)
  {
    if (recursive)
    {
      int count = executeCountAction(containerId, objectType, getCommandClass(), userProfile, "");
      return count;
    }
    return super.retrieveContainerItemsCount(containerId, objectType, userProfile);
  }

  protected T executeRetrieveItemAction(T : DirectoryObject)(String containerId, ObjectType objectType, Profile rendererProfile, AccessGroup userProfile)
  {
    ObjectClassType containerClassType = containerClass;
    if (rendererProfile.getContentDirectoryDefinitionFilter() !is null) {
      containerClassType = rendererProfile.getContentDirectoryDefinitionFilter().filterContainerClassType(containerClassType, containerId);
    }
    Command!(T) command = instantiateCommand(containerId, objectType, commandClass, containerClassType, itemClass, rendererProfile, userProfile, idPrefix, 0, 1);
    try {
      return command.retrieveItem();
    } catch (CommandExecutionException e) {
      log.error(String.format("Cannot retrieve results of action command: %s", cast(Object[])[ e.getMessage() ]), e);
    }return null;
  }

  public String getCommandClass()
  {
    return commandClass;
  }

  public String getIdPrefix() {
    return idPrefix;
  }

  public bool isRecursive() {
    return recursive;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.definition.ActionNode
 * JD-Core Version:    0.6.2
 */