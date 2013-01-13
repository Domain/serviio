module org.serviio.library.dao.VideoDAO;

import java.util.List;
import java.util.Map;
import org.serviio.db.dao.GenericDAO;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Person : RoleType;
import org.serviio.library.entities.Video;

public abstract interface VideoDAO : GenericDAO!(Video)
{
  public static final int TYPE_ALL = 0;
  public static final int TYPE_SERIES = 1;
  public static final int TYPE_MOVIES = 2;

  public abstract List!(Video) retrieveVideos(int paramInt1, AccessGroup paramAccessGroup, int paramInt2, int paramInt3);

  public abstract int retrieveVideosCount(int paramInt, AccessGroup paramAccessGroup);

  public abstract List!(Video) retrieveVideosForFolder(Long paramLong, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveVideosForFolderCount(Long paramLong, AccessGroup paramAccessGroup);

  public abstract List!(Video) retrieveVideosForPlaylist(Long paramLong, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveVideosForPlaylistCount(Long paramLong, AccessGroup paramAccessGroup);

  public abstract List!(Video) retrieveVideosForGenre(Long paramLong, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveVideosForGenreCount(Long paramLong, AccessGroup paramAccessGroup);

  public abstract List!(Video) retrieveVideosForPerson(Long paramLong, RoleType paramRoleType, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveVideosForPersonCount(Long paramLong, RoleType paramRoleType, AccessGroup paramAccessGroup);

  public abstract List!(Video) retrieveVideosForSeriesSeason(Long paramLong, Integer paramInteger, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveVideosForSeriesSeasonCount(Long paramLong, Integer paramInteger, AccessGroup paramAccessGroup);

  public abstract List!(String) retrieveVideoInitials(AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveVideoInitialsCount(AccessGroup paramAccessGroup);

  public abstract List!(Video) retrieveVideosForInitial(String paramString, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveVideosForInitialCount(String paramString, AccessGroup paramAccessGroup);

  public abstract List!(Video) retrieveLastViewedVideos(int paramInt1, AccessGroup paramAccessGroup, int paramInt2, int paramInt3);

  public abstract int retrieveLastViewedVideosCount(int paramInt, AccessGroup paramAccessGroup);

  public abstract List!(Video) retrieveLastAddedVideos(int paramInt1, AccessGroup paramAccessGroup, int paramInt2, int paramInt3);

  public abstract int retrieveLastAddedVideosCount(int paramInt, AccessGroup paramAccessGroup);

  public abstract Map!(Long, Integer) retrieveLastViewedEpisode(Long paramLong);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.VideoDAO
 * JD-Core Version:    0.6.2
 */