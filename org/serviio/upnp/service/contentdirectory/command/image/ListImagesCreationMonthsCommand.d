module org.serviio.upnp.service.contentdirectory.command.image.ListImagesCreationMonthsCommand;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.local.service.ImageService;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ClassProperties;
import org.serviio.upnp.service.contentdirectory.classes.Container;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObjectBuilder;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.command.AbstractCommand;
import org.serviio.upnp.service.contentdirectory.command.CommandExecutionException;
import org.serviio.upnp.service.contentdirectory.command.ObjectValuesBuilder;
import org.serviio.upnp.service.contentdirectory.definition.Definition;

public class ListImagesCreationMonthsCommand : AbstractCommand!(Container)
{
  public this(String contextIdentifier, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(contextIdentifier, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
  }

  protected Set!(ObjectClassType) getSupportedClasses()
  {
    return new HashSet!(ObjectClassType)(Arrays.asList(cast(ObjectClassType[])[ ObjectClassType.CONTAINER, ObjectClassType.STORAGE_FOLDER ]));
  }

  protected Set!(ObjectType) getSupportedObjectTypes()
  {
    return ObjectType.getContainerTypes();
  }

  protected List!(Container) retrieveList()
  {
    List!(Container) items = new ArrayList!(Container)();
    Integer year = Integer.valueOf(Integer.parseInt(getInternalObjectId()));

    List!(Integer) months = ImageService.getListOfImagesCreationMonths(year, accessGroup, startIndex, count);

    foreach (Integer month ; months) {
      String runtimeId = generateRuntimeObjectId(month);
      Map!(ClassProperties, Object) values = ObjectValuesBuilder.instantiateValuesForContainer(month.toString(), runtimeId, getDisplayedContainerId(objectId), objectType, accessGroup);
      items.add(cast(Container)DirectoryObjectBuilder.createInstance(containerClassType, values, null, null));
    }
    return items;
  }

  protected Container retrieveSingleItem()
  {
    Map!(ClassProperties, Object) values = ObjectValuesBuilder.instantiateValuesForContainer(getInternalObjectId(), objectId, Definition.instance().getParentNodeId(objectId), objectType, accessGroup);
    return cast(Container)DirectoryObjectBuilder.createInstance(containerClassType, values, null, null);
  }

  public int retrieveItemCount()
  {
    Integer year = Integer.valueOf(Integer.parseInt(getInternalObjectId()));
    return ImageService.getNumberOfImagesCreationMonths(year, accessGroup);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.image.ListImagesCreationMonthsCommand
 * JD-Core Version:    0.6.2
 */