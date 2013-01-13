module org.serviio.upnp.service.contentdirectory.command.AbstractCommand;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import org.serviio.library.entities.AccessGroup;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.BrowseItemsHolder;
import org.serviio.upnp.service.contentdirectory.ObjectNotFoundException;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObject;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.definition.Definition;

public abstract class AbstractCommand(T : DirectoryObject)
  : Command!(T)
{
  protected String objectId;
  protected ObjectClassType containerClassType;
  protected ObjectClassType itemClassType;
  protected int startIndex;
  protected int count;
  protected String idPrefix;
  protected Profile rendererProfile;
  protected ObjectType objectType = ObjectType.ALL;

  protected AccessGroup accessGroup = AccessGroup.ANY;

  public this(String objectId, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    this.objectId = objectId;
    this.containerClassType = containerClassType;
    this.itemClassType = itemClassType;
    this.startIndex = startIndex;
    this.count = count;
    this.idPrefix = idPrefix;
    this.rendererProfile = rendererProfile;
    this.objectType = objectType;
    this.accessGroup = accessGroup;
  }

  public BrowseItemsHolder!(T) retrieveItemList()
  {
    try
    {
      validateSupportedClassTypes();
      List!(T) items = getSupportedObjectTypes().contains(objectType) ? retrieveList() : new ArrayList!(T)();
      BrowseItemsHolder!(T) holder = new BrowseItemsHolder!(T)();
      holder.setItems(items);
      holder.setTotalMatched(getSupportedObjectTypes().contains(objectType) ? retrieveItemCount() : 0);
      return holder;
    } catch (Exception e) {
      throw new CommandExecutionException(String.format("Cannot execute library command for list: %s", cast(Object[])[ e.getMessage() ]), e);
    }
  }

  public T retrieveItem()
  {
    try
    {
      validateSupportedClassTypes();
      return retrieveSingleItem();
    } catch (Exception e) {
      if (( cast(ObjectNotFoundException)e !is null )) {
        throw (cast(ObjectNotFoundException)e);
      }
      throw new CommandExecutionException(String.format("Cannot execute library command for single item: %s", cast(Object[])[ e.getMessage() ]), e);
    }
  }

  protected abstract List!(T) retrieveList();

  protected abstract T retrieveSingleItem();

  protected abstract Set!(ObjectClassType) getSupportedClasses();

  protected abstract Set!(ObjectType) getSupportedObjectTypes();

  protected String generateRuntimeObjectId(Number entityId)
  {
    return generateRuntimeObjectId(entityId.toString());
  }

  protected String generateRuntimeObjectId(String objectIdentifier)
  {
    return objectId + "^" + idPrefix + "_" + objectIdentifier;
  }

  protected String getInternalObjectId()
  {
    if (objectId.indexOf("^") > 1) {
      return objectId.substring(objectId.lastIndexOf("_") + 1);
    }
    return "0";
  }

  protected String getInternalObjectId(String objectId)
  {
    if (objectId.indexOf("^") > 1) {
      return objectId.substring(objectId.lastIndexOf("_") + 1);
    }
    return "0";
  }

  protected String getDisplayedContainerId(String objectId)
  {
    if (Definition.instance().isOnlyShowContentsOfContainer(objectId)) {
      return Definition.instance().getParentNodeId(objectId);
    }
    return objectId;
  }

  private void validateSupportedClassTypes()
  {
    if ((containerClassType !is null) && (!getSupportedClasses().contains(containerClassType))) {
      throw new CommandExecutionException(String.format("Class %s is not supported by the Command %s", cast(Object[])[ containerClassType.toString(), getClass().getName() ]));
    }

    if ((itemClassType !is null) && (!getSupportedClasses().contains(itemClassType)))
      throw new CommandExecutionException(String.format("Class %s is not supported by the Command %s", cast(Object[])[ itemClassType.toString(), getClass().getName() ]));
  }

  public String getContextIdentifier()
  {
    return objectId;
  }

  public ObjectClassType getContainerClassType() {
    return containerClassType;
  }

  public ObjectClassType getItemClassType() {
    return itemClassType;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.AbstractCommand
 * JD-Core Version:    0.6.2
 */