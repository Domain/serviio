module org.serviio.upnp.webserver.ResourceTransportRequestHandler;

import java.io.IOException;
import java.net.InetAddress;
import java.util.Map;
import java.util.Map : Entry;
import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.HttpException;
import org.apache.http.HttpRequest;
import org.apache.http.HttpResponse;
import org.apache.http.HttpVersion;
import org.apache.http.MethodNotSupportedException;
import org.apache.http.entity.AbstractHttpEntity;
import org.apache.http.entity.InputStreamEntity;
import org.apache.http.protocol.HttpContext;
import org.serviio.delivery.Client;
import org.serviio.delivery.HttpDeliveryContainer;
import org.serviio.delivery.HttpResponseCodeException;
import org.serviio.delivery.RangeHeaders;
import org.serviio.delivery.ResourceDeliveryProcessor;
import org.serviio.delivery.ResourceRetrievalStrategyFactory;
import org.serviio.profile.Profile;
import org.serviio.profile.ProfileManager;
import org.serviio.upnp.protocol.http.transport.DLNAProtocolHandler;
import org.serviio.upnp.protocol.http.transport.ResourceTransportProtocolHandler;
import org.serviio.util.CaseInsensitiveMap;
import org.serviio.util.HttpUtils;
import org.serviio.util.StringUtils;

public class ResourceTransportRequestHandler : AbstractRequestHandler
{
  private static final ResourceRetrievalStrategyFactory resourceRetrievalStrategyFactory = new ResourceRetrievalStrategyFactory();

  private ResourceTransportProtocolHandler dlnaProtocolHandler = new DLNAProtocolHandler();

  protected void handleRequest(HttpRequest request, HttpResponse response, HttpContext context)
  {
    try
    {
      log.debug_(HttpUtils.requestToString(request));
      ResourceDeliveryProcessor.HttpMethod method = ResourceDeliveryProcessor.HttpMethod.valueOf(StringUtils.localeSafeToUppercase(request.getRequestLine().getMethod()));
      InetAddress clientIPAddress = getCallerIPAddress(context);
      Profile rendererProfile = ProfileManager.getProfile(clientIPAddress);
      Client client = new Client(clientIPAddress, rendererProfile);
      String requestUri = getRequestUri(request);
      Map!(String, String) requestHeadersMap = getRequestHeadersMap(request);
      HttpDeliveryContainer container = (new ResourceDeliveryProcessor(resourceRetrievalStrategyFactory)).deliverContent(requestUri, method, getHttpVersion(), requestHeadersMap, parseRangeHeaders(requestHeadersMap), getProtocolHandler(client), client);

      if (method == ResourceDeliveryProcessor.HttpMethod.GET) {
        response.setEntity(createHttpEntity(container));
      }
      saveResponseHeaders(container.getResponseHeaders(), response);
      if (container.isPartialContent())
        response.setStatusLine(HttpVersion.HTTP_1_1, 206);
      else {
        response.setStatusLine(HttpVersion.HTTP_1_1, 200);
      }
      log.debug_(HttpUtils.responseToString(response));
    } catch (HttpResponseCodeException e) {
      response.setStatusCode(e.getHttpCode());
    } catch (Exception e) {
      response.setStatusCode(500);
      log.error(String.format("Error while processing resource, sending back 500 error. Message: %s", cast(Object[])[ e.getMessage() ]), e);
    }
  }

  protected void checkMethod(HttpRequest request)
  {
    String method = StringUtils.localeSafeToUppercase(request.getRequestLine().getMethod());
    if ((!method.equals("GET")) && (!method.equals("HEAD")))
      throw new MethodNotSupportedException(method + " method not supported");
  }

  private Map!(String, String) getRequestHeadersMap(HttpRequest request)
  {
    Map!(String, String) headers = new CaseInsensitiveMap!(String)();
    foreach (Header header ; request.getAllHeaders()) {
      headers.put(header.getName(), header.getValue());
    }
    return headers;
  }

  private RangeHeaders parseRangeHeaders(Map!(String, String) headers) {
    String rangeHeader = cast(String)headers.get("Range");
    String timeSeekHeader = cast(String)headers.get("TimeSeekRange.dlna.org");
    try {
      return RangeHeaders.parseHttpRange(RangeHeaders.RangeDefinition.DLNA, rangeHeader, timeSeekHeader);
    }
    catch (NumberFormatException e) {
      log.debug_("Unsupported range request, sending back 400");
    }throw new HttpResponseCodeException(400);
  }

  private void saveResponseHeaders(Map!(String, Object) headers, HttpResponse response)
  {
    foreach (Entry!(String, Object) header ; headers.entrySet())
      response.addHeader(cast(String)header.getKey(), header.getValue().toString());
  }

  private ResourceTransportProtocolHandler getProtocolHandler(Client client)
  {
    ResourceTransportProtocolHandler protocolHandler = client.getRendererProfile().getResourceTransportProtocolHandler();
    if (protocolHandler !is null) {
      return protocolHandler;
    }
    return dlnaProtocolHandler;
  }

  private HttpEntity createHttpEntity(HttpDeliveryContainer container)
  {
    AbstractHttpEntity fileEntity = new InputStreamEntity(container.getContentStream(), container.getFileSize().longValue());

    if (DLNAProtocolHandler.isChunked(container.getTransferMode(), container.getRequestHttpVersion(), container.isTranscoded())) {
      fileEntity.setChunked(true);
      log.debug_("Creating entity with chunked transfer");
    }
    return fileEntity;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.webserver.ResourceTransportRequestHandler
 * JD-Core Version:    0.6.2
 */