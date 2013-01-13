module org.serviio.delivery.MediaFormatProfileResource;

import java.lang.Long;
import org.serviio.dlna.MediaFormatProfile;
import org.serviio.profile.DeliveryQuality;

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