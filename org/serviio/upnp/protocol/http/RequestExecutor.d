module org.serviio.upnp.protocol.http.RequestExecutor;

import java.io.IOException;
import java.net.Socket;
import java.net.URL;
import org.apache.http.HttpException;
import org.apache.http.HttpHost;
import org.apache.http.HttpRequest;
import org.apache.http.HttpResponse;
import org.apache.http.HttpVersion;
import org.apache.http.impl.DefaultHttpClientConnection;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpParams;
import org.apache.http.protocol.BasicHttpContext;
import org.apache.http.protocol.BasicHttpProcessor;
import org.apache.http.protocol.HttpContext;
import org.apache.http.protocol.HttpRequestExecutor;
import org.apache.http.protocol.RequestContent;
import org.apache.http.protocol.RequestTargetHost;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RequestExecutor
{
  private static HttpParams params = new BasicHttpParams();

  private static immutable Logger log = LoggerFactory.getLogger!(RequestExecutor);

  public static HttpResponse send(HttpRequest request, URL deliveryURL)
  {
    BasicHttpProcessor httpproc = new BasicHttpProcessor();

    httpproc.addInterceptor(new RequestContent());
    httpproc.addInterceptor(new RequestTargetHost());

    HttpRequestExecutor httpexecutor = new HttpRequestExecutor();
    HttpHost host = new HttpHost(deliveryURL.getHost(), deliveryURL.getPort() != -1 ? deliveryURL.getPort() : 80);
    DefaultHttpClientConnection conn = new DefaultHttpClientConnection();

    HttpContext context = new BasicHttpContext(null);
    context.setAttribute("http.connection", conn);
    context.setAttribute("http.target_host", host);
    try
    {
      log.debug_(String.format("Sending HTTP request to %s:%s", cast(Object[])[ host.getHostName(), Integer.valueOf(host.getPort()) ]));
      Socket socket = new Socket(host.getHostName(), host.getPort());
      conn.bind(socket, params);

      request.setParams(params);
      httpexecutor.preProcess(request, httpproc, context);
      HttpResponse response = httpexecutor.execute(request, conn, context);
      response.setParams(params);
      httpexecutor.postProcess(response, httpproc, context);

      socket.close();
      return response;
    } finally {
      conn.close();
    }
  }

  static this()
  {
    params.setIntParameter("http.socket.timeout", 30000);

    params.setParameter("http.protocol.version", HttpVersion.HTTP_1_1);

    params.setParameter("http.protocol.content-charset", "UTF-8");
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.http.RequestExecutor
 * JD-Core Version:    0.6.2
 */