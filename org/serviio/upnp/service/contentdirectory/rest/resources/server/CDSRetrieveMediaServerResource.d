module org.serviio.upnp.service.contentdirectory.rest.resources.server.CDSRetrieveMediaServerResource;

import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.Map;
import org.apache.http.HttpVersion;
import org.restlet.Request;
import org.restlet.data.MediaType;
import org.restlet.data.Range;
import org.restlet.data.Status;
import org.restlet.representation.StreamRepresentation;
import org.serviio.delivery.Client;
import org.serviio.delivery.HttpDeliveryContainer;
import org.serviio.delivery.HttpResponseCodeException;
import org.serviio.delivery.RangeHeaders;
import org.serviio.delivery.ResourceDeliveryProcessor;
import org.serviio.delivery.ResourceRetrievalStrategyFactory;
import org.serviio.profile.Profile;
import org.serviio.profile.ProfileManager;
import org.serviio.restlet.HttpCodeException;
import org.serviio.upnp.protocol.http.transport.CDSProtocolHandler;
import org.serviio.upnp.protocol.ssdp.SSDPConstants;
import org.serviio.upnp.service.contentdirectory.rest.representation.ClosingInputRepresentation;
import org.serviio.upnp.service.contentdirectory.rest.resources.CDSRetrieveMediaResource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CDSRetrieveMediaServerResource : AbstractRestrictedCDSServerResource
  , CDSRetrieveMediaResource
{
  public static final String RESOURCE_CONTEXT = "/resource";
  private static final Logger log = LoggerFactory.getLogger!(CDSRetrieveMediaServerResource);

  private static final ResourceRetrievalStrategyFactory resourceRetrievalStrategyFactory = new ResourceRetrievalStrategyFactory();
  private Profile profile;

  public StreamRepresentation deliver()
  {
    Request request = getRequest();
    log.debug_(request.toString());
    ResourceDeliveryProcessor processor = new ResourceDeliveryProcessor(resourceRetrievalStrategyFactory);

    String normalizedPath = getAndRemoveProfileFromPath(request.getOriginalRef().getPath());
    try {
      Map!(String, String) requestHeaders = getRequestHeaders(request);
      HttpDeliveryContainer container = processor.deliverContent(normalizedPath, ResourceDeliveryProcessor.HttpMethod.GET, getProtocol().getVersion().equals("1.1") ? HttpVersion.HTTP_1_1 : HttpVersion.HTTP_1_0, requestHeaders, parseRequestRangeHeaders(requestHeaders, request), new CDSProtocolHandler(), getClient());

      ClosingInputRepresentation rep = new ClosingInputRepresentation(container.getContentStream(), getMediaType(container.getResponseHeaders()), getFullStreamSize(container), getDeliveredStreamSize(container), getRequest());

      getResponse().setEntity(rep);
      getResponse().setDimensions(null);
      if (container.isPartialContent()) {
        setRange(container.getResponseHeaders());
      }
      getResponse().setStatus(container.isPartialContent() ? Status.SUCCESS_PARTIAL_CONTENT : Status.SUCCESS_OK);
      getResponse().getServerInfo().setAgent(SSDPConstants.SERVER);
      return rep;
    } catch (HttpResponseCodeException e) {
      throw new HttpCodeException(e.getHttpCode(), e.getMessage(), e.getCause());
    }
  }

  private String getAndRemoveProfileFromPath(String path)
  {
    int profilePosition = path.lastIndexOf(",");
    if (profilePosition > -1) {
      String normalizedPath = path.substring(0, profilePosition);
      profile = ProfileManager.getProfileById(path.substring(profilePosition + 1));
      if (profile !is null) {
        return normalizedPath;
      }
    }
    log.warn("Request doesn't include profile id or the profile is invalid");
    throw new HttpCodeException(400);
  }

  private Client getClient() {
    try {
      InetAddress clientIPAddress = InetAddress.getByName(getClientInfo().getAddress());
      Client c = new Client(clientIPAddress, profile);
      c.setExpectsClosedConnection(true);
      c.setSupportsRandomTimeSeek(true);
      return c;
    } catch (UnknownHostException e) {
      throw new RuntimeException("Cannot retrieve client IP address", e);
    }
  }

  private void setRange(Map!(String, Object) headers)
  {
    RangeHeaders range = getResponseRangeHeader(headers);
    if (range !is null) {
      if (range.hasHeaders(RangeHeaders.RangeUnit.BYTES)) {
        getResponse().getEntity().setRange(new Range(range.getStart(RangeHeaders.RangeUnit.BYTES).longValue(), range.getEnd(RangeHeaders.RangeUnit.BYTES).longValue() - range.getStart(RangeHeaders.RangeUnit.BYTES).longValue()));
      }
      if (range.hasHeaders(RangeHeaders.RangeUnit.SECONDS)) {
        Range rangeHeader = new Range(range.getStart(RangeHeaders.RangeUnit.SECONDS).longValue(), range.getEnd(RangeHeaders.RangeUnit.SECONDS).longValue() - range.getStart(RangeHeaders.RangeUnit.SECONDS).longValue());
        rangeHeader.setUnitName("seconds");
        rangeHeader.setTotalSize(range.getTotal(RangeHeaders.RangeUnit.SECONDS));
        getResponse().getEntity().setRange(rangeHeader);
      }
    }
  }

  private RangeHeaders getResponseRangeHeader(Map!(String, Object) headers) {
    RangeHeaders range = cast(RangeHeaders)headers.get("Content-Range");
    return range;
  }

  private long getFullStreamSize(HttpDeliveryContainer container) {
    RangeHeaders range = getResponseRangeHeader(container.getResponseHeaders());
    if ((container.isPartialContent()) && (range !is null) && (range.hasHeaders(RangeHeaders.RangeUnit.BYTES))) {
      return range.getTotal(RangeHeaders.RangeUnit.BYTES).longValue();
    }
    return container.getFileSize().longValue();
  }

  private Long getDeliveredStreamSize(HttpDeliveryContainer container)
  {
    RangeHeaders range = getResponseRangeHeader(container.getResponseHeaders());
    if ((container.isPartialContent()) && (range !is null) && (range.hasHeaders(RangeHeaders.RangeUnit.BYTES))) {
      return Long.valueOf(range.getEnd(RangeHeaders.RangeUnit.BYTES).longValue() - range.getStart(RangeHeaders.RangeUnit.BYTES).longValue());
    }
    return null;
  }

  private MediaType getMediaType(Map!(String, Object) headers)
  {
    String contentType = getHeaderStringValue("Content-Type", headers);
    if (contentType !is null) {
      return new MediaType(contentType);
    }
    return null;
  }

  private RangeHeaders parseRequestRangeHeaders(Map!(String, String) headers, Request request) {
    String rangeHeader = cast(String)headers.get("Range");
    String startSecond = request.getResourceRef().getQueryAsForm().getFirstValue("start", true);
    try {
      return RangeHeaders.parseHttpRange(RangeHeaders.RangeDefinition.CDS, rangeHeader, startSecond);
    }
    catch (NumberFormatException e) {
      log.debug_("Unsupported range request, sending back 400");
    }throw new HttpResponseCodeException(400);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.rest.resources.server.CDSRetrieveMediaServerResource
 * JD-Core Version:    0.6.2
 */