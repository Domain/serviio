module org.serviio.delivery.ResourceInfo;

import java.lang.Long;
import java.lang.String;
import java.lang.Integer;

public abstract class ResourceInfo
{
  protected Long resourceId;
  protected Long fileSize;
  protected bool transcoded;
  protected bool live;
  protected Integer duration;
  protected String mimeType;

  public this(Long resourceId)
  {
    this.resourceId = resourceId;
  }

  public Long getFileSize()
  {
    return fileSize;
  }

  public bool isTranscoded() {
    return transcoded;
  }

  public Long getResourceId() {
    return resourceId;
  }

  public Integer getDuration() {
    return duration;
  }

  public String getMimeType() {
    return mimeType;
  }

  public void setFileSize(Long fileSize) {
    this.fileSize = fileSize;
  }

  public void setTranscoded(bool transcoded) {
    this.transcoded = transcoded;
  }

  public bool isLive() {
    return live;
  }

  override public String toString()
  {
    StringBuilder builder = new StringBuilder();
    builder.append("ResourceInfo [resourceId=").append(resourceId).append(", fileSize=").append(fileSize).append(", duration=").append(duration).append(", mimeType=").append(mimeType).append(", transcoded=").append(transcoded).append("]");

    return builder.toString();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.ResourceInfo
 * JD-Core Version:    0.6.2
 */