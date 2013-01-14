module org.serviio.delivery.VideoMediaInfo;

import java.lang.String;
import java.lang.Integer;
import java.lang.Long;
import org.serviio.dlna.MediaFormatProfile;
import org.serviio.profile.DeliveryQuality;
import org.serviio.delivery.MediaFormatProfileResource;

public class VideoMediaInfo : MediaFormatProfileResource
{
  protected Integer width;
  protected Integer height;
  protected Integer bitrate;

  public this(Long resourceId, MediaFormatProfile profile, Long fileSize, Integer width, Integer height, Integer bitrate, bool transcoded, bool live, Integer duration, String mimeType, DeliveryQuality.QualityType quality)
  {
    super(resourceId, profile, fileSize, transcoded, live, duration, mimeType, quality);
    this.width = width;
    this.height = height;
    this.bitrate = bitrate;
  }

  public Integer getWidth()
  {
    return width;
  }

  public Integer getHeight() {
    return height;
  }

  public Integer getBitrate() {
    return bitrate;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.VideoMediaInfo
 * JD-Core Version:    0.6.2
 */