module org.serviio.upnp.service.contentdirectory.command.AbstractEntityItemCommand;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.serviio.db.entities.PersistedEntity;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.MediaItem;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectNotFoundException;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ClassProperties;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObjectBuilder;
import org.serviio.upnp.service.contentdirectory.classes.Item;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.classes.Resource;
import org.serviio.upnp.service.contentdirectory.definition.Definition;

public abstract class AbstractEntityItemCommand(E : PersistedEntity) : AbstractCommand!(Item)
{
  public this(String objectId, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(objectId, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
  }

  protected List!(Item) retrieveList()
  {
    List!(Item) items = new ArrayList!(Item)();

    List!(E) entities = retrieveEntityList();

    Long markedItemId = findMarkedItemId(false);

    foreach (E entity ; entities) {
      bool itemMarked = (markedItemId !is null) && (markedItemId.equals(entity.getId()));
      Map!(ClassProperties, Object) values = generateValuesForEntity(entity, generateRuntimeObjectId(entity.getId()), getDisplayedContainerId(objectId), getItemTitle(entity, itemMarked));
      List!(Resource) res = generateResourcesForEntity(entity);
      items.add(cast(Item)DirectoryObjectBuilder.createInstance(itemClassType, values, res, entity.getId()));
    }
    return items;
  }

  protected Item retrieveSingleItem()
  {
    E entity = retrieveSingleEntity(new Long(getInternalObjectId()));

    if (entity !is null)
    {
      Long markedItemId = findMarkedItemId(true);
      bool itemMarked = (markedItemId !is null) && (markedItemId.equals(entity.getId()));
      Map!(ClassProperties, Object) values = generateValuesForEntity(entity, objectId, Definition.instance().getParentNodeId(objectId), getItemTitle(entity, itemMarked));
      List!(Resource) res = generateResourcesForEntity(entity);
      return cast(Item)DirectoryObjectBuilder.createInstance(itemClassType, values, res, entity.getId());
    }
    throw new ObjectNotFoundException(String.format("Object with id %s not found in CDS", cast(Object[])[ objectId ]));
  }

  protected Set!(ObjectType) getSupportedObjectTypes()
  {
    return ObjectType.getItemTypes();
  }

  protected Long findMarkedItemId(bool forSingleItem)
  {
    return null;
  }

  protected abstract List!(E) retrieveEntityList();

  protected abstract E retrieveSingleEntity(Long paramLong);

  protected abstract String getItemTitle(E paramE, bool paramBoolean);

  protected Map!(ClassProperties, Object) generateValuesForEntity(E entity, String objectId, String parentId, String title)
  {
    return ObjectValuesBuilder.buildObjectValues(entity, objectId, parentId, objectType, title, rendererProfile, accessGroup);
  }

  protected List!(Resource) generateResourcesForEntity(E entity)
  {
    return ResourceValuesBuilder.buildResources(cast(MediaItem)entity, rendererProfile);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.AbstractEntityItemCommand
 * JD-Core Version:    0.6.2
 */