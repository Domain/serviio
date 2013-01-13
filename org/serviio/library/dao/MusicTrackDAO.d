module org.serviio.library.dao.MusicTrackDAO;

import java.util.List;
import org.serviio.db.dao.GenericDAO;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.MusicTrack;
import org.serviio.library.entities.Person : RoleType;

public abstract interface MusicTrackDAO : GenericDAO!(MusicTrack)
{
  public abstract List!(MusicTrack) retrieveMusicTracksForArtist(Long paramLong, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveMusicTracksForArtistCount(Long paramLong, AccessGroup paramAccessGroup);

  public abstract List!(MusicTrack) retrieveMusicTracksForGenre(Long paramLong, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveMusicTracksForGenreCount(Long paramLong, AccessGroup paramAccessGroup);

  public abstract List!(MusicTrack) retrieveMusicTracksForFolder(Long paramLong, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveMusicTracksForFolderCount(Long paramLong, AccessGroup paramAccessGroup);

  public abstract List!(String) retrieveMusicTracksInitials(AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveMusicTracksInitialsCount(AccessGroup paramAccessGroup);

  public abstract List!(MusicTrack) retrieveMusicTracksForInitial(String paramString, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveMusicTracksForInitialCount(String paramString, AccessGroup paramAccessGroup);

  public abstract List!(MusicTrack) retrieveMusicTracksForAlbum(Long paramLong, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveMusicTracksForAlbumCount(Long paramLong, AccessGroup paramAccessGroup);

  public abstract List!(MusicTrack) retrieveAllMusicTracks(AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveAllMusicTracksCount(AccessGroup paramAccessGroup);

  public abstract List!(MusicTrack) retrieveRandomMusicTracks(int paramInt1, int paramInt2, AccessGroup paramAccessGroup);

  public abstract int retrieveRandomMusicTracksCount(int paramInt, AccessGroup paramAccessGroup);

  public abstract List!(MusicTrack) retrieveMusicTracksForTrackRoleAndAlbum(Long paramLong1, RoleType paramRoleType, Long paramLong2, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveMusicTracksForTrackRoleAndAlbumCount(Long paramLong1, RoleType paramRoleType, Long paramLong2, AccessGroup paramAccessGroup);

  public abstract List!(MusicTrack) retrieveMusicTracksForPlaylist(Long paramLong, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveMusicTracksForPlaylistCount(Long paramLong, AccessGroup paramAccessGroup);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.MusicTrackDAO
 * JD-Core Version:    0.6.2
 */