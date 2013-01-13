module org.serviio.upnp.service.contentdirectory.command.AbstractListInitialsCommand;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.serviio.library.entities.AccessGroup;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ClassProperties;
import org.serviio.upnp.service.contentdirectory.classes.Container;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObjectBuilder;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.definition.Definition;
import org.serviio.util.StringUtils;

public abstract class AbstractListInitialsCommand : AbstractCommand!(Container)
{
  public this(String contextIdentifier, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(contextIdentifier, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
  }

  protected abstract List!(String) getListOfInitials(int paramInt1, int paramInt2);

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

    List!(String) letters = getListOfInitials(startIndex, count);

    foreach (String letter ; letters) {
      String runtimeId = generateRuntimeObjectId(String.valueOf(StringUtils.getUnicodeCode(letter)));
      Map!(ClassProperties, Object) values = ObjectValuesBuilder.instantiateValuesForContainer(letter, runtimeId, getDisplayedContainerId(objectId), objectType, accessGroup);
      items.add(cast(Container)DirectoryObjectBuilder.createInstance(containerClassType, values, null, null));
    }
    return items;
  }

  protected Container retrieveSingleItem()
  {
    String title = StringUtils.getCharacterForCode(Integer.valueOf(getInternalObjectId()).intValue());
    Map!(ClassProperties, Object) values = ObjectValuesBuilder.instantiateValuesForContainer(title, objectId, Definition.instance().getParentNodeId(objectId), objectType, accessGroup);
    return cast(Container)DirectoryObjectBuilder.createInstance(containerClassType, values, null, null);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.AbstractListInitialsCommand
 * JD-Core Version:    0.6.2
 */