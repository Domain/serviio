module org.serviio.library.dao.MusicAlbumDAO;

import java.util.List;
import org.serviio.db.dao.GenericDAO;
import org.serviio.db.dao.InvalidArgumentException;
import org.serviio.library.entities.MusicAlbum;
import org.serviio.library.entities.Person : RoleType;

public abstract interface MusicAlbumDAO : GenericDAO!(MusicAlbum)
{
  public abstract MusicAlbum findAlbum(String paramString1, String paramString2);

  public abstract int getNumberOfTracks(Long paramLong);

  public abstract List!(MusicAlbum) retrieveMusicAlbumsForTrackRole(Long paramLong, RoleType paramRoleType, int paramInt1, int paramInt2);

  public abstract int retrieveMusicAlbumsForTrackRoleCount(Long paramLong, RoleType paramRoleType);

  public abstract List!(MusicAlbum) retrieveMusicAlbumsForAlbumArtist(Long paramLong, int paramInt1, int paramInt2);

  public abstract int retrieveMusicAlbumsForAlbumArtistCount(Long paramLong);

  public abstract List!(MusicAlbum) retrieveAllMusicAlbums(int paramInt1, int paramInt2);

  public abstract int retrieveAllMusicAlbumsCount();
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.MusicAlbumDAO
 * JD-Core Version:    0.6.2
 */