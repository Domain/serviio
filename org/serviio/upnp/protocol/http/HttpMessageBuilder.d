module org.serviio.upnp.protocol.http.HttpMessageBuilder;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import org.apache.http.HttpRequest;
import org.apache.http.HttpResponse;
import org.apache.http.impl.io.HttpRequestWriter;
import org.apache.http.impl.io.HttpResponseWriter;
import org.apache.http.io.HttpMessageWriter;
import org.apache.http.io.SessionOutputBuffer;
import org.apache.http.message.BasicLineFormatter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HttpMessageBuilder
{
  private static final Logger log = LoggerFactory.getLogger!(HttpMessageBuilder);

  public static String transformToString(HttpRequest request)
  {
    ByteArrayOutputStream stream = new ByteArrayOutputStream(1024);
    SessionOutputBuffer outbuffer = new StreamSessionOutputBuffer(stream, 1024);
    HttpMessageWriter requestWriter = new HttpRequestWriter(outbuffer, new BasicLineFormatter(), null);
    try
    {
      requestWriter.write(request);
      outbuffer.flush();
      return stream.toString();
    } catch (Exception e) {
      log.error("Error during generating HTTP request message", e);
    } finally {
      try {
        stream.close();
      } catch (IOException e) {
      }
    }
    return null;
  }

  public static String transformToString(HttpResponse response)
  {
    ByteArrayOutputStream stream = new ByteArrayOutputStream(1024);
    SessionOutputBuffer outbuffer = new StreamSessionOutputBuffer(stream, 1024);
    HttpMessageWriter responseWriter = new HttpResponseWriter(outbuffer, new BasicLineFormatter(), null);
    try
    {
      responseWriter.write(response);
      outbuffer.flush();
      return stream.toString();
    } catch (Exception e) {
      log.error("Error during generating HTTP response message", e);
    } finally {
      try {
        stream.close();
      } catch (IOException e) {
      }
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.http.HttpMessageBuilder
 * JD-Core Version:    0.6.2
 */