module org.serviio.delivery.resource.transcode.StreamDescriptor;

import java.lang.Long;
import java.io.InputStream;

class StreamDescriptor
{
  private InputStream stream;
  private Long fileSize;

  public this(InputStream stream, Long fileSize)
  {
    this.stream = stream;
    this.fileSize = fileSize;
  }

  public InputStream getStream() {
    return stream;
  }

  public Long getFileSize() {
    return fileSize;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.resource.transcode.StreamDescriptor
 * JD-Core Version:    0.6.2
 */