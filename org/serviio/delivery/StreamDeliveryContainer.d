module org.serviio.delivery.StreamDeliveryContainer;

import java.io.InputStream;
import org.serviio.delivery.resource.transcode.TranscodingJobListener;
import org.serviio.delivery.DeliveryContainer;
import org.serviio.delivery.ResourceInfo;

public class StreamDeliveryContainer : DeliveryContainer
{
  private InputStream fileStream;

  public this(InputStream fileStream, ResourceInfo resourceInfo)
  {
    super(resourceInfo);
    this.fileStream = fileStream;
  }

  public this(InputStream fileStream, ResourceInfo resourceInfo, TranscodingJobListener jobListener) {
    super(resourceInfo, jobListener);
    this.fileStream = fileStream;
  }

  public InputStream getFileStream()
  {
    return fileStream;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.StreamDeliveryContainer
 * JD-Core Version:    0.6.2
 */