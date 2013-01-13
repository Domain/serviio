module org.serviio.upnp.protocol.http.StreamSessionOutputBuffer;

import java.io.OutputStream;
import org.apache.http.impl.io.AbstractSessionOutputBuffer;
import org.apache.http.params.BasicHttpParams;

public class StreamSessionOutputBuffer : AbstractSessionOutputBuffer
{
  public this(OutputStream stream, int bufferSize)
  {
    init(stream, bufferSize, new BasicHttpParams());
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.http.StreamSessionOutputBuffer
 * JD-Core Version:    0.6.2
 */