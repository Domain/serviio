module org.serviio.upnp.service.contentdirectory.command.person.AbstractListPersonsForInitialCommand;

import java.util.List;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Person;
import org.serviio.library.entities.Person : RoleType;
import org.serviio.library.local.service.PersonService;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;

public abstract class AbstractListPersonsForInitialCommand : AbstractPersonsRetrievalCommand
{
  private RoleType roleType;

  public this(String contextIdentifier, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count, RoleType roleType)
  {
    super(contextIdentifier, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
    this.roleType = roleType;
  }

  protected List!(Person) retrieveEntityList()
  {
    List!(Person) persons = PersonService.getListOfPersonsForInitial(getInitialFromId(getInternalObjectId()), roleType, startIndex, count);

    return persons;
  }

  public int retrieveItemCount()
  {
    return PersonService.getNumberOfPersonsForInitial(getInitialFromId(getInternalObjectId()), roleType);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.person.AbstractListPersonsForInitialCommand
 * JD-Core Version:    0.6.2
 */