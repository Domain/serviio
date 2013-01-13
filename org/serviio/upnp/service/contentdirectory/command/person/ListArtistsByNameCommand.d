module org.serviio.upnp.service.contentdirectory.command.person.ListArtistsByNameCommand;

import java.util.List;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Person;
import org.serviio.library.entities.Person : RoleType;
import org.serviio.library.local.service.PersonService;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;

public class ListArtistsByNameCommand : AbstractPersonsRetrievalCommand
{
  public this(String objectId, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(objectId, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
  }

  protected List!(Person) retrieveEntityList()
  {
    List!(Person) artists = PersonService.getListOfPersons(RoleType.ARTIST, startIndex, count);
    return artists;
  }

  public int retrieveItemCount()
  {
    return PersonService.getNumberOfPersons(RoleType.ARTIST);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.person.ListArtistsByNameCommand
 * JD-Core Version:    0.6.2
 */