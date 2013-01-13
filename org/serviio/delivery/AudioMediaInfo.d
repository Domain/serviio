module org.serviio.delivery.AudioMediaInfo;

import java.lang.Integer;
import java.lang.Long;
import org.serviio.dlna.MediaFormatProfile;
import org.serviio.profile.DeliveryQuality : QualityType;

public class AudioMediaInfo : MediaFormatProfileResource
{
  private Integer channels;
  private Integer sampleFrequency;
  private Integer bitrate;

  public this(Long resourceId, MediaFormatProfile profile, Long fileSize, bool transcoded, bool live, Integer duration, String mimeType, Integer channels, Integer sampleFrequency, Integer bitrate, QualityType quality)
  {
    super(resourceId, profile, fileSize, transcoded, live, duration, mimeType, quality);
    this.channels = channels;
    this.bitrate = bitrate;
    this.sampleFrequency = sampleFrequency;
  }

  public Integer getChannels()
  {
    return channels;
  }

  public Integer getSampleFrequency() {
    return sampleFrequency;
  }

  public Integer getBitrate() {
    return bitrate;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.AudioMediaInfo
 * JD-Core Version:    0.6.2
 */