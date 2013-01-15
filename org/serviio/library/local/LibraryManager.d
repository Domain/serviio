module org.serviio.library.local.LibraryManager;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import org.serviio.config.Configuration;
import org.serviio.library.AbstractLibraryManager;
import org.serviio.library.entities.Repository;
import org.serviio.library.local.metadata.CDSLibraryIndexingListener;
import org.serviio.library.local.metadata.LibraryAdditionsCheckerThread;
import org.serviio.library.local.metadata.LibraryUpdatesCheckerThread;
import org.serviio.library.local.metadata.LocalItemMetadata;
import org.serviio.library.local.metadata.MetadataFactory;
import org.serviio.library.local.metadata.PlaylistMaintainerThread;
import org.serviio.library.local.metadata.extractor.ExtractorType;
import org.serviio.library.local.metadata.extractor.InvalidMediaFormatException;
import org.serviio.library.local.metadata.extractor.MetadataExtractor;
import org.serviio.library.local.metadata.extractor.MetadataExtractorFactory;
import org.serviio.library.local.metadata.extractor.video.OnlineVideoSourcesMetadataExtractor;
import org.serviio.library.local.service.MediaService;
import org.serviio.library.metadata.MediaFileType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LibraryManager : AbstractLibraryManager
{
  private static final Logger log = LoggerFactory.getLogger!(LibraryManager)();
  private static LibraryManager instance;
  private LibraryUpdatesCheckerThread libraryUpdatesCheckerThread;
  private LibraryAdditionsCheckerThread libraryAdditionsCheckerThread;
  private PlaylistMaintainerThread playlistMaintainerThread;
  private bool updatePaused = false;

  public static LibraryManager getInstance()
  {
    if (instance is null) {
      instance = new LibraryManager();
    }
    return instance;
  }

  private this()
  {
    cdsListener = new CDSLibraryIndexingListener();
  }

  public synchronized void startLibraryUpdatesCheckerThread()
  {
    if (((libraryUpdatesCheckerThread is null) || ((libraryUpdatesCheckerThread !is null) && (!libraryUpdatesCheckerThread.isWorkerRunning()))) && 
      (!updatePaused)) {
      libraryUpdatesCheckerThread = new LibraryUpdatesCheckerThread();
      libraryUpdatesCheckerThread.setName("LibraryUpdatesCheckerThread");
      libraryUpdatesCheckerThread.setDaemon(true);
      libraryUpdatesCheckerThread.setPriority(1);
      libraryUpdatesCheckerThread.addListener(cdsListener);
      libraryUpdatesCheckerThread.start();
    }
  }

  public synchronized void startLibraryAdditionsCheckerThread()
  {
    if (((libraryAdditionsCheckerThread is null) || ((libraryAdditionsCheckerThread !is null) && (!libraryAdditionsCheckerThread.isWorkerRunning()))) && 
      (!updatePaused)) {
      libraryAdditionsCheckerThread = new LibraryAdditionsCheckerThread();
      libraryAdditionsCheckerThread.setName("LibraryAdditionsCheckerThread");
      libraryAdditionsCheckerThread.setDaemon(true);
      libraryAdditionsCheckerThread.setPriority(2);
      libraryAdditionsCheckerThread.addListener(cdsListener);
      libraryAdditionsCheckerThread.start();
    }
  }

  public synchronized void startPlaylistMaintainerThread()
  {
    if (((playlistMaintainerThread is null) || ((playlistMaintainerThread !is null) && (!playlistMaintainerThread.isWorkerRunning()))) && 
      (!updatePaused)) {
      playlistMaintainerThread = new PlaylistMaintainerThread();
      playlistMaintainerThread.setName("PlaylistMaintainerThread");
      playlistMaintainerThread.setDaemon(true);
      playlistMaintainerThread.setPriority(2);
      playlistMaintainerThread.addListener(cdsListener);
      playlistMaintainerThread.start();
    }
  }

  public synchronized void stopLibraryUpdatesCheckerThread()
  {
    stopThread(libraryUpdatesCheckerThread);
    libraryUpdatesCheckerThread = null;
  }

  public synchronized void stopLibraryAdditionsCheckerThread()
  {
    stopThread(libraryAdditionsCheckerThread);
    libraryAdditionsCheckerThread = null;
  }

  public synchronized void stopPlaylistMaintainerThread()
  {
    stopThread(playlistMaintainerThread);
    playlistMaintainerThread = null;
  }

  public synchronized void pauseUpdates()
  {
    updatePaused = true;
    stopLibraryAdditionsCheckerThread();
    stopLibraryUpdatesCheckerThread();
    stopPlaylistMaintainerThread();
  }

  public synchronized void resumeUpdates()
  {
    updatePaused = false;
    if (Configuration.isAutomaticLibraryRefresh()) {
      startLibraryAdditionsCheckerThread();
      startLibraryUpdatesCheckerThread();
    }
    startPlaylistMaintainerThread();
  }

  public bool isAdditionsInProcess()
  {
    return (libraryAdditionsCheckerThread !is null) && (libraryAdditionsCheckerThread.isSearchingForFiles());
  }

  public bool isUpdatesInProcess()
  {
    return (libraryUpdatesCheckerThread !is null) && (libraryUpdatesCheckerThread.isSearchingForFiles());
  }

  public String getLastAddedFileName() {
    return (cast(CDSLibraryIndexingListener)cdsListener).getLastAddedFile();
  }

  public Integer getNumberOfRecentlyAddedFiles() {
    return Integer.valueOf((cast(CDSLibraryIndexingListener)cdsListener).getNumberOfAddedFiles());
  }

  public LocalItemMetadata extractMetadata(File mediaFile, MediaFileType fileType, Repository repository)
  {
    List!(MetadataExtractor) extractors = MetadataExtractorFactory.getInstance().getExtractors(fileType);

    List!(LocalItemMetadata) metadataList = new ArrayList!(LocalItemMetadata)(extractors.size());
    try {
      foreach (MetadataExtractor extractor ; extractors) {
        try {
          if (isExtractorSupportedByRepository(extractor, repository)) {
            LocalItemMetadata metadata = extractor.extract(mediaFile, fileType, repository);
            if (metadata !is null) {
              log.debug_(String.format("Metadata found via extractor %s: %s", cast(Object[])[ extractor.getExtractorType(), metadata.toString() ]));
              metadataList.add(metadata);
            }
          }
        } catch (IOException e) {
          log.warn(String.format("Cannot read metadata of file %s via extractor %s. Message: %s", cast(Object[])[ mediaFile.getPath(), extractor.getExtractorType(), e.getMessage() ]));

          if (extractor.getExtractorType() == ExtractorType.EMBEDDED)
          {
            return null;
          }
        }
      }
      return mergeMetadata(metadataList, fileType);
    }
    catch (InvalidMediaFormatException e) {
      log.debug_(String.format("Skipping processing metadata for an unsupported file. Message: %s", cast(Object[])[ e.getMessage() ]));
    }
    return null;
  }

  public void forceMetadataUpdate(MediaFileType fileType)
  {
    log.info(String.format("Forcing metadata update for '%s' media files", cast(Object[])[ fileType ]));
    MediaService.markMediaItemsAsDirty(fileType);
  }

  public bool isRepositoryUpdatable(Repository rep)
  {
    if (rep.getLastScanned() is null)
    {
      return true;
    }
    if (rep.isKeepScanningForUpdates()) {
      return true;
    }
    return false;
  }

  protected LocalItemMetadata mergeMetadata(List!(LocalItemMetadata) metadataList, MediaFileType fileType)
  {
    LocalItemMetadata mergedMetadata = MetadataFactory.getMetadataInstance(fileType);

    Collections.reverse(metadataList);
    foreach (LocalItemMetadata metadata ; metadataList) {
      mergedMetadata.merge(metadata);
    }

    mergedMetadata.fillInUnknownEntries();

    return mergedMetadata;
  }

  private bool isExtractorSupportedByRepository(MetadataExtractor extractor, Repository repository)
  {
    if (( cast(OnlineVideoSourcesMetadataExtractor)extractor !is null )) {
      if (repository.isSupportsOnlineMetadata()) {
        return true;
      }
      return false;
    }

    return true;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.LibraryManager
 * JD-Core Version:    0.6.2
 */