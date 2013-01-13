module org.serviio.ui.representation.RemoteAccessRepresentation;

import org.serviio.profile.DeliveryQuality : QualityType;

public class RemoteAccessRepresentation
{
  private String remoteUserPassword;
  private QualityType preferredRemoteDeliveryQuality;

  public String getRemoteUserPassword()
  {
    return remoteUserPassword;
  }

  public void setRemoteUserPassword(String remoteUserPassword) {
    this.remoteUserPassword = remoteUserPassword;
  }

  public QualityType getPreferredRemoteDeliveryQuality() {
    return preferredRemoteDeliveryQuality;
  }

  public void setPreferredRemoteDeliveryQuality(QualityType preferredRemoteDeliveryQuality) {
    this.preferredRemoteDeliveryQuality = preferredRemoteDeliveryQuality;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.representation.RemoteAccessRepresentation
 * JD-Core Version:    0.6.2
 */