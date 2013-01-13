module org.serviio.upnp.webserver.ServiioHttpService;

import java.io.IOException;
import org.apache.http.ConnectionReuseStrategy;
import org.apache.http.HttpException;
import org.apache.http.HttpRequest;
import org.apache.http.HttpResponse;
import org.apache.http.HttpResponseFactory;
import org.apache.http.protocol.HttpContext;
import org.apache.http.protocol.HttpProcessor;
import org.apache.http.protocol.HttpService;

public class ServiioHttpService : HttpService
{
  public this(HttpProcessor proc, ConnectionReuseStrategy connStrategy, HttpResponseFactory responseFactory)
  {
    super(proc, connStrategy, responseFactory);
  }

  protected void doService(HttpRequest request, HttpResponse response, HttpContext context)
  {
    super.doService(request, response, context);

    if (response.getStatusLine().getStatusCode() == 501)
    {
      response.setStatusCode(404);
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.webserver.ServiioHttpService
 * JD-Core Version:    0.6.2
 */