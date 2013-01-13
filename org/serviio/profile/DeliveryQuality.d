module org.serviio.profile.DeliveryQuality;

import org.serviio.delivery.resource.transcode.TranscodingConfiguration;

public class DeliveryQuality
{
  private QualityType type;
  private TranscodingConfiguration transcodingConfiguration;
  private TranscodingConfiguration onlineTranscodingConfiguration;

  public this(QualityType type, TranscodingConfiguration transcodingConfiguration, TranscodingConfiguration onlineTranscodingConfiguration)
  {
    this.type = type;
    this.transcodingConfiguration = transcodingConfiguration;
    this.onlineTranscodingConfiguration = onlineTranscodingConfiguration;
  }

  public QualityType getType()
  {
    return type;
  }

  public TranscodingConfiguration getTranscodingConfiguration() {
    return transcodingConfiguration;
  }

  public TranscodingConfiguration getOnlineTranscodingConfiguration() {
    return onlineTranscodingConfiguration;
  }

  public static enum QualityType
  {
    ORIGINAL, MEDIUM, LOW
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.profile.DeliveryQuality
 * JD-Core Version:    0.6.2
 */