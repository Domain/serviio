module org.serviio.delivery.resource.AbstractDeliveryEngine;

import java.lang.String;
import java.lang.Double;
import java.lang.Long;
import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map : Entry;
import org.serviio.ApplicationSettings;
import org.serviio.delivery.Client;
import org.serviio.delivery.DeliveryContainer;
import org.serviio.delivery.MediaFormatProfileResource;
import org.serviio.delivery.OnlineInputStream;
import org.serviio.delivery.StreamDeliveryContainer;
import org.serviio.delivery.resource.transcode.TranscodingDefinition;
import org.serviio.dlna.MediaFormatProfile;
import org.serviio.dlna.UnsupportedDLNAMediaFileFormatException;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.local.service.MediaService;
import org.serviio.library.online.AbstractUrlExtractor;
import org.serviio.library.online.ContentURLContainer;
import org.serviio.profile.DeliveryQuality;
import org.serviio.profile.Profile;
import org.serviio.delivery.resource.DeliveryEngine;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class AbstractDeliveryEngine(RI : MediaFormatProfileResource, MI : MediaItem)
  : DeliveryEngine!(RI, MI)
{
  protected immutable Logger log = LoggerFactory.getLogger!(AbstractDeliveryEngine);

  public List!(RI) getMediaInfoForProfile(MI mediaItem, Profile rendererProfile)
  {
    log.debug_(String.format("Retrieving resource information for item %s and profile %s", cast(Object[])[ mediaItem.getId(), rendererProfile.getName() ]));
    Map!(DeliveryQuality.QualityType, List!(RI)) infos = new LinkedHashMap!(DeliveryQuality.QualityType, List!(RI))();
    try
    {
      LinkedHashMap!(DeliveryQuality.QualityType, List!(RI)) originalMediaInfos = retrieveOriginalMediaInfo(mediaItem, rendererProfile);
      if (originalMediaInfos !is null) {
        infos.putAll(originalMediaInfos);
      }

    }
    catch (UnsupportedDLNAMediaFileFormatException e)
    {
    }

    if (fileCanBeTranscoded(mediaItem, rendererProfile)) {
      infos.putAll(retrieveTranscodedMediaInfo(mediaItem, rendererProfile, null));
    }
    return flattenMediaInfoMap(infos);
  }

  public DeliveryContainer deliver(MI mediaItem, MediaFormatProfile selectedVersion, DeliveryQuality.QualityType selectedQuality, Double timeOffsetInSeconds, Double durationInSeconds, Client client)
  {
    log.debug_(String.format("Delivering item '%s' for client '%s'", cast(Object[])[ mediaItem.getId(), client ]));
    if (fileWillBeTranscoded(mediaItem, selectedVersion, selectedQuality, client.getRendererProfile())) {
      log.debug_(String.format("Delivering file '%s' using transcoding", cast(Object[])[ mediaItem.getFileName() ]));
      return retrieveTranscodedResource(mediaItem, selectedVersion, selectedQuality, timeOffsetInSeconds, durationInSeconds, client);
    }
    log.debug_(String.format("Delivering file '%s' in native format", cast(Object[])[ mediaItem.getFileName() ]));
    return retrieveOriginalFileContainer(mediaItem, selectedVersion, client);
  }

  public RI getMediaInfoForMediaItem(MI mediaItem, MediaFormatProfile selectedVersion, DeliveryQuality.QualityType selectedQuality, Profile rendererProfile)
  {
    log.debug_(String.format("Retrieving resource information for item %s, format %s and profile %s", cast(Object[])[ mediaItem.getId(), selectedVersion, rendererProfile.getName() ]));
    if (fileWillBeTranscoded(mediaItem, selectedVersion, selectedQuality, rendererProfile)) {
      return retrieveTranscodedMediaInfoForVersion(mediaItem, selectedVersion, selectedQuality, rendererProfile);
    }
    LinkedHashMap!(DeliveryQuality.QualityType, List!(RI)) originalMediaInfos = retrieveOriginalMediaInfo(mediaItem, rendererProfile);
    return findMediaInfoForFileProfile(cast(Collection!(RI))originalMediaInfos.get(DeliveryQuality.QualityType.ORIGINAL), selectedVersion);
  }

  protected abstract bool fileCanBeTranscoded(MI paramMI, Profile paramProfile);

  protected abstract bool fileWillBeTranscoded(MI paramMI, MediaFormatProfile paramMediaFormatProfile, DeliveryQuality.QualityType paramQualityType, Profile paramProfile);

  protected abstract LinkedHashMap!(DeliveryQuality.QualityType, List!(RI)) retrieveOriginalMediaInfo(MI paramMI, Profile paramProfile);

  protected abstract LinkedHashMap!(DeliveryQuality.QualityType, List!(RI)) retrieveTranscodedMediaInfo(MI paramMI, Profile paramProfile, Long paramLong);

  protected abstract RI retrieveTranscodedMediaInfoForVersion(MI paramMI, MediaFormatProfile paramMediaFormatProfile, DeliveryQuality.QualityType paramQualityType, Profile paramProfile);

  protected abstract TranscodingDefinition getMatchingTranscodingDefinition(List!(TranscodingDefinition) paramList, MI paramMI);

  protected abstract DeliveryContainer retrieveTranscodedResource(MI paramMI, MediaFormatProfile paramMediaFormatProfile, DeliveryQuality.QualityType paramQualityType, Double paramDouble1, Double paramDouble2, Client paramClient);

  protected Map!(DeliveryQuality.QualityType, TranscodingDefinition) getMatchingTranscodingDefinitions(MI mediaItem, Profile rendererProfile)
  {
    Map!(DeliveryQuality.QualityType, TranscodingDefinition) defs = new LinkedHashMap!(DeliveryQuality.QualityType, TranscodingDefinition)();
    TranscodingDefinition defaultDefinition = getMatchingTransodingDefinitionForQuality(rendererProfile.getDefaultDeliveryQuality(), mediaItem);
    if (defaultDefinition !is null) {
      defs.put(DeliveryQuality.QualityType.ORIGINAL, defaultDefinition);
    }
    foreach (DeliveryQuality altQuality ; rendererProfile.getAlternativeDeliveryQualities()) {
      TranscodingDefinition def = getMatchingTransodingDefinitionForQuality(altQuality, mediaItem);
      if (def !is null) {
        defs.put(altQuality.getType(), def);
      }
    }
    return defs;
  }

  private TranscodingDefinition getMatchingTransodingDefinitionForQuality(DeliveryQuality quality, MI mediaItem)
  {
    List!(TranscodingDefinition) localTDefs = quality.getTranscodingConfiguration() !is null ? quality.getTranscodingConfiguration().getDefinitions(mediaItem.getFileType()) : null;
    List!(TranscodingDefinition) onlineTDefs = quality.getOnlineTranscodingConfiguration() !is null ? quality.getOnlineTranscodingConfiguration().getDefinitions(mediaItem.getFileType()) : null;
    TranscodingDefinition result = null;
    if (!mediaItem.isLocalMedia())
    {
      result = getMatchingTranscodingDefinition(onlineTDefs, mediaItem);
    }
    if (result is null)
    {
      result = getMatchingTranscodingDefinition(localTDefs, mediaItem);
    }
    return result;
  }

  
protected DeliveryContainer retrieveOriginalFileContainer(MI mediaItem, MediaFormatProfile selectedVersion, Client client)
  {
    InputStream fis = null;
    if (mediaItem.isLocalMedia()) {
      File file = MediaService.getFile(mediaItem.getId());
      fis = new FileInputStream(file);
    } else {
      fis = getOnlineInputStream(mediaItem);
    }
    LinkedHashMap!(DeliveryQuality.QualityType, List!(RI)) mediaInfos = retrieveOriginalMediaInfo(mediaItem, client.getRendererProfile());
    return new StreamDeliveryContainer(fis, findMediaInfoForFileProfile(cast(Collection!(RI))mediaInfos.get(DeliveryQuality.QualityType.ORIGINAL), selectedVersion)); 
  } 
  protected InputStream getOnlineInputStream(MI mediaItem)
  {
    try
    {
      int buffer = mediaItem.isLive() ? ApplicationSettings.getIntegerProperty("live_stream_buffer").intValue() : 1000000;
      return new BufferedInputStream(new OnlineInputStream(getOnlineItemURL(mediaItem), mediaItem.getFileSize(), !mediaItem.isLive()), buffer);
    } catch (MalformedURLException e) {}
    throw new FileNotFoundException(String.format("Cannot retrieve online media item URL: %s", mediaItem.getFilePath()));
  }
  
  
protected RI findMediaInfoForFileProfile(Collection!(RI) infos, MediaFormatProfile selectedVersion) { 
	  foreach (MediaFormatProfileResource mi ; infos) {
      if (mi.getFormatProfile() == selectedVersion) {
        return cast(RI) mi;
      }
    }
    throw new UnsupportedDLNAMediaFileFormatException(String.format("No media description available for required version: %s", cast(Object[])[ selectedVersion ]));
  }

  protected void updateFeedUrl(MI mediaItem)
  {
    if ((!mediaItem.isLocalMedia()) && (mediaItem.getOnlineResourcePlugin() !is null) && (mediaItem.getOnlineItem() !is null)) {
      log.debug_("Extracting new URL for the expired feed item");
      try
      {
        ContentURLContainer urlContainer = AbstractUrlExtractor.extractItemUrl(mediaItem.getOnlineResourcePlugin(), mediaItem.getOnlineItem());
        if (urlContainer !is null) {
          mediaItem.setFileName(urlContainer.getContentUrl());
          log.debug_("Successfully set new URL for the feed item");
        } else {
          log.warn("Cannot extract expired URL, using previous one which might not work");
        }
      } catch (Throwable t) {
        log.debug_(String.format("Unexpected error during url extractor plugin invocation (%s) for item %s: %s", cast(Object[])[ mediaItem.getOnlineResourcePlugin().getExtractorName(), mediaItem.getOnlineItem().getTitle(), t.getMessage() ]));
      }
    }
  }

  private URL getOnlineItemURL(MI mediaItem)
  {
    updateFeedUrl(mediaItem);
    return new URL(mediaItem.getFileName());
  }

  private List!(RI) flattenMediaInfoMap(Map!(DeliveryQuality.QualityType, List!(RI)) map) {
    List!(RI) result = new ArrayList!(RI)();
    foreach (Entry!(DeliveryQuality.QualityType, List!(RI)) entry ; map.entrySet()) {
      result.addAll(cast(Collection!(RI))entry.getValue());
    }
    return result;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.resource.AbstractDeliveryEngine
 * JD-Core Version:    0.6.2
 */