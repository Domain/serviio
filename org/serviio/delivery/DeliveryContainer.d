module org.serviio.delivery.DeliveryContainer;

import org.serviio.delivery.resource.transcode.TranscodingJobListener;

public abstract class DeliveryContainer
{
  private ResourceInfo resourceInfo;
  private TranscodingJobListener jobListener;

  public this(ResourceInfo resourceInfo)
  {
    this.resourceInfo = resourceInfo;
  }

  public this(ResourceInfo resourceInfo, TranscodingJobListener jobListener) {
    this(resourceInfo);
    this.jobListener = jobListener;
  }

  public ResourceInfo getResourceInfo()
  {
    return resourceInfo;
  }

  public TranscodingJobListener getTranscodingJobListener() {
    return jobListener;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.DeliveryContainer
 * JD-Core Version:    0.6.2
 */