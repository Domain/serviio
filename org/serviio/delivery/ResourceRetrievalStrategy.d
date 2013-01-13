module org.serviio.delivery.ResourceRetrievalStrategy;

import java.lang.Long;
import java.lang.Double;
import java.io.FileNotFoundException;
import java.io.IOException;
import org.serviio.dlna.MediaFormatProfile;
import org.serviio.dlna.UnsupportedDLNAMediaFileFormatException;
import org.serviio.profile.DeliveryQuality;

public abstract interface ResourceRetrievalStrategy
{
  public abstract DeliveryContainer retrieveResource(Long paramLong, MediaFormatProfile paramMediaFormatProfile, DeliveryQuality.QualityType paramQualityType, Double paramDouble1, Double paramDouble2, Client paramClient, bool paramBoolean);

  public abstract ResourceInfo retrieveResourceInfo(Long paramLong, MediaFormatProfile paramMediaFormatProfile, DeliveryQuality.QualityType paramQualityType, Client paramClient);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.ResourceRetrievalStrategy
 * JD-Core Version:    0.6.2
 */