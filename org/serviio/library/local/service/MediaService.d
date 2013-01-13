module org.serviio.library.local.service.MediaService;

import java.io.File;
import java.util.List;
import org.serviio.db.dao.DAOFactory;
import org.serviio.library.entities.CoverImage;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.entities.MetadataDescriptor;
import org.serviio.library.entities.MetadataExtractorConfig;
import org.serviio.library.local.metadata.extractor.ExtractorType;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.library.service.Service;

public class MediaService
  : Service
{
  public static bool isMediaPresentInLibrary(File mediaFile)
  {
    return DAOFactory.getMediaItemDAO().isMediaItemPresent(mediaFile);
  }

  public static MediaItem getMediaItem(String filePath, bool ignoreCase) {
    return DAOFactory.getMediaItemDAO().getMediaItem(filePath, ignoreCase);
  }

  public static MediaItem readMediaItemById(Long id) {
    return DAOFactory.getMediaItemDAO().read(id);
  }

  public static File getFile(Long mediaItemId) {
    return DAOFactory.getMediaItemDAO().getFile(mediaItemId);
  }

  public static CoverImage getCoverImage(Long coverImageId) {
    return cast(CoverImage)DAOFactory.getCoverImageDAO().read(coverImageId);
  }

  public static void markMediaItemAsDirty(Long mediaItemId) {
    DAOFactory.getMediaItemDAO().markMediaItemAsDirty(mediaItemId);
  }

  public static void markMediaItemsAsDirty(MediaFileType fileType) {
    DAOFactory.getMediaItemDAO().markMediaItemsAsDirty(fileType);
  }

  public static void markMediaItemAsRead(Long mediaItemId) {
    DAOFactory.getMediaItemDAO().markMediaItemAsRead(mediaItemId);
  }

  public static void setMediaItemBookmark(Long mediaItemId, Integer seconds) {
    DAOFactory.getMediaItemDAO().setMediaItemBookmark(mediaItemId, seconds);
  }

  public static List!(MediaItem) getMediaItemsInRepository(Long repositoryId) {
    return DAOFactory.getMediaItemDAO().getMediaItemsInRepository(repositoryId);
  }

  public static List!(MediaItem) getMediaItemsInRepository(Long repositoryId, MediaFileType fileType) {
    return DAOFactory.getMediaItemDAO().getMediaItemsInRepository(repositoryId, fileType);
  }

  public static List!(MediaItem) getDirtyMediaItemsInRepository(Long repositoryId) {
    return DAOFactory.getMediaItemDAO().getDirtyMediaItemsInRepository(repositoryId);
  }

  public static MetadataDescriptor getMetadataDescriptorForMediaItem(Long mediaItemId, ExtractorType extractorType) {
    return DAOFactory.getMetadataDescriptorDAO().retrieveMetadataDescriptorForMedia(mediaItemId, extractorType);
  }

  public static List!(MetadataExtractorConfig) getMetadataExtractorConfigs(MediaFileType fileType) {
    return DAOFactory.getMetadataExtractorConfigDAO().retrieveByMediaFileType(fileType);
  }

  public static bool updateMetadataExtractorConfigs(List!(ExtractorType) extractors, MediaFileType fileType)
  {
    List!(MetadataExtractorConfig) existingConfigs = getMetadataExtractorConfigs(fileType);

    bool updateNecessary = false;

    if (extractors.size() == existingConfigs.size()) {
      foreach (MetadataExtractorConfig existingConfig ; existingConfigs) {
        if (!extractors.contains(existingConfig.getExtractorType()))
          updateNecessary = true;
      }
    }
    else {
      updateNecessary = true;
    }

    if (updateNecessary)
    {
      foreach (MetadataExtractorConfig config ; existingConfigs) {
        DAOFactory.getMetadataExtractorConfigDAO().delete_(config.getId());
      }

      foreach (ExtractorType extractor ; extractors) {
        MetadataExtractorConfig newConfig = new MetadataExtractorConfig(fileType, extractor, extractor.getDefaultPriority());
        DAOFactory.getMetadataExtractorConfigDAO().create(newConfig);
      }
    }
    return updateNecessary;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.service.MediaService
 * JD-Core Version:    0.6.2
 */