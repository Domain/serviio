module org.serviio.upnp.service.contentdirectory.command.AbstractListPlaylistsCommand;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Playlist;
import org.serviio.library.local.service.PlaylistService;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;

public abstract class AbstractListPlaylistsCommand : AbstractEntityContainerCommand!(Playlist)
{
  protected MediaFileType fileType;

  public this(String objectId, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count, MediaFileType fileType)
  {
    super(objectId, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
    this.fileType = fileType;
  }

  protected Set!(ObjectClassType) getSupportedClasses()
  {
    return new HashSet!(ObjectClassType)(Arrays.asList(cast(ObjectClassType[])[ ObjectClassType.CONTAINER, ObjectClassType.STORAGE_FOLDER, ObjectClassType.PLAYLIST_CONTAINER ]));
  }

  protected List!(Playlist) retrieveEntityList()
  {
    List!(Playlist) playlists = PlaylistService.getListOfPlaylistsWithMedia(fileType, accessGroup, startIndex, count);
    return playlists;
  }

  protected Playlist retrieveSingleEntity(Long entityId)
  {
    Playlist playlist = PlaylistService.getPlaylist(entityId);
    return playlist;
  }

  public int retrieveItemCount()
  {
    return PlaylistService.getNumberOfPlaylistsWithMedia(fileType, accessGroup);
  }

  protected String getContainerTitle(Playlist playlist)
  {
    return playlist.getTitle();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.AbstractListPlaylistsCommand
 * JD-Core Version:    0.6.2
 */