module org.serviio.upnp.service.contentdirectory.command.video.AbstractVideosRetrievalCommand;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Series;
import org.serviio.library.entities.Video;
import org.serviio.library.local.service.VideoService;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.command.AbstractEntityItemCommand;

public abstract class AbstractVideosRetrievalCommand : AbstractEntityItemCommand!(Video)
{
  public this(String contextIdentifier, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(contextIdentifier, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
  }

  protected final Set!(ObjectClassType) getSupportedClasses()
  {
    return new HashSet!(ObjectClassType)(Arrays.asList(cast(ObjectClassType[])[ ObjectClassType.VIDEO_ITEM, ObjectClassType.MOVIE ]));
  }

  protected Video retrieveSingleEntity(Long entityId)
  {
    Video video = VideoService.getVideo(entityId);
    return video;
  }

  protected String getItemTitle(Video video, bool markedItem)
  {
    if (video.getSeriesId() !is null) {
      Series series = VideoService.getSeries(video.getSeriesId());
      return String.format("%s (%s/%02d): %s", cast(Object[])[ series.getTitle(), video.getSeasonNumber(), video.getEpisodeNumber(), video.getTitle() ]);
    }

    return video.getTitle();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.video.AbstractVideosRetrievalCommand
 * JD-Core Version:    0.6.2
 */