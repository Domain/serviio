module org.serviio.upnp.service.contentdirectory.command.person.AbstractPersonsRetrievalCommand;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Person;
import org.serviio.library.local.service.PersonService;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.command.AbstractEntityContainerCommand;
import org.serviio.util.StringUtils;

public abstract class AbstractPersonsRetrievalCommand : AbstractEntityContainerCommand!(Person)
{
  public this(String contextIdentifier, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(contextIdentifier, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
  }

  protected Set!(ObjectClassType) getSupportedClasses()
  {
    return new HashSet!(ObjectClassType)(Arrays.asList(cast(ObjectClassType[])[ ObjectClassType.CONTAINER, ObjectClassType.PERSON, ObjectClassType.MUSIC_ARTIST, ObjectClassType.STORAGE_FOLDER ]));
  }

  protected Person retrieveSingleEntity(Long entityId)
  {
    Person person = PersonService.getPerson(entityId);
    return person;
  }

  protected String getContainerTitle(Person person)
  {
    return person.getName();
  }

  protected String getInitialFromId(String objectId)
  {
    return StringUtils.getCharacterForCode(Integer.parseInt(objectId));
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.person.AbstractPersonsRetrievalCommand
 * JD-Core Version:    0.6.2
 */