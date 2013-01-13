module org.serviio.delivery.SubtitlesRetrievalStrategy;

import java.lang.Long;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import org.serviio.dlna.MediaFormatProfile;
import org.serviio.dlna.UnsupportedDLNAMediaFileFormatException;
import org.serviio.library.local.service.SubtitlesService;
import org.serviio.profile.DeliveryQuality;
import org.serviio.util.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.serviio.delivery.ResourceRetrievalStrategy;

public class SubtitlesRetrievalStrategy
  : ResourceRetrievalStrategy
{
  private static immutable Logger log = LoggerFactory.getLogger!(SubtitlesRetrievalStrategy);

  public DeliveryContainer retrieveResource(Long mediaItemId, MediaFormatProfile selectedVersion, DeliveryQuality.QualityType selectedQuality, Double timeOffsetInSeconds, Double durationInSeconds, Client client, bool markAsRead)
  {
    File subtitleFile = SubtitlesService.findSubtitleFile(mediaItemId);
    if (subtitleFile is null) {
      throw new FileNotFoundException(String.format("Subtitle file for media item %s cannot be found", cast(Object[])[ mediaItemId ]));
    }

    log.debug_(String.format("Retrieving Subtitles for media item with id %s", cast(Object[])[ mediaItemId ]));

    ResourceInfo resourceInfo = retrieveResourceInfo(mediaItemId, subtitleFile, client);
    DeliveryContainer container = new StreamDeliveryContainer(new ByteArrayInputStream(FileUtils.readFileBytes(subtitleFile)), resourceInfo);
    return container;
  }

  public ResourceInfo retrieveResourceInfo(Long mediaItemId, MediaFormatProfile selectedVersion, DeliveryQuality.QualityType selectedQuality, Client client)
  {
    File subtitleFile = SubtitlesService.findSubtitleFile(mediaItemId);
    if (subtitleFile is null) {
      throw new FileNotFoundException(String.format("Subtitle file for media item %s cannot be found", cast(Object[])[ mediaItemId ]));
    }

    log.debug_(String.format("Retrieving info of Subtitles for media item with id %s", cast(Object[])[ mediaItemId ]));
    return retrieveResourceInfo(mediaItemId, subtitleFile, client);
  }

  private ResourceInfo retrieveResourceInfo(Long mediaItemId, File subtitleFile, Client client)
  {
    ResourceInfo resourceInfo = new SubtitlesInfo(mediaItemId, Long.valueOf(subtitleFile.length()), client.getRendererProfile().getSubtitlesMimeType());
    return resourceInfo;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.SubtitlesRetrievalStrategy
 * JD-Core Version:    0.6.2
 */