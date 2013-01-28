module org.serviio.ui.representation.RemoteAccessRepresentation;

import java.lang.String;
import org.serviio.profile.DeliveryQuality;

public class RemoteAccessRepresentation
{
    private String remoteUserPassword;
    private DeliveryQuality.QualityType preferredRemoteDeliveryQuality;

    public String getRemoteUserPassword()
    {
        return remoteUserPassword;
    }

    public void setRemoteUserPassword(String remoteUserPassword) {
        this.remoteUserPassword = remoteUserPassword;
    }

    public DeliveryQuality.QualityType getPreferredRemoteDeliveryQuality() {
        return preferredRemoteDeliveryQuality;
    }

    public void setPreferredRemoteDeliveryQuality(DeliveryQuality.QualityType preferredRemoteDeliveryQuality) {
        this.preferredRemoteDeliveryQuality = preferredRemoteDeliveryQuality;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.ui.representation.RemoteAccessRepresentation
* JD-Core Version:    0.6.2
*/