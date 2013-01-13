module org.serviio.upnp.protocol.http.HttpMessageParser;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import org.apache.http.HttpException;
import org.apache.http.HttpRequest;
import org.apache.http.HttpResponse;
import org.apache.http.impl.DefaultHttpResponseFactory;
import org.apache.http.impl.io.HttpRequestParser;
import org.apache.http.impl.io.HttpResponseParser;
import org.apache.http.io.SessionInputBuffer;
import org.apache.http.message.BasicLineParser;
import org.apache.http.params.BasicHttpParams;

public class HttpMessageParser
{
  public static HttpRequest parseHttpRequest(String message)
  {
    ByteArrayInputStream stream = new ByteArrayInputStream(message.getBytes());
    SessionInputBuffer inbuffer = new StreamSessionInputBuffer(stream, 1024);
    try
    {
      org.apache.http.io.HttpMessageParser requestParser = new HttpRequestParser(inbuffer, new BasicLineParser(), new UniversalHttpRequestFactory(), new BasicHttpParams());

      HttpRequest request = cast(HttpRequest)requestParser.parse();
      return request;
    } finally {
      try {
        stream.close();
      }
      catch (IOException e)
      {
      }
    }
  }

  public static HttpResponse parseHttpResponse(String message)
  {
    ByteArrayInputStream stream = new ByteArrayInputStream(message.getBytes());
    SessionInputBuffer inbuffer = new StreamSessionInputBuffer(stream, 1024);
    try
    {
      org.apache.http.io.HttpMessageParser responseParser = new HttpResponseParser(inbuffer, new BasicLineParser(), new DefaultHttpResponseFactory(), new BasicHttpParams());

      HttpResponse response = cast(HttpResponse)responseParser.parse();
      return response;
    } finally {
      try {
        stream.close();
      }
      catch (IOException e)
      {
      }
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.http.HttpMessageParser
 * JD-Core Version:    0.6.2
 */