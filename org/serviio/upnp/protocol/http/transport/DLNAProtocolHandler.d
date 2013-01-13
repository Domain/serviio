module org.serviio.upnp.protocol.http.transport.DLNAProtocolHandler;

import java.io.IOException;
import java.util.Date;
import java.util.List;
import java.util.Map;
import org.apache.http.HttpVersion;
import org.apache.http.ProtocolVersion;
import org.serviio.delivery.Client;
import org.serviio.delivery.HttpResponseCodeException;
import org.serviio.delivery.MediaFormatProfileResource;
import org.serviio.delivery.RangeHeaders;
import org.serviio.delivery.ResourceDeliveryProcessor : HttpMethod;
import org.serviio.delivery.ResourceInfo;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.local.service.MediaService;
import org.serviio.library.online.OnlineItemService;
import org.serviio.library.online.metadata.OnlineItem;
import org.serviio.upnp.protocol.ssdp.SSDPConstants;
import org.serviio.upnp.service.contentdirectory.ProtocolAdditionalInfo;
import org.serviio.util.DateUtils;

public class DLNAProtocolHandler : AbstractProtocolHandler
{
  public static bool isChunked(TransferMode transferMode, ProtocolVersion httpVersion, bool transcoded)
  {
    if ((httpVersion == HttpVersion.HTTP_1_1) && (transcoded) && (transferMode == TransferMode.STREAMING)) {
      return true;
    }
    return false;
  }

  public void handleResponse(Map!(String, String) requestHeaders, Map!(String, Object) responseHeaders, HttpMethod httpMethod, ProtocolVersion requestHttpVersion, ResourceInfo resourceInfo, Integer protocolInfoIndex, TransferMode transferMode, Client client, Long streamSize, RangeHeaders range)
  {
    String contentFeaturesHeader = cast(String)requestHeaders.get("getcontentFeatures.dlna.org");

    setContentLengthResponseHeader(responseHeaders, getResponseContentLength(streamSize, isChunked(transferMode, requestHttpVersion, resourceInfo.isTranscoded())));
    responseHeaders.put("Date", DateUtils.formatRFC1123(new Date()));
    responseHeaders.put("Server", SSDPConstants.SERVER);
    responseHeaders.put("Cache-control", "no-cache");

    if (range !is null) {
      if (range.hasHeaders(RangeHeaders.RangeUnit.SECONDS)) {
        responseHeaders.put("TimeSeekRange.dlna.org", String.format("npt=%s-%s/%s", cast(Object[])[ range.getStart(RangeHeaders.RangeUnit.SECONDS), range.getEnd(RangeHeaders.RangeUnit.SECONDS), range.getTotal(RangeHeaders.RangeUnit.SECONDS) ]));
      } else if (range.hasHeaders(RangeHeaders.RangeUnit.BYTES)) {
        long total = range.getTotal(RangeHeaders.RangeUnit.BYTES).longValue();
        responseHeaders.put("Content-Range", String.format("bytes %s-%s/%s", cast(Object[])[ range.getStart(RangeHeaders.RangeUnit.BYTES), range.getEnd(RangeHeaders.RangeUnit.BYTES), total == -1L ? "50000000000" : Long.valueOf(total) ]));
      }
    }

    if (contentFeaturesHeader !is null) {
      if (contentFeaturesHeader.trim().equals("1")) {
        storeContentFeatures(responseHeaders, resourceInfo, protocolInfoIndex, client);
      }
      else
      {
        throw new HttpResponseCodeException(400);
      }
    }

    responseHeaders.put("transferMode.dlna.org", transferMode.httpHeaderValue());
    responseHeaders.put("realTimeInfo.dlna.org", "DLNA.ORG_TLAG=*");
  }

  public bool supportsRangeHeader(RangeHeaders.RangeUnit type, bool http11, bool transcoded)
  {
    if (type == RangeHeaders.RangeUnit.BYTES) {
      if ((http11) || ((!http11) && (!transcoded)))
      {
        return true;
      }
      return false;
    }

    if (!transcoded) {
      return false;
    }
    return true;
  }

  protected RangeHeaders unsupportedRangeHeader(RangeHeaders.RangeUnit type, RangeHeaders range, bool http11, bool transcoded, Long streamSize)
  {
    if (type == RangeHeaders.RangeUnit.BYTES)
    {
      if ((!range.hasHeaders(RangeHeaders.RangeUnit.SECONDS)) || (!supportsRangeHeader(RangeHeaders.RangeUnit.SECONDS, http11, transcoded)))
      {
        log.debug_("Unsupported range request, sending back 416");
        throw new HttpResponseCodeException(416);
      }
      return null;
    }
    return null;
  }

  protected void storeContentFeatures(Map!(String, Object) responseHeaders, ResourceInfo resourceInfo, Integer protocolInfoIndex, Client client)
  {
    if (( cast(MediaFormatProfileResource)resourceInfo !is null )) {
      MediaFormatProfileResource ri = cast(MediaFormatProfileResource)resourceInfo;
      List/*!(? : ProtocolAdditionalInfo)*/ pis = client.getRendererProfile().getResourceProtocolInfo(ri.getFormatProfile()).getAdditionalInfos();
      ProtocolAdditionalInfo pi = cast(ProtocolAdditionalInfo)pis.get(protocolInfoIndex !is null ? protocolInfoIndex.intValue() : 0);
      responseHeaders.put("contentFeatures.dlna.org", pi.buildMediaProtocolInfo(resourceInfo.isTranscoded(), resourceInfo.isLive(), (cast(MediaFormatProfileResource)resourceInfo).getFormatProfile().getFileType(), (resourceInfo.getDuration() !is null) && (resourceInfo.getDuration().intValue() > 0)));
    }
  }

  protected MediaItem getMediaItemResource(RequestedResourceDescriptor originalDescriptor)
  {
    MediaItem mediaItem = null;
    if (MediaItem.isLocalMedia(originalDescriptor.getResourceId()))
      mediaItem = MediaService.readMediaItemById(originalDescriptor.getResourceId());
    else
      try {
        OnlineItem onlineItem = OnlineItemService.findOnlineItemById(originalDescriptor.getResourceId());
        if (onlineItem !is null)
          mediaItem = onlineItem.toMediaItem();
      }
      catch (IOException e)
      {
      }
    return mediaItem;
  }

  private void setContentLengthResponseHeader(Map!(String, Object) responseHeaders, Long fileSize) {
    if (fileSize !is null)
      responseHeaders.put("Content-Length", fileSize.toString());
  }

  private Long getResponseContentLength(Long filesize, bool chunked)
  {
    if (!chunked)
    {
      if ((filesize !is null) && (filesize.longValue() >= 0L)) {
        return filesize;
      }
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.http.transport.DLNAProtocolHandler
 * JD-Core Version:    0.6.2
 */