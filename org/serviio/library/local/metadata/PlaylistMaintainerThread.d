module org.serviio.library.local.metadata.PlaylistMaintainerThread;

import java.lang.String;
import java.io.File;
import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.entities.Playlist;
import org.serviio.library.local.service.MediaService;
import org.serviio.library.local.service.PlaylistService;
import org.serviio.library.metadata.AbstractLibraryCheckerThread;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.library.playlist.CannotParsePlaylistException;
import org.serviio.library.playlist.ParsedPlaylist;
import org.serviio.library.playlist.PlaylistItem;
import org.serviio.library.playlist.PlaylistParser;
import org.serviio.util.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PlaylistMaintainerThread : AbstractLibraryCheckerThread
{
    private static immutable Logger log;
    private static const int REFRESH_INTERVAL_IN_MINUTES = 5;

    static this()
    {
        log = LoggerFactory.getLogger!(PlaylistMaintainerThread)();
    }

    override public void run()
    {
        log.info("Started looking playlist changes");
        workerRunning = true;
        while (workerRunning) {
            searchingForFiles = true;

            List!(Playlist) playlists = PlaylistService.getAllPlaylists();
            foreach (Playlist playlist ; playlists) {
                bool playlistUpdated = false;
                File playlistFile = new File(playlist.getFilePath());
                if ((playlistFile.exists()) && (workerRunning)) {
                    try {
                        if ((playlist.getDateUpdated() is null) || (playlist.getDateUpdated().before(FileUtils.getLastModifiedDate(playlistFile))))
                        {
                            playlistUpdated = addPlaylistItems(playlist, playlistFile);
                        } else if (!playlist.isAllItemsFound())
                        {
                            playlistUpdated = checkForMissingPlaylistItems(playlist);
                        }
                    } catch (CannotParsePlaylistException e) {
                        log.warn("An error occured while updating playlist: ", e.getMessage());
                    } catch (Exception e) {
                        log.warn("An error occured while updating playlist, will continue", e);
                    }
                }
                if (playlistUpdated) {
                    notifyListenersUpdate(playlist.getTitle());
                }
            }

            searchingForFiles = false;
            try {
                if (workerRunning) {
                    isSleeping = true;
                    Thread.sleep(REFRESH_INTERVAL_IN_MINUTES*6000);
                    isSleeping = false;
                }
            } catch (InterruptedException e) {
                isSleeping = false;
            }
        }
        log.info("Finished looking for playlist changes");
    }

    private bool checkForMissingPlaylistItems(Playlist playlist)
    {
        log.debug_(String.format("Playlist %s has unresolved items, checking if they are in the library now", cast(Object[])[ playlist.getTitle() ]));

        ParsedPlaylist parsedPlaylist = parsePlaylst(playlist.getFilePath());

        List!(Integer) currentItemIndexes = PlaylistService.getPlaylistItemIndices(playlist.getId());
        bool allItemsPresent = true;
        bool updated = false;
        foreach (PlaylistItem pi ; parsedPlaylist.getItems()) {
            if (!currentItemIndexes.contains(pi.getSequenceNumber()))
            {
                log.debug_(String.format("Found playlist item that has not been added yet: %s", cast(Object[])[ pi.getPath() ]));
                MediaItem existingMediaItem = MediaService.getMediaItem(pi.getPath(), true);
                if (existingMediaItem !is null)
                {
                    PlaylistService.addPlaylistItem(pi.getSequenceNumber(), existingMediaItem.getId(), playlist.getId());
                    playlist.getFileTypes().add(existingMediaItem.getFileType());
                    log.debug_("Registered playlist item");
                    updated = true;
                } else {
                    log.debug_(String.format("Item '%s' cannot be resolved to an entity in the Serviio library, will try again later", cast(Object[])[ pi.getPath() ]));
                    allItemsPresent = false;
                }
            }
        }
        if (updated)
        {
            playlist.setAllItemsFound(allItemsPresent);
            PlaylistService.updatePlaylist(playlist);
        }
        return updated;
    }

    private bool addPlaylistItems(Playlist playlist, File playlistFile) {
        log.debug_(String.format("Playlist %s has changed, updating the library", cast(Object[])[ playlist.getTitle() ]));
        ParsedPlaylist parsedPlaylist = parsePlaylst(playlist.getFilePath());

        PlaylistService.removePlaylistItems(playlist.getId());

        Set!(MediaFileType) fileTypes = new HashSet!(MediaFileType)();
        bool allItemsPresent = true;
        foreach (PlaylistItem pi ; parsedPlaylist.getItems()) {
            MediaItem existingMediaItem = MediaService.getMediaItem(pi.getPath(), true);
            if (existingMediaItem !is null) {
                PlaylistService.addPlaylistItem(pi.getSequenceNumber(), existingMediaItem.getId(), playlist.getId());
                fileTypes.add(existingMediaItem.getFileType());
            } else {
                allItemsPresent = false;
            }

        }

        playlist.setTitle(parsedPlaylist.getTitle());
        playlist.setDateUpdated(FileUtils.getLastModifiedDate(playlistFile));
        playlist.setFileTypes(fileTypes);
        playlist.setAllItemsFound(allItemsPresent);
        PlaylistService.updatePlaylist(playlist);

        return true;
    }

    private ParsedPlaylist parsePlaylst(String filePath) {
        return PlaylistParser.getInstance().parse(filePath);
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.local.metadata.PlaylistMaintainerThread
* JD-Core Version:    0.6.2
*/