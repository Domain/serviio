module org.serviio.delivery.CoverImageRetrievalStrategy;

import java.lang.Long;
import java.lang.String;
import java.io.ByteArrayInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import org.serviio.dlna.MediaFormatProfile;
import org.serviio.dlna.UnsupportedDLNAMediaFileFormatException;
import org.serviio.library.entities.CoverImage;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.local.service.MediaService;
import org.serviio.library.online.OnlineItemService;
import org.serviio.profile.DeliveryQuality : QualityType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.serviio.delivery.ResourceRetrievalStrategy;

public class CoverImageRetrievalStrategy
  : ResourceRetrievalStrategy
{
  private static immutable Logger log = LoggerFactory.getLogger!(CoverImageRetrievalStrategy);

  public DeliveryContainer retrieveResource(Long coverImageId, MediaFormatProfile selectedVersion, QualityType selectedQuality, Double timeOffsetInSeconds, Double durationInSeconds, Client client, bool markAsRead)
  {
    CoverImage coverImage = retrieveCoverImage(coverImageId);

    log.debug_(String.format("Retrieving Cover image with id %s", cast(Object[])[ coverImageId ]));

    ResourceInfo resourceInfo = retrieveResourceInfo(coverImage, selectedVersion, client);
    DeliveryContainer container = new StreamDeliveryContainer(new ByteArrayInputStream(coverImage.getImageBytes()), resourceInfo);
    return container;
  }

  public ResourceInfo retrieveResourceInfo(Long coverImageId, MediaFormatProfile selectedVersion, QualityType selectedQuality, Client client)
  {
    CoverImage coverImage = retrieveCoverImage(coverImageId);

    log.debug_(String.format("Retrieving info of Cover image with id %s", cast(Object[])[ coverImageId ]));
    return retrieveResourceInfo(coverImage, selectedVersion, client);
  }

  private ResourceInfo retrieveResourceInfo(CoverImage coverImage, MediaFormatProfile selectedVersion, Client client)
  {
    Long fileSize = new Long(coverImage.getImageBytes().length);

    ResourceInfo resourceInfo = new ImageMediaInfo(coverImage.getId(), MediaFormatProfile.JPEG_TN, fileSize, Integer.valueOf(coverImage.getWidth()), Integer.valueOf(coverImage.getHeight()), false, coverImage.getMimeType(), QualityType.ORIGINAL);

    return resourceInfo;
  }

  private CoverImage retrieveCoverImage(Long resourceId) {
    if (MediaItem.isLocalMedia(resourceId)) {
      CoverImage coverImage = MediaService.getCoverImage(resourceId);
      if (coverImage is null) {
        throw new FileNotFoundException(String.format("Cover image %s cannot be found", cast(Object[])[ resourceId ]));
      }
      return coverImage;
    }

    CoverImage coverImage = OnlineItemService.findThumbnail(resourceId);
    if (coverImage is null)
    {
      throw new FileNotFoundException(String.format("Cover image for feed item %s cannot be found", cast(Object[])[ resourceId ]));
    }
    return coverImage;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.CoverImageRetrievalStrategy
 * JD-Core Version:    0.6.2
 */