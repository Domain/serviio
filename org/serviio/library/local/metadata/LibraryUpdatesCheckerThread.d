module org.serviio.library.local.metadata.LibraryUpdatesCheckerThread;

import java.io.File;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import org.serviio.config.Configuration;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.entities.MetadataDescriptor;
import org.serviio.library.entities.Playlist;
import org.serviio.library.entities.Repository;
import org.serviio.library.local.LibraryManager;
import org.serviio.library.local.metadata.extractor.ExtractorType;
import org.serviio.library.local.metadata.extractor.MetadataExtractor;
import org.serviio.library.local.metadata.extractor.MetadataExtractorFactory;
import org.serviio.library.local.service.AudioService;
import org.serviio.library.local.service.ImageService;
import org.serviio.library.local.service.MediaService;
import org.serviio.library.local.service.PlaylistService;
import org.serviio.library.local.service.RepositoryService;
import org.serviio.library.local.service.VideoService;
import org.serviio.library.metadata.AbstractLibraryCheckerThread;
import org.serviio.library.metadata.InvalidMetadataException;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.util.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LibraryUpdatesCheckerThread : AbstractLibraryCheckerThread
{
  private static final int THREAD_SLEEP_PERIOD = 3600000;
  private static List!(ExtractorType) automaticExtractors = Arrays.asList(cast(ExtractorType[])[ ExtractorType.EMBEDDED, ExtractorType.COVER_IMAGE_IN_FOLDER, ExtractorType.MYMOVIES, ExtractorType.SWISSCENTER, ExtractorType.XBMC ]);

  private static final Logger log = LoggerFactory.getLogger!(LibraryUpdatesCheckerThread)();

  public void run()
  {
    log.info("Started looking for updates to currently shared files");
    workerRunning = true;
    while (workerRunning) {
      searchingForFiles = true;

      List!(Repository) repositories = RepositoryService.getAllRepositories();
      foreach (Repository repository ; repositories) {
        try
        {
          if ((workerRunning) && 
            (LibraryManager.getInstance().isRepositoryUpdatable(repository))) {
            searchForRemovedPlaylists(repository);
            searchForRemovedAndUpdatedFiles(repository);
          }
        }
        catch (Exception e) {
          log.warn("An error occured while scanning for items to be removed or updated, will continue", e);
        }
      }

      foreach (Repository repository ; repositories)
      {
        try
        {
          if ((workerRunning) && 
            (LibraryManager.getInstance().isRepositoryUpdatable(repository))) {
            updateMetadata(repository);
            RepositoryService.markRepositoryAsScanned(repository.getId());
          }
        }
        catch (Exception e) {
          log.warn("An error occured while updating metadata, will continue", e);
        }
      }
      searchingForFiles = false;
      if (Configuration.isAutomaticLibraryRefresh())
        try {
          if (workerRunning) {
            isSleeping = true;
            Thread.sleep(THREAD_SLEEP_PERIOD);
            isSleeping = false;
          }
        } catch (InterruptedException e) {
          isSleeping = false;
        }
      else {
        workerRunning = false;
      }
    }
    log.info("Finished looking for updates to currently shared files");
  }

  protected void searchForRemovedAndUpdatedFiles(Repository repository)
  {
    log.debug_(String.format("Looking for removed/updated files in repository: %s", cast(Object[])[ repository.getFolder() ]));

    List!(MediaItem) items = MediaService.getMediaItemsInRepository(repository.getId());
    Iterator!(MediaItem) itemsIt = items.iterator();
    while ((workerRunning) && (itemsIt.hasNext()))
    {
      MediaItem item = cast(MediaItem)itemsIt.next();

      File mediaFile = MediaService.getFile(item.getId());
      if ((mediaFile !is null) && (!mediaFile.exists())) {
        try {
          log.info(String.format("Removing '%s' (%s) from Library", cast(Object[])[ item.getTitle(), mediaFile.getPath() ]));

          if (item.getFileType() == MediaFileType.AUDIO)
          {
            AudioService.removeMusicTrackFromLibrary(item.getId());
          } else if (item.getFileType() == MediaFileType.VIDEO)
          {
            VideoService.removeVideoFromLibrary(item.getId());
          }
          else ImageService.removeImageFromLibrary(item.getId());

          notifyListenersRemove(mediaFile.getName());
        } catch (Exception e) {
          log.warn(String.format("Cannot remove item %s from Library. Message: %s", cast(Object[])[ item.getTitle(), e.getMessage() ]), e);
        }

      }
      else if (Configuration.isSearchUpdatedFiles())
        try {
          List!(MetadataExtractor) extractors = MetadataExtractorFactory.getInstance().getExtractors(item.getFileType());
          foreach (MetadataExtractor extractor ; extractors)
          {
            if ((workerRunning) && (automaticExtractors.contains(extractor.getExtractorType()))) {
              MetadataDescriptor descriptor = MediaService.getMetadataDescriptorForMediaItem(item.getId(), extractor.getExtractorType());
              if (extractor.isMetadataUpdated(mediaFile, item, descriptor))
              {
                MediaService.markMediaItemAsDirty(item.getId());
              }
            }
          }
        } catch (Exception e) {
          log.warn(String.format("Cannot search for updated metadata for title %s. Message: %s", cast(Object[])[ item.getTitle(), e.getMessage() ]), e);
        }
    }
  }

  protected void searchForRemovedPlaylists(Repository repository)
  {
    log.debug_(String.format("Looking for removed playlist files in repository: %s", cast(Object[])[ repository.getFolder() ]));

    List!(Playlist) playlists = PlaylistService.getPlaylistsInRepository(repository.getId());
    Iterator!(Playlist) playlistIt = playlists.iterator();
    while ((workerRunning) && (playlistIt.hasNext())) {
      Playlist playlist = cast(Playlist)playlistIt.next();

      File playlistFile = new File(playlist.getFilePath());
      if ((playlistFile !is null) && (!playlistFile.exists()))
        try {
          log.info(String.format("Removing playlist '%s' (%s) from Library", cast(Object[])[ playlist.getTitle(), FileUtils.getProperFilePath(playlistFile) ]));

          PlaylistService.detetePlaylistAndItems(playlist.getId());
          notifyListenersRemove(playlistFile.getName());
        } catch (Exception e) {
          log.warn(String.format("Cannot remove playlist %s from Library. Message: %s", cast(Object[])[ playlist.getTitle(), e.getMessage() ]), e);
        }
    }
  }

  protected void updateMetadata(Repository repository)
  {
    List!(MediaItem) mediaItems = MediaService.getDirtyMediaItemsInRepository(repository.getId());
    if (mediaItems.size() > 0) {
      log.debug_(String.format("Updating dirty metadata for repository: %s", cast(Object[])[ repository.getFolder() ]));
      Iterator!(MediaItem) mediaItemsIt = mediaItems.iterator();
      while ((workerRunning) && (mediaItemsIt.hasNext())) {
        MediaItem mediaItem = cast(MediaItem)mediaItemsIt.next();
        try {
          File mediaFile = MediaService.getFile(mediaItem.getId());
          if ((mediaFile !is null) && (mediaFile.exists())) {
            MediaFileType fileType = mediaItem.getFileType();

            LocalItemMetadata mergedMetadata = LibraryManager.getInstance().extractMetadata(mediaFile, fileType, repository);
            if ((mergedMetadata !is null) && (workerRunning))
            {
              mergedMetadata.validateMetadata();
              bool updated = false;

              if ((fileType == MediaFileType.AUDIO) && (( cast(AudioMetadata)mergedMetadata !is null ))) {
                AudioService.updateMusicTrackInLibrary(cast(AudioMetadata)mergedMetadata, mediaItem.getId());
                updated = true;
              } else if ((fileType == MediaFileType.VIDEO) && (( cast(VideoMetadata)mergedMetadata !is null ))) {
                VideoService.updateVideoInLibrary(cast(VideoMetadata)mergedMetadata, mediaItem.getId());
                updated = true;
              } else if ((fileType == MediaFileType.IMAGE) && (( cast(ImageMetadata)mergedMetadata !is null ))) {
                ImageService.updateImageInLibrary(cast(ImageMetadata)mergedMetadata, mediaItem.getId());
                updated = true;
              }
              else {
                log.error(String.format("Error during update metadata extraction for file %s. Metadata mismatch.", new Object[0]), mediaFile.getName());
              }
              if (updated) {
                log.info(String.format("Updated '%s' (%s) in Library", cast(Object[])[ mediaItem.getTitle(), mediaFile.getPath() ]));
                notifyListenersUpdate(mediaFile.getName());
              }
            }
          }
        } catch (InvalidMetadataException ime) {
          log.warn(String.format("Cannot update file %s in library because of invalid metadata. Message: %s", cast(Object[])[ mediaItem.getTitle(), ime.getMessage() ]));
        } catch (Exception e) {
          log.warn(String.format("Cannot update file %s in library because of an unexpected error. Message: %s", cast(Object[])[ mediaItem.getTitle(), e.getMessage() ]), e);
        }
      }
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.LibraryUpdatesCheckerThread
 * JD-Core Version:    0.6.2
 */