module org.serviio.library.local.service.PersonService;

import java.util.List;
import org.serviio.db.dao.DAOFactory;
import org.serviio.library.entities.Person;
import org.serviio.library.entities.Person : RoleType;
import org.serviio.library.service.Service;

public class PersonService
  : Service
{
  public static Person getPerson(Long personId)
  {
    return DAOFactory.getPersonDAO().findPersonById(personId);
  }

  public static List!(Person) getListOfPersons(RoleType role, int startingIndex, int requestedCount)
  {
    return DAOFactory.getPersonDAO().retrievePersonsWithRole(role, startingIndex, requestedCount);
  }

  public static int getNumberOfPersons(RoleType role)
  {
    return DAOFactory.getPersonDAO().getPersonsWithRoleCount(role);
  }

  public static List!(Person) getListOfPersonsForMediaItem(Long mediaItemId, RoleType roleType)
  {
    return DAOFactory.getPersonDAO().retrievePersonsWithRoleForMediaItem(roleType, mediaItemId);
  }

  public static List!(Person) getListOfPersonsForMusicAlbum(Long albumId, RoleType roleType)
  {
    return DAOFactory.getPersonDAO().retrievePersonsWithRoleForMusicAlbum(roleType, albumId);
  }

  public static List!(String) getListOfPersonInitials(RoleType role, int startingIndex, int requestedCount)
  {
    return DAOFactory.getPersonDAO().retrievePersonInitials(role, startingIndex, requestedCount);
  }

  public static int getNumberOfPersonInitials(RoleType role)
  {
    return DAOFactory.getPersonDAO().retrievePersonInitialsCount(role);
  }

  public static List!(Person) getListOfPersonsForInitial(String initial, RoleType role, int startingIndex, int requestedCount)
  {
    return DAOFactory.getPersonDAO().retrievePersonsForInitial(initial, role, startingIndex, requestedCount);
  }

  public static int getNumberOfPersonsForInitial(String initial, RoleType role)
  {
    return DAOFactory.getPersonDAO().retrievePersonsForInitialCount(initial, role);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.service.PersonService
 * JD-Core Version:    0.6.2
 */