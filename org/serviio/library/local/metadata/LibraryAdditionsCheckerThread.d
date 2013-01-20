module org.serviio.library.local.metadata.LibraryAdditionsCheckerThread;

import java.io.File;
import java.io.IOException;
import java.util.List;
import org.serviio.config.Configuration;
import org.serviio.library.entities.Repository;
import org.serviio.library.local.LibraryManager;
import org.serviio.library.local.service.AudioService;
import org.serviio.library.local.service.ImageService;
import org.serviio.library.local.service.MediaService;
import org.serviio.library.local.service.PlaylistService;
import org.serviio.library.local.service.RepositoryService;
import org.serviio.library.local.service.VideoService;
import org.serviio.library.metadata.AbstractLibraryCheckerThread;
import org.serviio.library.metadata.InvalidMetadataException;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.library.playlist.CannotParsePlaylistException;
import org.serviio.library.playlist.ParsedPlaylist;
import org.serviio.library.playlist.PlaylistParser;
import org.serviio.library.playlist.PlaylistType;
import org.serviio.util.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LibraryAdditionsCheckerThread : AbstractLibraryCheckerThread
{
    private static immutable Logger log;

    static this()
    {
        log = LoggerFactory.getLogger!(LibraryAdditionsCheckerThread)();
    }

    override public void run()
    {
        log.info("Started looking for newly added files");
        workerRunning = true;
        while (workerRunning) {
            searchingForFiles = true;

            notifyListenersResetForAdding();

            List!(Repository) repositories = RepositoryService.getAllRepositories();

            foreach (Repository repository ; repositories) {
                try
                {
                    if ((workerRunning) && 
                        (LibraryManager.getInstance().isRepositoryUpdatable(repository))) {
                            searchForNewFiles(repository.getFolder(), repository);
                            RepositoryService.markRepositoryAsScanned(repository.getId());
                        }
                }
                catch (Exception e) {
                    log.warn("An error occured while scanning for item to be added, will continue", e);
                }
            }

            searchingForFiles = false;

            if (Configuration.isAutomaticLibraryRefresh())
                try {
                    if (workerRunning) {
                        isSleeping = true;
                        Thread.sleep(Configuration.getAutomaticLibraryRefreshInterval().intValue() * 60 * 1000);
                        isSleeping = false;
                    }
                } catch (InterruptedException e) {
                    isSleeping = false;
                }
            else {
                workerRunning = false;
            }
        }
        log.info("Finished looking for newly added files");
    }

    protected void searchForNewFiles(File folder, Repository repository)
    {
        bool searchHidden = Configuration.isSearchHiddenFiles();

        if (workerRunning)
            if ((folder.isDirectory()) && (folder.canRead())) {
                log.debug_(String.format("Looking for files to share in folder: %s", cast(Object[])[ folder.getAbsolutePath() ]));
                File[] files = folder.listFiles();
                int i = 0;
                while ((workerRunning) && (files !is null) && (i < files.length)) {
                    File file = files[(i++)];
                    if (file.isDirectory()) {
                        if (fileIsVisible(searchHidden, file))
                        {
                            searchForNewFiles(file, repository);
                        }
                    }
                    else
                        try {
                            if (fileIsVisible(searchHidden, file)) {
                                String fileExtension = FileUtils.getFileExtension(file);
                                MediaFileType fileType = MediaFileType.findMediaFileTypeByExtension(fileExtension);
                                if ((fileType !is null) && (repository.getSupportedFileTypes().contains(fileType)))
                                {
                                    addNewMediaFile(repository, file, fileType);
                                } else if (fileType is null)
                                {
                                    if (PlaylistType.playlistTypeExtensionSupported(fileExtension))
                                        addNewPlaylistFile(repository, file);
                                }
                            }
                        }
                    catch (InvalidMetadataException ime) {
                        log.warn(String.format("Cannot add file %s because of invalid metadata. Message: %s", cast(Object[])[ file.getName(), ime.getMessage() ]));
                    } catch (CannotParsePlaylistException cppe) {
                        log.warn(String.format("Cannot add playlist file %s. Message: %s", cast(Object[])[ file.getName(), cppe.getMessage() ]), cppe);
                    } catch (Exception e) {
                        log.warn(String.format("Cannot add file %s because of an unexpected error. Message: %s", cast(Object[])[ file.getName(), e.getMessage() ]), e);
                    }
                }
            }
            else {
                log.warn(String.format("Folder '%s' is either not an existing directory or cannot be read due to access rights", cast(Object[])[ folder.getAbsolutePath() ]));
            }
    }

    private void addNewMediaFile(Repository repository, File file, MediaFileType fileType)
    {
        log.debug_(String.format("Found file '%s', checking if it's already in the Library", cast(Object[])[ file.getName() ]));

        bool mediaPresent = MediaService.isMediaPresentInLibrary(file);

        if ((!mediaPresent) && (file.exists()) && (workerRunning))
            if (file.canRead()) {
                log.debug_("File not in Library, will add it");

                LocalItemMetadata mergedMetadata = LibraryManager.getInstance().extractMetadata(file, fileType, repository);
                if ((mergedMetadata !is null) && (workerRunning))
                {
                    mergedMetadata.validateMetadata();
                    bool newAdded = false;

                    if ((fileType == MediaFileType.AUDIO) && (( cast(AudioMetadata)mergedMetadata !is null ))) {
                        AudioService.addMusicTrackToLibrary(cast(AudioMetadata)mergedMetadata, repository);
                        newAdded = true;
                    } else if ((fileType == MediaFileType.VIDEO) && (( cast(VideoMetadata)mergedMetadata !is null ))) {
                        VideoService.addVideoToLibrary(cast(VideoMetadata)mergedMetadata, repository);
                        newAdded = true;
                    } else if ((fileType == MediaFileType.IMAGE) && (( cast(ImageMetadata)mergedMetadata !is null ))) {
                        ImageService.addImageToLibrary(cast(ImageMetadata)mergedMetadata, repository);
                        newAdded = true;
                    }
                    else {
                        log.error(String.format("Error during metadata extraction for file %s. Metadata mismatch.", new Object[0]), file.getName());
                    }
                    if (newAdded) {
                        log.info(String.format("Added file '%s' (title: %s) to Library", cast(Object[])[ file.getName(), mergedMetadata.getTitle() ]));
                        notifyListenersAdd(file.getName());
                    }
                }
            } else {
                log.warn(String.format("File '%s' cannot be read, probably due to access rights", cast(Object[])[ file.getAbsolutePath() ]));
            }
    }

    private void addNewPlaylistFile(Repository repository, File file)
    {
        log.debug_(String.format("Found playlist file '%s', checking if it's already in the Library", cast(Object[])[ file.getName() ]));
        bool playlistPresent = PlaylistService.isPlaylistInLibrary(file);

        if ((!playlistPresent) && (file.exists()) && (workerRunning))
            if (file.canRead()) {
                log.debug_("Playlist file not in Library, will add it");

                String playlistFilePath = FileUtils.getProperFilePath(file);
                ParsedPlaylist playlist = PlaylistParser.getInstance().parse(playlistFilePath);
                if (playlist !is null) {
                    PlaylistService.addPlaylistToLibrary(playlist, repository, playlistFilePath, null);
                    log.info(String.format("Added playlist '%s' (title: %s) to Library", cast(Object[])[ file.getName(), playlist.getTitle() ]));
                    notifyListenersAdd(file.getName());
                }
            } else {
                log.warn(String.format("Playlist file '%s' cannot be read, probably due to access rights", cast(Object[])[ file.getAbsolutePath() ]));
            }
    }

    private bool fileIsVisible(bool searchHidden, File file)
    {
        return (searchHidden) || ((!searchHidden) && (!file.isHidden()));
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.local.metadata.LibraryAdditionsCheckerThread
* JD-Core Version:    0.6.2
*/