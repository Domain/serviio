module org.serviio.upnp.service.contentdirectory.command.video.ListLastViewedVideosCommand;

import java.util.List;
import org.serviio.config.Configuration;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Video;
import org.serviio.library.local.service.VideoService;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;

public class ListLastViewedVideosCommand : AbstractVideosRetrievalCommand
{
  public this(String contextIdentifier, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(contextIdentifier, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
  }

  protected List!(Video) retrieveEntityList()
  {
    List!(Video) videos = VideoService.getListOfLastViewedVideos(Configuration.getNumberOfFilesForDynamicCategories().intValue(), accessGroup, startIndex, count);
    return videos;
  }

  public int retrieveItemCount()
  {
    return VideoService.getNumberOfLastViewedVideos(Configuration.getNumberOfFilesForDynamicCategories().intValue(), accessGroup);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.video.ListLastViewedVideosCommand
 * JD-Core Version:    0.6.2
 */