module org.serviio.upnp.service.contentdirectory.command.AbstractEntityContainerCommand;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.serviio.db.entities.PersistedEntity;
import org.serviio.library.entities.AccessGroup;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectNotFoundException;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ClassProperties;
import org.serviio.upnp.service.contentdirectory.classes.Container;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObjectBuilder;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.definition.Definition;

public abstract class AbstractEntityContainerCommand(E : PersistedEntity) : AbstractCommand!(Container)
{
  public this(String objectId, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(objectId, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
  }

  protected List!(Container) retrieveList()
  {
    List!(Container) items = new ArrayList!(Container)();

    List!(E) entities = retrieveEntityList();

    foreach (E entity ; entities) {
      String runtimeId = generateRuntimeObjectId(entity.getId());
      Map!(ClassProperties, Object) values = generateValuesForEntity(entity, runtimeId, getDisplayedContainerId(objectId), getContainerTitle(entity));
      items.add(cast(Container)DirectoryObjectBuilder.createInstance(containerClassType, values, null, entity.getId()));
    }
    return items;
  }

  public int retrieveItemCount()
  {
    return 0;
  }

  protected Set!(ObjectType) getSupportedObjectTypes()
  {
    return ObjectType.getContainerTypes();
  }

  protected Container retrieveSingleItem()
  {
    E entity = retrieveSingleEntity(new Long(getInternalObjectId()));

    if (entity !is null) {
      Map!(ClassProperties, Object) values = generateValuesForEntity(entity, objectId, Definition.instance().getParentNodeId(objectId), getContainerTitle(entity));
      return cast(Container)DirectoryObjectBuilder.createInstance(containerClassType, values, null, entity.getId());
    }
    throw new ObjectNotFoundException(String.format("Object with id %s not found in CDS", cast(Object[])[ objectId ]));
  }

  protected abstract List!(E) retrieveEntityList();

  protected abstract E retrieveSingleEntity(Long paramLong);

  protected abstract String getContainerTitle(E paramE);

  protected Map!(ClassProperties, Object) generateValuesForEntity(E entity, String objectId, String parentId, String title)
  {
    return ObjectValuesBuilder.buildObjectValues(entity, objectId, parentId, objectType, title, rendererProfile, accessGroup);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.AbstractEntityContainerCommand
 * JD-Core Version:    0.6.2
 */