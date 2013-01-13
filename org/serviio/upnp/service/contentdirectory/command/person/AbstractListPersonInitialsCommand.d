module org.serviio.upnp.service.contentdirectory.command.person.AbstractListPersonInitialsCommand;

import java.util.List;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Person : RoleType;
import org.serviio.library.local.service.PersonService;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.command.AbstractListInitialsCommand;
import org.serviio.upnp.service.contentdirectory.command.CommandExecutionException;

public abstract class AbstractListPersonInitialsCommand : AbstractListInitialsCommand
{
  protected RoleType roleType;

  public this(String contextIdentifier, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count, RoleType roleType)
  {
    super(contextIdentifier, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
    this.roleType = roleType;
  }

  protected List!(String) getListOfInitials(int startIndex, int count)
  {
    return PersonService.getListOfPersonInitials(roleType, startIndex, count);
  }

  public int retrieveItemCount()
  {
    return PersonService.getNumberOfPersonInitials(roleType);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.person.AbstractListPersonInitialsCommand
 * JD-Core Version:    0.6.2
 */