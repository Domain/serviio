module org.serviio.delivery.MediaFormatProfileResource;

import java.lang.String;
import java.lang.Long;
import java.lang.Integer;
import org.serviio.dlna.MediaFormatProfile;
import org.serviio.profile.DeliveryQuality;
import org.serviio.delivery.ResourceInfo;

public abstract class MediaFormatProfileResource : ResourceInfo
{
  private MediaFormatProfile formatProfile;
  private DeliveryQuality.QualityType quality;

  public this(Long resourceId, MediaFormatProfile profile, Long fileSize, bool transcoded, bool live, Integer duration, String mimeType, DeliveryQuality.QualityType quality)
  {
    super(resourceId);
    this.live = live;
    formatProfile = profile;
    this.fileSize = fileSize;
    this.transcoded = transcoded;
    this.duration = duration;
    this.mimeType = mimeType;
    this.quality = quality;
  }

  public MediaFormatProfile getFormatProfile()
  {
    return formatProfile;
  }

  public DeliveryQuality.QualityType getQuality() {
    return quality;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.MediaFormatProfileResource
 * JD-Core Version:    0.6.2
 */