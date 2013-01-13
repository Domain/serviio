module org.serviio.upnp.service.contentdirectory.command.audio.ListAllAlbumsCommand;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.MusicAlbum;
import org.serviio.library.local.service.AudioService;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.command.AbstractEntityContainerCommand;

public class ListAllAlbumsCommand : AbstractEntityContainerCommand!(MusicAlbum)
{
  public this(String contextIdentifier, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(contextIdentifier, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
  }

  protected Set!(ObjectClassType) getSupportedClasses()
  {
    return new HashSet!(ObjectClassType)(Arrays.asList(cast(ObjectClassType[])[ ObjectClassType.CONTAINER, ObjectClassType.MUSIC_ALBUM ]));
  }

  protected List!(MusicAlbum) retrieveEntityList()
  {
    List!(MusicAlbum) albums = AudioService.getListOfAllAlbums(startIndex, count);
    return albums;
  }

  protected MusicAlbum retrieveSingleEntity(Long entityId)
  {
    MusicAlbum album = AudioService.getMusicAlbum(entityId);
    return album;
  }

  public int retrieveItemCount()
  {
    return AudioService.getNumberOfAllAlbums();
  }

  protected String getContainerTitle(MusicAlbum album)
  {
    return album.getTitle();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.audio.ListAllAlbumsCommand
 * JD-Core Version:    0.6.2
 */