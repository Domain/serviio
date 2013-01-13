module org.serviio.upnp.service.contentdirectory.command.audio.AbstractSongsRetrievalCommand;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.MusicTrack;
import org.serviio.library.local.service.AudioService;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.command.AbstractEntityItemCommand;

public abstract class AbstractSongsRetrievalCommand : AbstractEntityItemCommand!(MusicTrack)
{
  public this(String contextIdentifier, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(contextIdentifier, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
  }

  protected final Set!(ObjectClassType) getSupportedClasses()
  {
    return new HashSet!(ObjectClassType)(Arrays.asList(cast(ObjectClassType[])[ ObjectClassType.AUDIO_ITEM, ObjectClassType.MUSIC_TRACK ]));
  }

  protected MusicTrack retrieveSingleEntity(Long entityId)
  {
    MusicTrack song = AudioService.getSong(entityId);
    return song;
  }

  protected String getItemTitle(MusicTrack track, bool markItem)
  {
    return track.getTitle();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.audio.AbstractSongsRetrievalCommand
 * JD-Core Version:    0.6.2
 */