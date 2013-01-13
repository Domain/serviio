module org.serviio.delivery.SubtitlesInfo;

import java.lang.Long;
import java.lang.String;
import org.serviio.delivery.ResourceInfo;

public class SubtitlesInfo : ResourceInfo
{
  public this(Long resourceId, Long fileSize, String mimeType)
  {
    super(resourceId);
    this.fileSize = fileSize;
    this.mimeType = mimeType;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.SubtitlesInfo
 * JD-Core Version:    0.6.2
 */