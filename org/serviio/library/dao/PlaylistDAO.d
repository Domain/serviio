module org.serviio.library.dao.PlaylistDAO;

import java.io.File;
import java.util.List;
import org.serviio.db.dao.GenericDAO;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Playlist;
import org.serviio.library.metadata.MediaFileType;

public abstract interface PlaylistDAO : GenericDAO!(Playlist)
{
  public abstract List!(Playlist) findAll();

  public abstract bool isPlaylistPresent(File paramFile);

  public abstract List!(Playlist) getPlaylistsInRepository(Long paramLong);

  public abstract void removeMediaItemFromPlaylists(Long paramLong);

  public abstract void removePlaylistItems(Long paramLong);

  public abstract void addPlaylistItem(Integer paramInteger, Long paramLong1, Long paramLong2);

  public abstract List!(Integer) getPlaylistItemIndices(Long paramLong);

  public abstract List!(Playlist) retrievePlaylistsWithMedia(MediaFileType paramMediaFileType, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int getPlaylistsWithMediaCount(MediaFileType paramMediaFileType, AccessGroup paramAccessGroup);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.PlaylistDAO
 * JD-Core Version:    0.6.2
 */