module org.serviio.upnp.service.contentdirectory.command.audio.AbstractSongsForRoleAndAlbumRetrievalCommand;

import java.util.List;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.MusicTrack;
import org.serviio.library.entities.Person : RoleType;
import org.serviio.library.local.service.AudioService;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.definition.Definition;

public abstract class AbstractSongsForRoleAndAlbumRetrievalCommand : AbstractSongsRetrievalCommand
{
  private RoleType roleType;

  public this(String contextIdentifier, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count, RoleType roleType)
  {
    super(contextIdentifier, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
    this.roleType = roleType;
  }

  protected List!(MusicTrack) retrieveEntityList()
  {
    Long artistId = Long.valueOf(Long.parseLong(getInternalObjectId(Definition.instance().getParentNodeId(objectId))));
    Long albumId = Long.valueOf(Long.parseLong(getInternalObjectId()));
    List!(MusicTrack) songs = AudioService.getListOfSongsForTrackRoleAndAlbum(artistId, roleType, albumId, accessGroup, startIndex, count);
    return songs;
  }

  public int retrieveItemCount()
  {
    Long artistId = Long.valueOf(Long.parseLong(getInternalObjectId(Definition.instance().getParentNodeId(objectId))));
    Long albumId = Long.valueOf(Long.parseLong(getInternalObjectId()));
    return AudioService.getNumberOfSongsForTrackRoleAndAlbum(artistId, roleType, albumId, accessGroup);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.audio.AbstractSongsForRoleAndAlbumRetrievalCommand
 * JD-Core Version:    0.6.2
 */