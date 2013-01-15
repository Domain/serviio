module org.serviio.delivery.resource.ImageDeliveryEngine;

import java.awt.Dimension;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import org.serviio.delivery.Client;
import org.serviio.delivery.DeliveryContainer;
import org.serviio.delivery.ImageMediaInfo;
import org.serviio.delivery.StreamDeliveryContainer;
import org.serviio.delivery.resource.transcode.ImageTranscodingDefinition;
import org.serviio.delivery.resource.transcode.ImageTranscodingMatch;
import org.serviio.delivery.resource.transcode.ImageTranscodingProfilesProvider;
import org.serviio.delivery.resource.transcode.TranscodingCache;
import org.serviio.delivery.resource.transcode.TranscodingDefinition;
import org.serviio.dlna.ImageContainer;
import org.serviio.dlna.MediaFormatProfile;
import org.serviio.dlna.MediaFormatProfileResolver;
import org.serviio.dlna.UnsupportedDLNAMediaFileFormatException;
import org.serviio.external.DCRawWrapper;
import org.serviio.library.entities.Image;
import org.serviio.library.local.service.MediaService;
import org.serviio.profile.DeliveryQuality;
import org.serviio.profile.Profile;
import org.serviio.util.FileUtils;
import org.serviio.util.ImageUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ImageDeliveryEngine : AbstractDeliveryEngine!(ImageMediaInfo, Image)
{
  private static immutable Logger log = LoggerFactory.getLogger!(ImageDeliveryEngine)();

  private static immutable List!(MediaFormatProfile) JPEG_PROFILES = Arrays.asList(cast(MediaFormatProfile[])[ MediaFormatProfile.JPEG_LRG, MediaFormatProfile.JPEG_MED, MediaFormatProfile.JPEG_SM ]);

  private static TranscodingCache transcodingCache = new TranscodingCache();
  private static ImageDeliveryEngine instance;

  public static ImageDeliveryEngine getInstance()
  {
    if (instance is null) {
      instance = new ImageDeliveryEngine();
    }
    return instance;
  }

  protected LinkedHashMap!(DeliveryQuality.QualityType, List!(ImageMediaInfo)) retrieveTranscodedMediaInfo(Image mediaItem, Profile rendererProfile, Long fileSize)
  {
    log.debug_(String.format("Getting media info for transcoded versions of file %s", cast(Object[])[ mediaItem.getFileName() ]));
    LinkedHashMap!(DeliveryQuality.QualityType, List!(ImageMediaInfo)) resourceInfos = new LinkedHashMap!(DeliveryQuality.QualityType, List!(ImageMediaInfo))();
    try
    {
      bool originalWillBeTransformed = imageWillBeTransformed(mediaItem, rendererProfile, DeliveryQuality.QualityType.ORIGINAL);

      if (originalWillBeTransformed) {
        try
        {
          resourceInfos.put(getQualityType(MediaFormatProfile.JPEG_LRG), Collections.singletonList(createTranscodedImageInfoForProfile(mediaItem, MediaFormatProfile.JPEG_LRG, null, rendererProfile)));
        } catch (UnsupportedDLNAMediaFileFormatException ex) {
          log.warn(String.format("Cannot get media info for resized original file %s: %s", cast(Object[])[ mediaItem.getFileName(), ex.getMessage() ]));
        }
      }

      List!(MediaFormatProfile) fileProfiles = MediaFormatProfileResolver.resolve(mediaItem);
      List!(MediaFormatProfile) optionalProfiles = ImageTranscodingProfilesProvider.getAvailableTranscodingProfiles(fileProfiles);
      if ((optionalProfiles !is null) && (imageIsResizable(mediaItem)))
        foreach (MediaFormatProfile targetProfile ; optionalProfiles)
          if ((!originalWillBeTransformed) || ((originalWillBeTransformed) && (targetProfile != MediaFormatProfile.JPEG_LRG)))
            try
            {
              resourceInfos.put(getQualityType(targetProfile), Collections.singletonList(createTranscodedImageInfoForProfile(mediaItem, targetProfile, fileSize, rendererProfile)));
            } catch (UnsupportedDLNAMediaFileFormatException ex) {
              log.warn(String.format("Cannot get media info for transcoded file %s: %s", cast(Object[])[ mediaItem.getFileName(), ex.getMessage() ]));
            }
    }
    catch (UnsupportedDLNAMediaFileFormatException ex1)
    {
      log.warn(String.format("Unknown DLNA format profile of file %s: %s", cast(Object[])[ mediaItem.getFileName(), ex1.getMessage() ]));
    }
    return resourceInfos;
  }

  protected ImageMediaInfo retrieveTranscodedMediaInfoForVersion(Image mediaItem, MediaFormatProfile selectedVersion, DeliveryQuality.QualityType selectedQuality, Profile rendererProfile)
  {
    log.debug_(String.format("Getting media info for transcoded version of file %s", cast(Object[])[ mediaItem.getFileName() ]));
    return createTranscodedImageInfoForProfile(mediaItem, selectedVersion, null, rendererProfile);
  }

  protected DeliveryContainer retrieveTranscodedResource(Image mediaItem, MediaFormatProfile selectedVersion, DeliveryQuality.QualityType selectedQuality, Double timeOffsetInSeconds, Double durationInSeconds, Client client)
  {
    log.debug_(String.format("Retrieving transcoded version of file %s using format profile %s", cast(Object[])[ mediaItem.getFileName(), selectedVersion ]));
    byte[] transcodedImageBytes = null;
    synchronized (transcodingCache) {
      if (transcodingCache.isInCache(mediaItem.getId(), selectedVersion)) {
        transcodedImageBytes = transcodingCache.getCachedBytes();
      } else {
        transcodedImageBytes = transcodeImage(mediaItem, selectedVersion, client.getRendererProfile());
        transcodingCache.storeInCache(mediaItem.getId(), selectedVersion, transcodedImageBytes);
      }
    }
    DeliveryContainer container = new StreamDeliveryContainer(new ByteArrayInputStream(transcodedImageBytes), createTranscodedImageInfoForProfile(mediaItem, selectedVersion, Long.valueOf(transcodedImageBytes.length), client.getRendererProfile()));

    return container;
  }

  protected bool fileCanBeTranscoded(Image mediaItem, Profile rendererProfile)
  {
    return imageIsResizable(mediaItem);
  }

  protected bool fileWillBeTranscoded(Image mediaItem, MediaFormatProfile selectedVersion, DeliveryQuality.QualityType selectedQuality, Profile rendererProfile)
  {
    List!(MediaFormatProfile) fileProfiles = MediaFormatProfileResolver.resolve(mediaItem);

    bool imageWillBeTransformed = imageWillBeTransformed(mediaItem, rendererProfile, selectedQuality);

    if ((selectedVersion is null) || (fileProfiles.contains(selectedVersion))) {
      if (!imageWillBeTransformed) {
        return false;
      }
      return true;
    }

    List!(MediaFormatProfile) optionalProfiles = ImageTranscodingProfilesProvider.getAvailableTranscodingProfiles(fileProfiles);
    if ((optionalProfiles !is null) && (optionalProfiles.size() > 0)) {
      return true;
    }
    return false;
  }

  protected LinkedHashMap!(DeliveryQuality.QualityType, List!(ImageMediaInfo)) retrieveOriginalMediaInfo(Image image, Profile rendererProfile)
  {
    if (!transcodeNeeded(image, rendererProfile, DeliveryQuality.QualityType.ORIGINAL))
    {
      if (imageWillRotate(image, rendererProfile, false))
      {
        return null;
      }
      List!(MediaFormatProfile) fileProfiles = MediaFormatProfileResolver.resolve(image);
      LinkedHashMap!(DeliveryQuality.QualityType, List!(ImageMediaInfo)) result = new LinkedHashMap!(DeliveryQuality.QualityType, List!(ImageMediaInfo))();
      foreach (MediaFormatProfile fileProfile ; fileProfiles) {
        result.put(DeliveryQuality.QualityType.ORIGINAL, Collections.singletonList(new ImageMediaInfo(image.getId(), fileProfile, image.getFileSize(), image.getWidth(), image.getHeight(), false, rendererProfile.getMimeType(fileProfile), DeliveryQuality.QualityType.ORIGINAL)));
      }

      return result;
    }

    return null;
  }

  protected TranscodingDefinition getMatchingTranscodingDefinition(List!(TranscodingDefinition) tDefs, Image mediaItem)
  {
    Iterator!(TranscodingDefinition) i;
    if ((tDefs !is null) && (tDefs.size() > 0))
      for (i = tDefs.iterator(); i.hasNext(); ) { TranscodingDefinition tDef = cast(TranscodingDefinition)i.next();
        List!(ImageTranscodingMatch) matches = (cast(ImageTranscodingDefinition)tDef).getMatches();
        foreach (ImageTranscodingMatch match ; matches)
          if (match.matches(mediaItem.getContainer(), mediaItem.getChromaSubsampling()))
            return cast(ImageTranscodingDefinition)tDef;
      }
    return null;
  }

  private bool imageWillBeTransformed(Image mediaItem, Profile rendererProfile, DeliveryQuality.QualityType quality)
  {
    bool originalTranscoded = transcodeNeeded(mediaItem, rendererProfile, quality);
    bool imageRotated = imageWillRotate(mediaItem, rendererProfile, originalTranscoded);
    return (originalTranscoded) || (imageRotated);
  }

  private ImageMediaInfo createTranscodedImageInfoForProfile(Image originalImage, MediaFormatProfile selectedVersion, Long fileSize, Profile rendererProfile)
  {
    if (isTranscodingValid(originalImage, selectedVersion))
    {
      int maxWidth = 0;
      int maxHeight = 0;
      DeliveryQuality.QualityType quality = getQualityType(selectedVersion);
      if (selectedVersion == MediaFormatProfile.JPEG_SM) {
        maxWidth = 640;
        maxHeight = 480;
      } else if (selectedVersion == MediaFormatProfile.JPEG_MED) {
        maxWidth = 1024;
        maxHeight = 768;
      }
      else {
        maxWidth = 4096;
        maxHeight = 4096;
      }

      Dimension newDimension = ImageUtils.getResizedDimensions(originalImage.getWidth().intValue(), originalImage.getHeight().intValue(), maxWidth, maxHeight);
      if (imageWillRotate(originalImage, rendererProfile, true)) {
        return new ImageMediaInfo(originalImage.getId(), selectedVersion, null, Integer.valueOf(cast(int)newDimension.getHeight()), Integer.valueOf(cast(int)newDimension.getWidth()), true, rendererProfile.getMimeType(selectedVersion), quality);
      }

      return new ImageMediaInfo(originalImage.getId(), selectedVersion, fileSize, Integer.valueOf(cast(int)newDimension.getWidth()), Integer.valueOf(cast(int)newDimension.getHeight()), true, rendererProfile.getMimeType(selectedVersion), quality);
    }

    throw new UnsupportedDLNAMediaFileFormatException("Images can only be transformed to JPEG continer");
  }

  private DeliveryQuality.QualityType getQualityType(MediaFormatProfile mediaFormatProfile)
  {
    if (mediaFormatProfile == MediaFormatProfile.JPEG_SM)
      return DeliveryQuality.QualityType.LOW;
    if (mediaFormatProfile == MediaFormatProfile.JPEG_MED) {
      return DeliveryQuality.QualityType.MEDIUM;
    }

    return DeliveryQuality.QualityType.ORIGINAL;
  }

  private byte[] transcodeImage(Image originalImage, MediaFormatProfile selectedVersion, Profile rendererProfile)
  {
    byte[] originalImageBytes = getImageBytes(originalImage);
    if (isTranscodingValid(originalImage, selectedVersion)) {
      try
      {
        byte[] transcodedImage = null;
        if (selectedVersion == MediaFormatProfile.JPEG_SM)
          transcodedImage = ImageUtils.resizeImageAsJPG(originalImageBytes, 640, 480).getImageData();
        else if (selectedVersion == MediaFormatProfile.JPEG_MED)
          transcodedImage = ImageUtils.resizeImageAsJPG(originalImageBytes, 1024, 768).getImageData();
        else if (selectedVersion == MediaFormatProfile.JPEG_LRG)
          transcodedImage = ImageUtils.resizeImageAsJPG(originalImageBytes, 4096, 4096).getImageData();
        else {
          throw new UnsupportedDLNAMediaFileFormatException(String.format("Unsupported transcoding profile requested: %s", cast(Object[])[ selectedVersion.toString() ]));
        }
        if (imageWillRotate(originalImage, rendererProfile, true))
		{
		}
        return ImageUtils.rotateImage(transcodedImage, originalImage.getRotation().intValue()).getImageData();
      }
      catch (Throwable e)
      {
        throw new IOException("Cannot transcode image: " + e.getMessage(), e);
      }
    }
    throw new UnsupportedDLNAMediaFileFormatException("Only JPEG can be usedas a target container for image trancoding at the moment");
  }

  private byte[] getImageBytes(Image image)
  {
    try {
      if (image.isLocalMedia()) {
        File imageFile = MediaService.getFile(image.getId());
        if (image.getContainer() == ImageContainer.RAW) {
          return DCRawWrapper.retrieveThumbnailFromRawFile(FileUtils.getProperFilePath(imageFile));
        }
        return FileUtils.readFileBytes(imageFile);
      }

      InputStream onlineStream = getOnlineInputStream(image);
      return FileUtils.readFileBytes(onlineStream);
    }
    catch (Exception e) {
      throw new RuntimeException(e);
    }
  }

  private bool transcodeNeeded(Image image, Profile rendererProfile, DeliveryQuality.QualityType quality)
  {
    if (getMatchingTranscodingDefinitions(image, rendererProfile).get(quality) !is null) {
      return true;
    }
    if ((imageIsResizable(image)) && 
      (rendererProfile.isLimitImageResolution())) {
      if (image.getContainer() == ImageContainer.JPEG) {
        if ((image.getWidth().intValue() <= 4096) && (image.getHeight().intValue() <= 4096)) {
          return false;
        }
        return true;
      }
      if (image.getContainer() == ImageContainer.PNG) {
        if ((image.getWidth().intValue() <= 4096) && (image.getHeight().intValue() <= 4096)) {
          return false;
        }
        return true;
      }
      if (image.getContainer() == ImageContainer.GIF) {
        if ((image.getWidth().intValue() <= 1600) && (image.getHeight().intValue() <= 1200)) {
          return false;
        }
        return true;
      }

      return false;
    }

    return false;
  }

  private bool imageWillRotate(Image image, Profile profile, bool willBeResized)
  {
    if ((image.getRotation() !is null) && (!image.getRotation().equals(new Integer(0))) && ((profile.isAutomaticImageRotation()) || (willBeResized))) {
      return true;
    }
    return false;
  }

  private bool isTranscodingValid(Image originalImage, MediaFormatProfile targetFormat)
  {
    return ((originalImage.getContainer() == ImageContainer.JPEG) || (originalImage.getContainer() == ImageContainer.PNG) || (originalImage.getContainer() == ImageContainer.GIF) || (originalImage.getContainer() == ImageContainer.RAW)) && (JPEG_PROFILES.contains(targetFormat));
  }

  private bool imageIsResizable(Image image)
  {
    if ((image.getWidth() is null) || (image.getHeight() is null))
    {
      return false;
    }
    return true;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.resource.ImageDeliveryEngine
 * JD-Core Version:    0.6.2
 */