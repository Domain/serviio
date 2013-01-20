module org.serviio.library.local.service.PlaylistService;

import java.lang.Long;
import java.lang.String;
import java.lang.Integer;
import java.io.File;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import org.serviio.db.dao.DAOFactory;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Playlist;
import org.serviio.library.entities.Repository;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.library.playlist.ParsedPlaylist;
import org.serviio.library.service.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PlaylistService : Service
{
    private static immutable Logger log;

    static this()
    {
        log = LoggerFactory.getLogger!(PlaylistService)();
    }

    public static Playlist getPlaylist(Long playlistId)
    {
        return cast(Playlist)DAOFactory.getPlaylistDAO().read(playlistId);
    }

    public static List!(Playlist) getAllPlaylists()
    {
        return DAOFactory.getPlaylistDAO().findAll();
    }

    public static bool isPlaylistInLibrary(File playlistFile)
    {
        return DAOFactory.getPlaylistDAO().isPlaylistPresent(playlistFile);
    }

    public static void addPlaylistToLibrary(ParsedPlaylist parsedPlaylist, Repository repository, String filePath, Date lastModified)
    {
        log.debug_(String.format("Adding playlist into database: %s", cast(Object[])[ parsedPlaylist.getTitle() ]));

        Playlist playlist = new Playlist(parsedPlaylist.getTitle(), new HashSet!(MediaFileType)(), filePath, lastModified, repository.getId());
        playlist.setAllItemsFound(false);

        DAOFactory.getPlaylistDAO().create(playlist);
    }

    public static void detetePlaylistAndItems(Long playlistId)
    {
        DAOFactory.getPlaylistDAO().delete_(playlistId);
    }

    public static List!(Playlist) getPlaylistsInRepository(Long repositoryId) {
        return DAOFactory.getPlaylistDAO().getPlaylistsInRepository(repositoryId);
    }

    public static void removeMediaItemFromPlaylists(Long mediaItemId) {
        DAOFactory.getPlaylistDAO().removeMediaItemFromPlaylists(mediaItemId);
    }

    public static void updatePlaylist(Playlist transientObject) {
        DAOFactory.getPlaylistDAO().update(transientObject);
    }

    public static void removePlaylistItems(Long playlistId) {
        DAOFactory.getPlaylistDAO().removePlaylistItems(playlistId);
    }

    public static void addPlaylistItem(Integer order, Long mediaItemId, Long playlistId) {
        DAOFactory.getPlaylistDAO().addPlaylistItem(order, mediaItemId, playlistId);
    }

    public static List!(Integer) getPlaylistItemIndices(Long playlistId) {
        return DAOFactory.getPlaylistDAO().getPlaylistItemIndices(playlistId);
    }

    public static List!(Playlist) getListOfPlaylistsWithMedia(MediaFileType mediaType, AccessGroup accessGroup, int startingIndex, int requestedCount)
    {
        return DAOFactory.getPlaylistDAO().retrievePlaylistsWithMedia(mediaType, accessGroup, startingIndex, requestedCount);
    }

    public static int getNumberOfPlaylistsWithMedia(MediaFileType mediaType, AccessGroup accessGroup)
    {
        return DAOFactory.getPlaylistDAO().getPlaylistsWithMediaCount(mediaType, accessGroup);
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.local.service.PlaylistService
* JD-Core Version:    0.6.2
*/