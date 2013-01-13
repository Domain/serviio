module org.serviio.upnp.service.contentdirectory.command.person.ListAlbumArtistInitialsCommand;

import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Person : RoleType;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;

public class ListAlbumArtistInitialsCommand : AbstractListPersonInitialsCommand
{
  public this(String contextIdentifier, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(contextIdentifier, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count, RoleType.ALBUM_ARTIST);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.person.ListAlbumArtistInitialsCommand
 * JD-Core Version:    0.6.2
 */