module org.serviio.delivery.ResourceDeliveryProcessor;

import java.lang.Long;
import java.lang.String;
import java.io.ByteArrayInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Map : Entry;
import java.util.TreeMap;
import org.apache.http.ProtocolVersion;
import org.serviio.delivery.resource.transcode.TranscodingJobListener;
import org.serviio.dlna.MediaFormatProfile;
import org.serviio.dlna.UnsupportedDLNAMediaFileFormatException;
import org.serviio.upnp.protocol.http.transport.InvalidResourceRequestException;
import org.serviio.upnp.protocol.http.transport.RequestedResourceDescriptor;
import org.serviio.upnp.protocol.http.transport.ResourceTransportProtocolHandler;
import org.serviio.upnp.protocol.http.transport.TransferMode;
import org.serviio.util.ObjectValidator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ResourceDeliveryProcessor
{
  private static const Long TRANSCODED_VIDEO_CONTENT_LENGTH = new Long(50000000000L);
  private static const Long TRANSCODED_AUDIO_CONTENT_LENGTH = new Long(900000000L);
  private static const Long TRANSCODED_IMAGE_CONTENT_LENGTH = new Long(9000000L);

  private static immutable Logger log = LoggerFactory.getLogger!(ResourceDeliveryProcessor);
  private ResourceRetrievalStrategyFactory resourceRetrievalStrategyFactory;

  public this(ResourceRetrievalStrategyFactory resourceRetrievalStrategyFactory)
  {
    this.resourceRetrievalStrategyFactory = resourceRetrievalStrategyFactory;
  }

  public HttpDeliveryContainer deliverContent(String requestUri, HttpMethod method, ProtocolVersion httpVersion, Map!(String, String) requestHeaders, RangeHeaders rangeHeaders, ResourceTransportProtocolHandler protocolHandler, Client client)
  {
    log.debug_(String.format("Resource request accepted. Using client '%s'", cast(Object[])[ client ]));
    try
    {
      RequestedResourceDescriptor resourceReq = protocolHandler.getRequestedResourceDescription(requestUri);
      log.debug_(String.format("Request for resource %s and type '%s' received", cast(Object[])[ resourceReq.getResourceId(), resourceReq.getResourceType().toString() ]));

      ResourceRetrievalStrategy resourceRetrievalStrategy = resourceRetrievalStrategyFactory.instantiateResourceRetrievalStrategy(resourceReq.getResourceType());
      if (method == HttpMethod.GET)
      {
        MediaFormatProfile selectedVersion = getSelectedVersion(resourceReq.getTargetProfileName());
        ResourceInfo resourceInfo = resourceRetrievalStrategy.retrieveResourceInfo(resourceReq.getResourceId(), selectedVersion, resourceReq.getQuality(), client);
        return handleGETRequest(resourceRetrievalStrategy, resourceInfo, selectedVersion, resourceReq.getQuality(), requestHeaders, rangeHeaders, httpVersion, resourceReq.getProtocolInfoIndex(), client, protocolHandler);
      }

      ResourceInfo resourceInfo = resourceRetrievalStrategy.retrieveResourceInfo(resourceReq.getResourceId(), getSelectedVersion(resourceReq.getTargetProfileName()), resourceReq.getQuality(), client);
      TransferMode transferMode = getTransferMode(requestHeaders, resourceInfo);
      return handleHEADRequest(requestHeaders, httpVersion, resourceInfo, resourceReq.getProtocolInfoIndex(), transferMode, client, protocolHandler);
    }
    catch (FileNotFoundException e) {
      log.warn(String.format("Error while processing resource, sending back 404 error. Message: %s", cast(Object[])[ e.getMessage() ]));
      throw new HttpResponseCodeException(404);
    } catch (InvalidResourceRequestException e) {
      log.warn("Invalid request, sending back 400 error", e);
      throw new HttpResponseCodeException(400);
    } catch (UnsupportedDLNAMediaFileFormatException e) {
      log.warn("Invalid request, sending back 500 error", e);
    }throw new HttpResponseCodeException(500);
  }

  private HttpDeliveryContainer handleHEADRequest(Map!(String, String) requestHeaders, ProtocolVersion requestHttpVersion, ResourceInfo resourceInfo, Integer protocolInfoIndex, TransferMode transferMode, Client client, ResourceTransportProtocolHandler protocolHandler)
  {
    Map!(String, Object) responseHeaders = new LinkedHashMap!(String, Object)();
    responseHeaders.put("Content-Type", resourceInfo.getMimeType());
    Long streamSize = computeFileSize(resourceInfo);

    protocolHandler.handleResponse(requestHeaders, responseHeaders, HttpMethod.HEAD, requestHttpVersion, resourceInfo, protocolInfoIndex, transferMode, client, streamSize, null);
    log.debug_("Sending HEAD response back");
    return new HttpDeliveryContainer(responseHeaders);
  }

  private HttpDeliveryContainer handleGETRequest(ResourceRetrievalStrategy resourceRetrievalStrategy, ResourceInfo resourceInfo, MediaFormatProfile selectedVersion, DeliveryQuality.QualityType quality, Map!(String, String) requestHeaders, RangeHeaders requestRangeHeaders, ProtocolVersion requestHttpVersion, Integer protocolInfoIndex, Client client, ResourceTransportProtocolHandler protocolHandler)
  {
    bool markAsRead = markAsReadRequired(requestRangeHeaders);
    TransferMode transferMode = getTransferMode(requestHeaders, resourceInfo);

    HttpDeliveryContainer responseContainer = null;
    Long fileSize = computeFileSize(resourceInfo);
    RangeHeaders range = null;
    if ((requestRangeHeaders !is null) && (!resourceInfo.isLive()))
    {
      if (requestRangeHeaders.hasHeaders(RangeHeaders.RangeUnit.BYTES)) {
        range = protocolHandler.handleByteRange(requestRangeHeaders, requestHttpVersion, resourceInfo, fileSize);
        if (range !is null) {
          responseContainer = retrieveResource(resourceRetrievalStrategy, resourceInfo, selectedVersion, quality, transferMode, client, markAsRead, range.getStart(RangeHeaders.RangeUnit.BYTES).longValue(), range.getEnd(RangeHeaders.RangeUnit.BYTES).longValue() - range.getStart(RangeHeaders.RangeUnit.BYTES).longValue() + 1L, null, null, true, range.getTotal(RangeHeaders.RangeUnit.BYTES).longValue() != -1L, requestHttpVersion);
        }

      }

      if ((responseContainer is null) && (requestRangeHeaders.hasHeaders(RangeHeaders.RangeUnit.SECONDS)) && (resourceInfo.getDuration() !is null)) {
        range = protocolHandler.handleTimeRange(requestRangeHeaders, requestHttpVersion, resourceInfo);
        if (range !is null) {
          if ((range.getStart(RangeHeaders.RangeUnit.SECONDS).equals(Long.valueOf(0L))) && (range.getEnd(RangeHeaders.RangeUnit.SECONDS).equals(new Long(resourceInfo.getDuration().intValue()))))
          {
            responseContainer = retrieveResource(resourceRetrievalStrategy, resourceInfo, selectedVersion, quality, transferMode, client, markAsRead, 0L, fileSize.longValue(), null, null, false, true, requestHttpVersion);
          }
          else if (resourceInfo.getFileSize() is null)
          {
            if (client.isSupportsRandomTimeSeek())
            {
              Double requestedTimeOffset = Double.valueOf(range.getStart(RangeHeaders.RangeUnit.SECONDS).doubleValue());
              Double requestedDuration = new Double(range.getEnd(RangeHeaders.RangeUnit.SECONDS).longValue() - range.getStart(RangeHeaders.RangeUnit.SECONDS).longValue());
              responseContainer = retrieveResource(resourceRetrievalStrategy, resourceInfo, selectedVersion, quality, transferMode, client, markAsRead, 0L, fileSize.longValue(), requestedTimeOffset, requestedDuration, true, true, requestHttpVersion);
            }
            else {
              DeliveryContainer deliveryContainer = resourceRetrievalStrategy.retrieveResource(resourceInfo.getResourceId(), selectedVersion, quality, null, null, client, markAsRead);

              TranscodingJobListener jobListener = deliveryContainer.getTranscodingJobListener();
              if ((jobListener is null) || (jobListener.getFilesizeMap().size() == 0))
              {
                log.debug_("Unsupported time range request because current filesize is not available, sending back 406");
                throw new HttpResponseCodeException(406);
              }
              TreeMap!(Double, TranscodingJobListener.ProgressData) filesizeMap = jobListener.getFilesizeMap();
              Long startByte = convertSecondsToBytes(new Double(range.getStart(RangeHeaders.RangeUnit.SECONDS).longValue()), filesizeMap);
              log.debug_(String.format("Delivering bytes %s - %s from transcoded file, based on time range %s - %s", cast(Object[])[ startByte, fileSize, range.getStart(RangeHeaders.RangeUnit.SECONDS), range.getEnd(RangeHeaders.RangeUnit.SECONDS) ]));
              responseContainer = retrieveResource(deliveryContainer, resourceInfo, transferMode, client, startByte.longValue(), fileSize.longValue(), true, true, requestHttpVersion);
            }
          }
          else
          {
            log.debug_(String.format("Delivering bytes %s - %s from native file, based on time range %s - %s", cast(Object[])[ range.getStart(RangeHeaders.RangeUnit.BYTES), range.getEnd(RangeHeaders.RangeUnit.BYTES), range.getStart(RangeHeaders.RangeUnit.SECONDS), range.getEnd(RangeHeaders.RangeUnit.SECONDS) ]));
            responseContainer = retrieveResource(resourceRetrievalStrategy, resourceInfo, selectedVersion, quality, transferMode, client, markAsRead, range.getStart(RangeHeaders.RangeUnit.BYTES).longValue(), range.getEnd(RangeHeaders.RangeUnit.BYTES).longValue() - range.getStart(RangeHeaders.RangeUnit.BYTES).longValue() + 1L, null, null, true, true, requestHttpVersion);
          }
        }
      }

    }

    if (responseContainer is null)
    {
      responseContainer = retrieveResource(resourceRetrievalStrategy, resourceInfo, selectedVersion, quality, transferMode, client, markAsRead, 0L, fileSize.longValue(), null, null, false, true, requestHttpVersion);
    }

    protocolHandler.handleResponse(requestHeaders, responseContainer.getResponseHeaders(), HttpMethod.GET, requestHttpVersion, resourceInfo, protocolInfoIndex, transferMode, client, responseContainer.getFileSize(), range);
    log.debug_("Sending file back");
    return responseContainer;
  }

  private HttpDeliveryContainer retrieveResource(ResourceRetrievalStrategy resourceRetrievalStrategy, ResourceInfo resourceInfo, MediaFormatProfile selectedVersion, DeliveryQuality.QualityType quality, TransferMode transferMode, Client client, bool markAsRead, long skipBytes, long streamSize, Double timeOffsetInSeconds, Double requestedDurationInSeconds, bool partialContent, bool deliverStream, ProtocolVersion requestHttpVersion)
  {
    DeliveryContainer deliveryContainer = resourceRetrievalStrategy.retrieveResource(resourceInfo.getResourceId(), selectedVersion, quality, timeOffsetInSeconds, requestedDurationInSeconds, client, markAsRead);
    return retrieveResource(deliveryContainer, resourceInfo, transferMode, client, skipBytes, streamSize, partialContent, deliverStream, requestHttpVersion);
  }

  private HttpDeliveryContainer retrieveResource(DeliveryContainer deliveryContainer, ResourceInfo resourceInfo, TransferMode transferMode, Client client, long skipBytes, long streamSize, bool partialContent, bool deliverStream, ProtocolVersion requestHttpVersion)
  {
    Map!(String, Object) responseHeaders = new LinkedHashMap!(String, Object)();
    responseHeaders.put("Content-Type", resourceInfo.getMimeType());
    return prepareContainer(responseHeaders, deliveryContainer, transferMode, Long.valueOf(skipBytes), Long.valueOf(streamSize), partialContent, requestHttpVersion, resourceInfo.isTranscoded(), client.isExpectsClosedConnection(), deliverStream);
  }

  private HttpDeliveryContainer prepareContainer(Map!(String, Object) responseHeaders, DeliveryContainer container, TransferMode transferMode, Long skip, Long fileSize, bool partialContent, ProtocolVersion requestHttpVersion, bool transcoded, bool alwaysCloseConnection, bool deliverStream)
  {
    InputStream is_ = deliverStream ? (cast(StreamDeliveryContainer)container).getFileStream() : new ByteArrayInputStream(new byte[0]);
    Long contentLengthToRead = Long.valueOf(deliverStream ? (new Long(fileSize.longValue())).longValue() : 0L);
    if ((container.getResourceInfo().isTranscoded()) && ((transferMode == TransferMode.INTERACTIVE) || (transferMode == TransferMode.BACKGROUND) || (alwaysCloseConnection)))
    {
      contentLengthToRead = Long.valueOf(-1L);
      log.debug_("Entity will be consumed till the end");
    }
    log.debug_(String.format("Stream entity has length: %s", cast(Object[])[ contentLengthToRead ]));
    seekInInputStream(is_, skip);
    return new HttpDeliveryContainer(responseHeaders, is_, partialContent, requestHttpVersion, transferMode, transcoded, contentLengthToRead);
  }

  private void seekInInputStream(InputStream is_, Long skip)
  {
    try {
      is_.skip(skip.longValue());
    } catch (IOException e) {
      log.error("Cannot set starting index for the transport");
      throw new RuntimeException("Cannot skip file stream to requested byte: " + e.getMessage());
    }
  }

  private bool markAsReadRequired(RangeHeaders rangeHeaders)
  {
    bool offsetRequested = false;
    if (rangeHeaders !is null) {
      Long start = rangeHeaders.hasHeaders(RangeHeaders.RangeUnit.BYTES) ? rangeHeaders.getStart(RangeHeaders.RangeUnit.BYTES) : null;
      start = (start is null) && (rangeHeaders.hasHeaders(RangeHeaders.RangeUnit.SECONDS)) ? rangeHeaders.getStart(RangeHeaders.RangeUnit.SECONDS) : null;
      offsetRequested = (start !is null) && (!start.equals(new Long(0L)));
    }
    if (!offsetRequested)
    {
      return true;
    }
    return false;
  }

  private MediaFormatProfile getSelectedVersion(String profileName)
  {
    if (ObjectValidator.isNotEmpty(profileName)) {
      try {
        return MediaFormatProfile.valueOf(profileName);
      } catch (IllegalArgumentException e) {
        log.warn(String.format("Requested DLNA media format profile %s is not supported, using original profile of the media", cast(Object[])[ profileName ]));
        return null;
      }
    }
    return null;
  }

  private TransferMode getTransferMode(Map!(String, String) headers, ResourceInfo resourceInfo)
  {
    String requestedTransferMode = cast(String)headers.get("transferMode.dlna.org");
    if ((requestedTransferMode !is null) && (ObjectValidator.isNotEmpty(requestedTransferMode)))
    {
      return TransferMode.getValueByHttpHeaderValue(requestedTransferMode);
    }

    if ((( cast(ImageMediaInfo)resourceInfo !is null )) || (( cast(SubtitlesInfo)resourceInfo !is null ))) {
      return TransferMode.INTERACTIVE;
    }
    return TransferMode.STREAMING;
  }

  private Long computeFileSize(ResourceInfo resourceInfo)
  {
    if (resourceInfo.getFileSize() !is null) {
      return resourceInfo.getFileSize();
    }

    if (( cast(ImageMediaInfo)resourceInfo !is null ))
      return TRANSCODED_IMAGE_CONTENT_LENGTH;
    if (( cast(AudioMediaInfo)resourceInfo !is null ))
      return TRANSCODED_AUDIO_CONTENT_LENGTH;
    if (( cast(VideoMediaInfo)resourceInfo !is null )) {
      return TRANSCODED_VIDEO_CONTENT_LENGTH;
    }
    return null;
  }

  protected Long convertSecondsToBytes(Double seconds, TreeMap!(Double, TranscodingJobListener.TranscodingJobListener.ProgressData) filesizeMap)
  {
    if (seconds.doubleValue() == 0.0) {
      return Long.valueOf(0L);
    }
    if (seconds.doubleValue() <= (cast(Double)filesizeMap.lastKey()).doubleValue())
    {
      Entry!(Double, TranscodingJobListener.ProgressData) upperBoundary = filesizeMap.ceilingEntry(seconds);
      Entry!(Double, TranscodingJobListener.ProgressData) lowerBoundary = filesizeMap.floorEntry(seconds);

      if (lowerBoundary is null) {
        return convertSecondsToBytes((cast(TranscodingJobListener.TranscodingJobListener.ProgressData)upperBoundary.getValue()).getFileSize(), cast(Double)upperBoundary.getKey(), Long.valueOf(0L), Double.valueOf(0.0), seconds);
      }
      return convertSecondsToBytes((cast(TranscodingJobListener.TranscodingJobListener.ProgressData)upperBoundary.getValue()).getFileSize(), cast(Double)upperBoundary.getKey(), (cast(TranscodingJobListener.TranscodingJobListener.ProgressData)lowerBoundary.getValue()).getFileSize(), cast(Double)lowerBoundary.getKey(), seconds);
    }

    Entry!(Double, TranscodingJobListener.ProgressData) lastEntry = filesizeMap.lastEntry();
    Double secondsFromLast = Double.valueOf(seconds.doubleValue() - (cast(Double)lastEntry.getKey()).doubleValue());
    Double approxFileSizeSinceLastEntry = Double.valueOf((cast(TranscodingJobListener.TranscodingJobListener.ProgressData)lastEntry.getValue()).getBitrate().floatValue() * secondsFromLast.doubleValue() / 8.0 * 1024.0);
    return Long.valueOf((cast(TranscodingJobListener.TranscodingJobListener.ProgressData)lastEntry.getValue()).getFileSize().longValue() + approxFileSizeSinceLastEntry.longValue());
  }

  private Long convertSecondsToBytes(Long upperFileSize, Double upperTime, Long lowerFilesize, Double lowerTime, Double seconds)
  {
    if (upperTime.equals(lowerTime)) {
      return Long.valueOf(upperFileSize.longValue() * 1024L);
    }
    Long segmentFilesize = Long.valueOf(upperFileSize.longValue() - lowerFilesize.longValue());
    Double segmentDuration = Double.valueOf(upperTime.doubleValue() - lowerTime.doubleValue());
    Double kBytesPerSecond = Double.valueOf(segmentFilesize.longValue() / segmentDuration.doubleValue());
    Double approxkBytes = Double.valueOf(lowerFilesize.longValue() + kBytesPerSecond.doubleValue() * (seconds.doubleValue() - lowerTime.doubleValue()));
    return Long.valueOf(approxkBytes.longValue() * 1024L);
  }

  public static enum HttpMethod
  {
    GET, HEAD
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.ResourceDeliveryProcessor
 * JD-Core Version:    0.6.2
 */