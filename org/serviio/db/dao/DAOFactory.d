module org.serviio.db.dao.DAOFactory;

import org.serviio.config.dao.ConfigEntryDAO;
import org.serviio.config.dao.ConfigEntryDAOImpl;
import org.serviio.library.dao.AccessGroupDAO;
import org.serviio.library.dao.AccessGroupDAOImpl;
import org.serviio.library.dao.CoverImageDAO;
import org.serviio.library.dao.CoverImageDAOImpl;
import org.serviio.library.dao.FolderDAO;
import org.serviio.library.dao.FolderDAOImpl;
import org.serviio.library.dao.GenreDAO;
import org.serviio.library.dao.GenreDAOImpl;
import org.serviio.library.dao.ImageDAO;
import org.serviio.library.dao.ImageDAOImpl;
import org.serviio.library.dao.MediaItemDAO;
import org.serviio.library.dao.MediaItemDAOImpl;
import org.serviio.library.dao.MetadataDescriptorDAO;
import org.serviio.library.dao.MetadataDescriptorDAOImpl;
import org.serviio.library.dao.MetadataExtractorConfigDAO;
import org.serviio.library.dao.MetadataExtractorConfigDAOImpl;
import org.serviio.library.dao.MusicAlbumDAO;
import org.serviio.library.dao.MusicAlbumDAOImpl;
import org.serviio.library.dao.MusicTrackDAO;
import org.serviio.library.dao.MusicTrackDAOImpl;
import org.serviio.library.dao.OnlineRepositoryDAO;
import org.serviio.library.dao.OnlineRepositoryDAOImpl;
import org.serviio.library.dao.PersonDAO;
import org.serviio.library.dao.PersonDAOImpl;
import org.serviio.library.dao.PlaylistDAO;
import org.serviio.library.dao.PlaylistDAOImpl;
import org.serviio.library.dao.RepositoryDAO;
import org.serviio.library.dao.RepositoryDAOImpl;
import org.serviio.library.dao.SeriesDAO;
import org.serviio.library.dao.SeriesDAOImpl;
import org.serviio.library.dao.VideoDAO;
import org.serviio.library.dao.VideoDAOImpl;
import org.serviio.renderer.dao.RendererDAO;
import org.serviio.renderer.dao.RendererDAOImpl;
import org.serviio.update.dao.DBLogDAO;
import org.serviio.update.dao.DBLogDAOImpl;

public final class DAOFactory
{
  private static RepositoryDAO repositoryDAO;
  private static MusicAlbumDAO musicAlbumDAO;
  private static MediaItemDAO mediaItemDAO;
  private static MusicTrackDAO musicTrackDAO;
  private static FolderDAO folderDAO;
  private static GenreDAO genreDAO;
  private static CoverImageDAO coverImageDAO;
  private static PersonDAO personDAO;
  private static MetadataExtractorConfigDAO metadataExtractorConfigDAO;
  private static MetadataDescriptorDAO metadataDescriptorDAO;
  private static ImageDAO imageDAO;
  private static VideoDAO videoDAO;
  private static SeriesDAO seriesDAO;
  private static ConfigEntryDAO configEntryDAO;
  private static DBLogDAO dbLogDAO;
  private static RendererDAO rendererDAO;
  private static OnlineRepositoryDAO onlineRepositoryDAO;
  private static PlaylistDAO playlistDAO;
  private static AccessGroupDAO accessGroupDAO;

  public static RepositoryDAO getRepositoryDAO()
  {
    if (repositoryDAO is null) {
      repositoryDAO = new RepositoryDAOImpl();
    }
    return repositoryDAO;
  }

  public static MusicAlbumDAO getMusicAlbumDAO() {
    if (musicAlbumDAO is null) {
      musicAlbumDAO = new MusicAlbumDAOImpl();
    }
    return musicAlbumDAO;
  }

  public static MediaItemDAO getMediaItemDAO() {
    if (mediaItemDAO is null) {
      mediaItemDAO = new MediaItemDAOImpl();
    }
    return mediaItemDAO;
  }

  public static MusicTrackDAO getMusicTrackDAO() {
    if (musicTrackDAO is null) {
      musicTrackDAO = new MusicTrackDAOImpl();
    }
    return musicTrackDAO;
  }

  public static FolderDAO getFolderDAO() {
    if (folderDAO is null) {
      folderDAO = new FolderDAOImpl();
    }
    return folderDAO;
  }

  public static GenreDAO getGenreDAO() {
    if (genreDAO is null) {
      genreDAO = new GenreDAOImpl();
    }
    return genreDAO;
  }

  public static PersonDAO getPersonDAO() {
    if (personDAO is null) {
      personDAO = new PersonDAOImpl();
    }
    return personDAO;
  }

  public static CoverImageDAO getCoverImageDAO() {
    if (coverImageDAO is null) {
      coverImageDAO = new CoverImageDAOImpl();
    }
    return coverImageDAO;
  }

  public static MetadataExtractorConfigDAO getMetadataExtractorConfigDAO() {
    if (metadataExtractorConfigDAO is null) {
      metadataExtractorConfigDAO = new MetadataExtractorConfigDAOImpl();
    }
    return metadataExtractorConfigDAO;
  }

  public static MetadataDescriptorDAO getMetadataDescriptorDAO()
  {
    if (metadataDescriptorDAO is null) {
      metadataDescriptorDAO = new MetadataDescriptorDAOImpl();
    }
    return metadataDescriptorDAO;
  }

  public static ImageDAO getImageDAO()
  {
    if (imageDAO is null) {
      imageDAO = new ImageDAOImpl();
    }
    return imageDAO;
  }

  public static VideoDAO getVideoDAO() {
    if (videoDAO is null) {
      videoDAO = new VideoDAOImpl();
    }
    return videoDAO;
  }

  public static SeriesDAO getSeriesDAO() {
    if (seriesDAO is null) {
      seriesDAO = new SeriesDAOImpl();
    }
    return seriesDAO;
  }

  public static ConfigEntryDAO getConfigEntryDAO() {
    if (configEntryDAO is null) {
      configEntryDAO = new ConfigEntryDAOImpl();
    }
    return configEntryDAO;
  }

  public static DBLogDAO getDBLogDAO() {
    if (dbLogDAO is null) {
      dbLogDAO = new DBLogDAOImpl();
    }
    return dbLogDAO;
  }

  public static RendererDAO getRendererDAO() {
    if (rendererDAO is null) {
      rendererDAO = new RendererDAOImpl();
    }
    return rendererDAO;
  }

  public static OnlineRepositoryDAO getOnlineRepositoryDAO() {
    if (onlineRepositoryDAO is null) {
      onlineRepositoryDAO = new OnlineRepositoryDAOImpl();
    }
    return onlineRepositoryDAO;
  }

  public static PlaylistDAO getPlaylistDAO() {
    if (playlistDAO is null) {
      playlistDAO = new PlaylistDAOImpl();
    }
    return playlistDAO;
  }

  public static AccessGroupDAO getAccessGroupDAO() {
    if (accessGroupDAO is null) {
      accessGroupDAO = new AccessGroupDAOImpl();
    }
    return accessGroupDAO;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.db.dao.DAOFactory
 * JD-Core Version:    0.6.2
 */