module org.serviio.delivery.resource.transcode.AudioTranscodingMatch;

import org.serviio.dlna.AudioContainer;
import org.serviio.profile.OnlineContentType;

public class AudioTranscodingMatch
{
  private AudioContainer container;
  private OnlineContentType onlineContentType;

  public this(AudioContainer container, OnlineContentType onlineContentType)
  {
    this.container = container;
    this.onlineContentType = onlineContentType;
  }

  public bool matches(AudioContainer container, OnlineContentType onlineContentType)
  {
    if (((container == this.container) || (this.container == AudioContainer.ANY)) && ((this.onlineContentType == OnlineContentType.ANY) || (this.onlineContentType == onlineContentType))) {
      return true;
    }
    return false;
  }

  public AudioContainer getContainer()
  {
    return container;
  }

  public OnlineContentType getOnlineContentType() {
    return onlineContentType;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.resource.transcode.AudioTranscodingMatch
 * JD-Core Version:    0.6.2
 */