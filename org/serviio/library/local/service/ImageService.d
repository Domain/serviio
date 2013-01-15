module org.serviio.library.local.service.ImageService;

import java.io.File;
import java.util.List;
import org.serviio.config.Configuration;
import org.serviio.db.dao.DAOFactory;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Image;
import org.serviio.library.entities.MetadataDescriptor;
import org.serviio.library.entities.Repository;
import org.serviio.library.local.metadata.ImageDescriptor;
import org.serviio.library.local.metadata.ImageMetadata;
import org.serviio.library.local.metadata.extractor.MetadataFile;
import org.serviio.library.service.Service;
import org.serviio.util.ImageUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ImageService
  : Service
{
  private static final Logger log = LoggerFactory.getLogger!(ImageService)();

  public static void addImageToLibrary(ImageMetadata metadata, Repository repository)
  {
    Long mediaItemId;
    if (metadata !is null) {
      log.debug_(String.format("Adding image into database: %s", cast(Object[])[ metadata.getTitle() ]));

      Long folderId = FolderService.createOrReadFolder(repository, metadata.getFilePath());

      Long thumbnailId = createThumbnail(metadata);

      Image image = new Image(metadata.getTitle(), metadata.getContainer(), (new File(metadata.getFilePath())).getName(), metadata.getFilePath(), Long.valueOf(metadata.getFileSize()), folderId, repository.getId(), metadata.getDate());

      image.setWidth(metadata.getWidth());
      image.setHeight(metadata.getHeight());
      image.setColorDepth(metadata.getColorDepth());
      image.setDescription(metadata.getDescription());
      image.setThumbnailId(thumbnailId);
      image.setRotation(metadata.getExifRotation());
      image.setChromaSubsampling(metadata.getChromaSubsampling());

      mediaItemId = Long.valueOf(DAOFactory.getImageDAO().create(image));

      foreach (MetadataFile metadataFile ; metadata.getMetadataFiles()) {
        MetadataDescriptor metadataDescriptor = new MetadataDescriptor(metadataFile.getExtractorType(), mediaItemId, metadataFile.getLastUpdatedDate(), metadataFile.getIdentifier());

        DAOFactory.getMetadataDescriptorDAO().create(metadataDescriptor);
      }
    }
    else {
      log.warn("Image cannot be added to the library because no metadata has been provided");
    }
  }

  public static void removeImageFromLibrary(Long mediaItemId)
  {
    Image image = getImage(mediaItemId);
    if (image !is null) {
      log.debug_(String.format("Removing image from database: %s", cast(Object[])[ image.getTitle() ]));

      PlaylistService.removeMediaItemFromPlaylists(mediaItemId);

      DAOFactory.getMetadataDescriptorDAO().removeMetadataDescriptorsForMedia(mediaItemId);

      DAOFactory.getImageDAO().delete_(image.getId());

      FolderService.removeFolderAndItsParents(image.getFolderId());

      removeThumbnail(image);
    } else {
      log.warn("Image cannot be removed from the library because it cannot be found");
    }
  }

  public static void updateImageInLibrary(ImageMetadata metadata, Long mediaItemId)
  {
    if (metadata !is null) {
      log.debug_(String.format("Updating image in database: %s", cast(Object[])[ metadata.getTitle() ]));

      Image image = getImage(mediaItemId);

      Long thumbnailId = createThumbnail(metadata);

      Image updatedImage = new Image(metadata.getTitle(), metadata.getContainer(), image.getFileName(), metadata.getFilePath(), Long.valueOf(metadata.getFileSize()), image.getFolderId(), image.getRepositoryId(), metadata.getDate());

      updatedImage.setId(image.getId());
      updatedImage.setDescription(metadata.getDescription());
      updatedImage.setWidth(metadata.getWidth());
      updatedImage.setHeight(metadata.getHeight());
      updatedImage.setColorDepth(metadata.getColorDepth());
      updatedImage.setThumbnailId(thumbnailId);
      updatedImage.setRotation(metadata.getExifRotation());
      updatedImage.setChromaSubsampling(metadata.getChromaSubsampling());

      updatedImage.setDirty(false);

      DAOFactory.getImageDAO().update(updatedImage);

      DAOFactory.getMetadataDescriptorDAO().removeMetadataDescriptorsForMedia(mediaItemId);

      foreach (MetadataFile metadataFile ; metadata.getMetadataFiles()) {
        MetadataDescriptor metadataDescriptor = new MetadataDescriptor(metadataFile.getExtractorType(), mediaItemId, metadataFile.getLastUpdatedDate(), metadataFile.getIdentifier());

        DAOFactory.getMetadataDescriptorDAO().create(metadataDescriptor);
      }

      removeThumbnail(image);
    }
    else {
      log.warn("Image cannot be updated in the library because no metadata has been provided");
    }
  }

  public static Image getImage(Long imageId) {
    return cast(Image)DAOFactory.getImageDAO().read(imageId);
  }

  public static List!(Image) getListOfImagesForFolder(Long folderId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    return DAOFactory.getImageDAO().retrieveImagesForFolder(folderId, accessGroup, startingIndex, requestedCount);
  }

  public static int getNumberOfImagesForFolder(Long folderId, AccessGroup accessGroup)
  {
    return DAOFactory.getImageDAO().retrieveImagesForFolderCount(folderId, accessGroup);
  }

  public static List!(Image) getListOfImagesForPlaylist(Long playlistId, AccessGroup accessGroup, int startingIndex, int requestedCount) {
    return DAOFactory.getImageDAO().retrieveImagesForPlaylist(playlistId, accessGroup, startingIndex, requestedCount);
  }

  public static int getNumberOfImagesForPlaylist(Long playlistId, AccessGroup accessGroup) {
    return DAOFactory.getImageDAO().retrieveImagesForPlaylistCount(playlistId, accessGroup);
  }

  public static List!(Image) getListOfImagesForYear(Integer year, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    return DAOFactory.getImageDAO().retrieveImagesForYear(year, accessGroup, startingIndex, requestedCount);
  }

  public static int getNumberOfImagesForYear(Integer year, AccessGroup accessGroup)
  {
    return DAOFactory.getImageDAO().retrieveImagesForYearCount(year, accessGroup);
  }

  public static List!(Integer) getListOfImagesCreationYears(AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    return DAOFactory.getImageDAO().retrieveImagesCreationYears(accessGroup, startingIndex, requestedCount);
  }

  public static int getNumberOfImagesCreationYears(AccessGroup accessGroup)
  {
    return DAOFactory.getImageDAO().retrieveImagesCreationYearsCount(accessGroup);
  }

  public static List!(Integer) getListOfImagesCreationMonths(Integer year, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    return DAOFactory.getImageDAO().retrieveImagesCreationMonths(year, accessGroup, startingIndex, requestedCount);
  }

  public static int getNumberOfImagesCreationMonths(Integer year, AccessGroup accessGroup)
  {
    return DAOFactory.getImageDAO().retrieveImagesCreationMonthsCount(year, accessGroup);
  }

  public static List!(Image) getListOfImagesForMonthAndYear(Integer month, Integer year, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    return DAOFactory.getImageDAO().retrieveImagesForMonthOfYear(month, year, accessGroup, startingIndex, requestedCount);
  }

  public static int getNumberOfImagesForMonthAndYear(Integer month, Integer year, AccessGroup accessGroup)
  {
    return DAOFactory.getImageDAO().retrieveImagesForMonthOfYearCount(month, year, accessGroup);
  }

  public static List!(Image) getListOfAllImages(AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    return DAOFactory.getImageDAO().retrieveAllImages(accessGroup, startingIndex, requestedCount);
  }

  public static int getNumberOfAllImages(AccessGroup accessGroup)
  {
    return DAOFactory.getImageDAO().retrieveAllImagesCount(accessGroup);
  }

  private static void removeThumbnail(Image image)
  {
    if (image.getThumbnailId() !is null)
      DAOFactory.getCoverImageDAO().delete_(image.getThumbnailId());
  }

  private static Long createThumbnail(ImageMetadata metadata)
  {
    if (Configuration.isGenerateLocalThumbnailForImages()) {
      try {
        ImageDescriptor coverImage = metadata.getCoverImage();
        if (coverImage is null)
        {
          coverImage = ImageUtils.resizeImageAsJPG(new File(metadata.getFilePath()), 160, 160);
        }

        return CoverImageService.createCoverImage(coverImage, metadata.getExifRotation());
      } catch (Throwable e) {
        log.warn(String.format("Cannot convert image to JPG. Message: %s", cast(Object[])[ e.getMessage() ]));
        return null;
      }
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.service.ImageService
 * JD-Core Version:    0.6.2
 */