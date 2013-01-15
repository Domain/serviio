module org.serviio.library.dao.MediaItemDAOImpl;

import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import org.serviio.db.DatabaseManager;
import org.serviio.db.dao.InvalidArgumentException;
import org.serviio.db.dao.PersistenceException;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.util.FileUtils;
import org.serviio.util.JdbcUtils;
import org.serviio.util.Platform;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MediaItemDAOImpl
  : MediaItemDAO
{
  private static final Logger log = LoggerFactory.getLogger!(MediaItemDAOImpl)();

  public bool isMediaItemPresent(File mediaFile)
  {
    if (mediaFile is null) {
      throw new InvalidArgumentException("Cannot check item presence. Required data is missing.");
    }
    log.debug_(String.format("Checking if DB already contains media item %s", cast(Object[])[ mediaFile.getName() ]));
    MediaItem mi = getMediaItem(FileUtils.getProperFilePath(mediaFile), Platform.isWindows());
    if (mi !is null) {
      log.debug_(String.format("Media item %s already exists in DB", cast(Object[])[ mediaFile.getName() ]));
      return true;
    }
    log.debug_(String.format("Media item %s doesn't exist in DB yet", cast(Object[])[ mediaFile.getName() ]));
    return false;
  }

  public MediaItem getMediaItem(String filePath, bool ignoreCase)
  {
    log.debug_(String.format("Looking up a media item for file path: %s, ignore case: %s", cast(Object[])[ filePath, Boolean.valueOf(ignoreCase) ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT id, title, sort_title, file_size, file_name, file_path, folder_id, creation_date, description, file_type, last_viewed_date, number_viewed, dirty, bookmark, cover_image_id, repository_id FROM media_item WHERE ").append(ignoreCase ? "lc_file_path = ?" : "file_path = ?").toString());

      ps.setString(1, ignoreCase ? filePath.toLowerCase() : filePath);
      ResultSet rs = ps.executeQuery();
      return mapSingleResult(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot find media item by file path: %s ", cast(Object[])[ filePath ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public MediaItem read(Long id)
  {
    log.debug_(String.format("Reading a MediaItem (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, title, sort_title, file_size, file_name, file_path, folder_id, creation_date, description, file_type, last_viewed_date, number_viewed, dirty, bookmark, cover_image_id, repository_id FROM media_item where id = ?");

      ps.setLong(1, id.longValue());
      ResultSet rs = ps.executeQuery();
      return mapSingleResult(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read MediaItem with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public File getFile(Long mediaItemId)
  {
    log.debug_(String.format("Getting file of media item %s", cast(Object[])[ mediaItemId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT media_item.file_path as file_path FROM media_item WHERE  media_item.id = ?");

      ps.setLong(1, mediaItemId.longValue());

      ResultSet rs = ps.executeQuery();
      if (rs.next()) {
        return new File(rs.getString("file_path"));
      }
      return null;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot get file of media item: %s ", cast(Object[])[ mediaItemId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(MediaItem) getMediaItemsInRepository(Long repositoryId)
  {
    log.debug_(String.format("Reading MediaItems for Repository (id = %s)", cast(Object[])[ repositoryId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT media_item.id as id, title, sort_title, file_size, file_name, file_path, folder_id, creation_date, description, file_type, last_viewed_date, number_viewed, dirty, bookmark, cover_image_id, repository_id FROM media_item where repository_id = ?");

      ps.setLong(1, repositoryId.longValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read MediaItems for Repository with id = %s", cast(Object[])[ repositoryId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(MediaItem) getMediaItemsInRepository(Long repositoryId, MediaFileType fileType)
  {
    log.debug_(String.format("Reading MediaItems (%s) for Repository (id = %s)", cast(Object[])[ fileType, repositoryId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT media_item.id as id, title, sort_title, file_size, file_name, file_path, folder_id, creation_date, description, file_type, last_viewed_date, number_viewed, dirty, bookmark, cover_image_id, repository_id FROM media_item where repository_id = ? and file_type = ?");

      ps.setLong(1, repositoryId.longValue());
      ps.setString(2, fileType.toString());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read MediaItems (%s) for Repository with id = %s", cast(Object[])[ fileType, repositoryId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void markMediaItemAsDirty(Long mediaItemId)
  {
    if (mediaItemId is null) {
      throw new InvalidArgumentException("Cannot mark MediaItem as dirty. Required data is missing.");
    }
    log.debug_(String.format("Marking MediaItem (id = %s) as dirty", cast(Object[])[ mediaItemId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("UPDATE media_item SET dirty = 1 WHERE id = ?");
      ps.setLong(1, mediaItemId.longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot mark MediaItem %s as dirty", cast(Object[])[ mediaItemId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void markMediaItemsAsDirty(MediaFileType fileType)
  {
    if (fileType is null) {
      throw new InvalidArgumentException("Cannot mark MediaItems as dirty. Required data is missing.");
    }
    log.debug_(String.format("Marking MediaItems (type = %s) as dirty", cast(Object[])[ fileType ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("UPDATE media_item SET dirty = 1 WHERE file_type = ?");
      ps.setString(1, fileType.toString());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot mark MediaItems of type %s as dirty", cast(Object[])[ fileType ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void setMediaItemBookmark(Long mediaItemId, Integer seconds)
  {
    if ((mediaItemId is null) || (seconds is null)) {
      throw new InvalidArgumentException("Cannot set MediaItem bookmark. Required data is missing.");
    }
    log.debug_(String.format("Bookmarking MediaItem (id = %s) at %s seconds", cast(Object[])[ mediaItemId, seconds ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("UPDATE media_item SET bookmark = ? WHERE id = ?");
      ps.setInt(1, seconds.intValue());
      ps.setLong(2, mediaItemId.longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot set bookmark for MediaItem %s", cast(Object[])[ mediaItemId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(MediaItem) getDirtyMediaItemsInRepository(Long repositoryId)
  {
    log.debug_(String.format("Reading dirty MediaItems for Repository (id = %s)", cast(Object[])[ repositoryId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT media_item.id as id, title, sort_title, file_size, file_name, file_path, folder_id, creation_date, description, file_type, last_viewed_date, number_viewed, dirty, bookmark, cover_image_id, repository_id FROM media_item where media_item.repository_id = ? and media_item.dirty = 1");

      ps.setLong(1, repositoryId.longValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read dirty MediaItems for Repository with id = %s", cast(Object[])[ repositoryId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void markMediaItemAsRead(Long mediaItemId)
  {
    if (mediaItemId is null) {
      throw new InvalidArgumentException("Cannot mark MediaItem as read. Required data is missing.");
    }
    log.debug_(String.format("Marking MediaItem (id = %s) as read", cast(Object[])[ mediaItemId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("UPDATE media_item SET last_viewed_date = CURRENT TIMESTAMP, number_viewed = (number_viewed + 1) WHERE id = ?");
      ps.setLong(1, mediaItemId.longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot mark MediaItem %s as read", cast(Object[])[ mediaItemId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  protected MediaItem mapSingleResult(ResultSet rs)
  {
    if (rs.next()) {
      return initMediaItem(rs);
    }
    return null;
  }

  protected List!(MediaItem) mapResultSet(ResultSet rs)
  {
    List!(MediaItem) result = new ArrayList!(MediaItem)();
    while (rs.next()) {
      result.add(initMediaItem(rs));
    }
    return result;
  }

  private MediaItem initMediaItem(ResultSet rs) {
    Long id = Long.valueOf(rs.getLong("id"));
    String title = rs.getString("title");
    String sortTitle = rs.getString("sort_title");
    Long fileSize = JdbcUtils.getLongFromResultSet(rs, "file_size");
    String fileName = rs.getString("file_name");
    String filePath = rs.getString("file_path");
    Long folderId = Long.valueOf(rs.getLong("folder_id"));
    Long repositoryId = Long.valueOf(rs.getLong("repository_id"));
    Date date = rs.getTimestamp("creation_date");
    String description = rs.getString("description");
    Date lastViewed = rs.getTimestamp("last_viewed_date");
    Integer numberViewed = Integer.valueOf(rs.getInt("number_viewed"));
    Integer bookmark = Integer.valueOf(rs.getInt("bookmark"));
    Long coverImageId = Long.valueOf(rs.getLong("cover_image_id"));
    bool dirty = rs.getBoolean("dirty");
    MediaFileType fileType = MediaFileType.valueOf(rs.getString("file_type"));

    MediaItem item = new MediaItem(title, fileName, filePath, fileSize, folderId, repositoryId, date, fileType);
    item.setId(id);
    item.setDescription(description);
    item.setSortTitle(sortTitle);
    item.setDirty(dirty);
    item.setLastViewedDate(lastViewed);
    item.setNumberViewed(numberViewed);
    item.setBookmark(bookmark);
    item.setThumbnailId(coverImageId);

    return item;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.MediaItemDAOImpl
 * JD-Core Version:    0.6.2
 */