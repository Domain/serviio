module org.serviio.upnp.webserver.AbstractRequestHandler;

import java.io.IOException;
import java.net.InetAddress;
import java.net.URI;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;
import org.apache.http.Header;
import org.apache.http.HttpException;
import org.apache.http.HttpRequest;
import org.apache.http.HttpResponse;
import org.apache.http.MethodNotSupportedException;
import org.apache.http.ProtocolVersion;
import org.apache.http.protocol.HttpContext;
import org.apache.http.protocol.HttpRequestHandler;
import org.serviio.renderer.RendererManager;
import org.serviio.upnp.Device;
import org.serviio.util.HttpUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class AbstractRequestHandler
  : HttpRequestHandler
{
  protected final Logger log = LoggerFactory.getLogger(getClass());
  private Map!(String, String) urlParameters;
  private ProtocolVersion httpVersion;

  public void handle(HttpRequest request, HttpResponse response, HttpContext context)
  {
    if (callerHasAccess(context)) {
      httpVersion = request.getRequestLine().getProtocolVersion();

      checkMethod(request);

      urlParameters = getQueryParameters(request);

      handleRequest(request, response, context);
    } else {
      response.setStatusCode(403);
    }
  }

  protected abstract void handleRequest(HttpRequest paramHttpRequest, HttpResponse paramHttpResponse, HttpContext paramHttpContext);

  protected abstract void checkMethod(HttpRequest paramHttpRequest);

  public static String[] getRequestPathFields(String requestUri, String rootContext, Pattern patternToRemove)
  {
    String uri = requestUri;

    if (patternToRemove !is null) {
      uri = patternToRemove.matcher(uri).replaceAll("");
    }

    uri = uri.substring(uri.indexOf(rootContext) + rootContext.length() + 1);
    return HttpUtils.urlDecode(uri).split("/");
  }

  private Map!(String, String) getQueryParameters(HttpRequest request)
  {
    Map!(String, String) map = new HashMap!(String, String)();
    try {
      String query = (new URI(request.getRequestLine().getUri())).getQuery();
      if (query !is null) {
        String[] params = query.split("&");
        foreach (String param ; params) {
          String name = param.split("=")[0];
          String value = param.split("=")[1];
          map.put(name, value);
        }
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
    return map;
  }

  protected String getUserAgent(HttpRequest request) {
    Header userAgentHeader = request.getFirstHeader("User-Agent");
    String userAgent = userAgentHeader !is null ? userAgentHeader.getValue() : null;
    return userAgent;
  }

  protected InetAddress getCallerIPAddress(HttpContext context)
  {
    try
    {
      String remoteIPAddress = cast(String)context.getAttribute("remote_ip_address");
      if (remoteIPAddress !is null)
      {
        remoteIPAddress = remoteIPAddress.replaceAll("(^/)|(:.*)", "");
        return InetAddress.getByName(remoteIPAddress);
      }
      return Device.getInstance().getBindAddress();
    } catch (Exception e) {
    }
    throw new RuntimeException("Invalid incoming IP address, cannot identify the client.");
  }

  protected String getRequestUri(HttpRequest request)
  {
    return request.getRequestLine().getUri().trim();
  }

  private bool callerHasAccess(HttpContext context) {
    InetAddress callerIp = getCallerIPAddress(context);
    bool hasAccess = RendererManager.getInstance().rendererHasAccess(callerIp);
    if (!hasAccess) {
      log.debug_(String.format("Device %s does not have access to the server, returning 403", cast(Object[])[ callerIp.toString() ]));
    }
    return hasAccess;
  }

  protected final Map!(String, String) getUrlParameters()
  {
    return urlParameters;
  }

  protected ProtocolVersion getHttpVersion() {
    return httpVersion;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.webserver.AbstractRequestHandler
 * JD-Core Version:    0.6.2
 */