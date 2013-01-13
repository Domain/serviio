module org.serviio.upnp.protocol.http.UniversalHttpRequestFactory;

import org.apache.http.HttpRequest;
import org.apache.http.MethodNotSupportedException;
import org.apache.http.RequestLine;
import org.apache.http.impl.DefaultHttpRequestFactory;
import org.apache.http.message.BasicHttpRequest;

public class UniversalHttpRequestFactory : DefaultHttpRequestFactory
{
  public HttpRequest newHttpRequest(RequestLine requestline)
  {
    HttpRequest request = null;
    try {
      request = super.newHttpRequest(requestline);
    } catch (MethodNotSupportedException e) {
      request = new BasicHttpRequest(requestline);
    }
    return request;
  }

  public HttpRequest newHttpRequest(String method, String uri)
  {
    HttpRequest request = null;
    try {
      request = super.newHttpRequest(method, uri);
    } catch (MethodNotSupportedException e) {
      request = new BasicHttpRequest(method, uri);
    }
    return request;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.http.UniversalHttpRequestFactory
 * JD-Core Version:    0.6.2
 */