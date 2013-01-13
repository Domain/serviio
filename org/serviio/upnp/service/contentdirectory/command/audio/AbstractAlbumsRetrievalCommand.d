module org.serviio.upnp.service.contentdirectory.command.audio.AbstractAlbumsRetrievalCommand;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.MusicAlbum;
import org.serviio.library.local.service.AudioService;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.command.AbstractEntityContainerCommand;

public abstract class AbstractAlbumsRetrievalCommand : AbstractEntityContainerCommand!(MusicAlbum)
{
  public this(String contextIdentifier, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(contextIdentifier, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
  }

  protected Set!(ObjectClassType) getSupportedClasses()
  {
    return new HashSet!(ObjectClassType)(Arrays.asList(cast(ObjectClassType[])[ ObjectClassType.CONTAINER, ObjectClassType.MUSIC_ALBUM ]));
  }

  protected MusicAlbum retrieveSingleEntity(Long entityId)
  {
    MusicAlbum album = AudioService.getMusicAlbum(entityId);
    return album;
  }

  protected String getContainerTitle(MusicAlbum album)
  {
    return album.getTitle();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.audio.AbstractAlbumsRetrievalCommand
 * JD-Core Version:    0.6.2
 */