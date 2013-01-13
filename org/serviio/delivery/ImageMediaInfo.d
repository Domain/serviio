module org.serviio.delivery.ImageMediaInfo;

import java.lang.Integer;
import java.lang.Long;
import org.serviio.dlna.MediaFormatProfile;
import org.serviio.profile.DeliveryQuality;

public class ImageMediaInfo : MediaFormatProfileResource
{
  protected Integer width;
  protected Integer height;

  public this(Long resourceId, MediaFormatProfile profile, Long fileSize, Integer width, Integer height, bool transcoded, String mimeType, DeliveryQuality.QualityType quality)
  {
    super(resourceId, profile, fileSize, transcoded, false, null, mimeType, quality);
    this.width = width;
    this.height = height;
  }

  public Integer getWidth()
  {
    return width;
  }

  public Integer getHeight() {
    return height;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.ImageMediaInfo
 * JD-Core Version:    0.6.2
 */