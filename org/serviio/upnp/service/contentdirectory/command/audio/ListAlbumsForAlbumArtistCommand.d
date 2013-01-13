module org.serviio.upnp.service.contentdirectory.command.audio.ListAlbumsForAlbumArtistCommand;

import java.util.List;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.MusicAlbum;
import org.serviio.library.local.service.AudioService;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;

public class ListAlbumsForAlbumArtistCommand : AbstractAlbumsRetrievalCommand
{
  public this(String contextIdentifier, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(contextIdentifier, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
  }

  protected List!(MusicAlbum) retrieveEntityList()
  {
    List!(MusicAlbum) albums = AudioService.getListOfAlbumsForAlbumArtist(new Long(getInternalObjectId()), startIndex, count);
    return albums;
  }

  public int retrieveItemCount()
  {
    return AudioService.getNumberOfAlbumsForAlbumArtist(new Long(getInternalObjectId()));
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.audio.ListAlbumsForAlbumArtistCommand
 * JD-Core Version:    0.6.2
 */