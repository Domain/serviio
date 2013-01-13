module org.serviio.upnp.service.contentdirectory.command.video.ListVideosForInitialCommand;

import java.util.List;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Video;
import org.serviio.library.local.service.VideoService;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.util.StringUtils;

public class ListVideosForInitialCommand : AbstractVideosRetrievalCommand
{
  public this(String contextIdentifier, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(contextIdentifier, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
  }

  protected List!(Video) retrieveEntityList()
  {
    List!(Video) videos = VideoService.getListOfVideosForInitial(getInitialFromId(getInternalObjectId()), accessGroup, startIndex, count);
    return videos;
  }

  public int retrieveItemCount()
  {
    return VideoService.getNumberOfVideosForInitial(getInitialFromId(getInternalObjectId()), accessGroup);
  }

  private String getInitialFromId(String objectId)
  {
    return StringUtils.getCharacterForCode(Integer.parseInt(objectId));
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.video.ListVideosForInitialCommand
 * JD-Core Version:    0.6.2
 */