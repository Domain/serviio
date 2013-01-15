module org.serviio.library.dao.PlaylistDAOImpl;

import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import org.serviio.db.DatabaseManager;
import org.serviio.db.JdbcExecutor;
import org.serviio.db.dao.InvalidArgumentException;
import org.serviio.db.dao.PersistenceException;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Playlist;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.util.FileUtils;
import org.serviio.util.JdbcUtils;
import org.serviio.util.ObjectValidator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PlaylistDAOImpl : AbstractAccessibleDao
  , PlaylistDAO
{
  private static final Logger log = LoggerFactory.getLogger!(PlaylistDAOImpl)();

  public long create(Playlist newInstance)
  {
    if ((newInstance is null) || (newInstance.getTitle() is null)) {
      throw new InvalidArgumentException("Cannot create Playlist. Required data is missing.");
    }
    log.debug_(String.format("Creating a new Playlist (title = %s)", cast(Object[])[ newInstance.getTitle() ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("INSERT INTO playlist (file_types, title, file_path, date_updated, repository_id,all_items_found) VALUES (?,?,?,?,?,?)", 1);

      ps.setString(1, MediaFileType.parseMediaFileTypesToString(newInstance.getFileTypes()));
      ps.setString(2, JdbcUtils.trimToMaxLength(newInstance.getTitle(), 128));
      ps.setString(3, newInstance.getFilePath());
      JdbcUtils.setTimestampValueOnStatement(ps, 4, newInstance.getDateUpdated());
      ps.setLong(5, newInstance.getRepositoryId().longValue());
      ps.setBoolean(6, newInstance.isAllItemsFound());
      ps.executeUpdate();
      return JdbcUtils.retrieveGeneratedID(ps);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot create Playlist with name %s", cast(Object[])[ newInstance.getTitle() ]), e);
    } finally {
      DatabaseManager.releaseConnection(con);
    }
  }

  public void delete_(Long id)
  {
    log.debug_(String.format("Deleting a Playlist (id = %s) and all related items", cast(Object[])[ id ]));

    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();

      ps = con.prepareStatement("DELETE FROM playlist_item WHERE playlist_id = ?");
      ps.setLong(1, id.longValue());
      ps.executeUpdate();

      deletePlaylist(con, id);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot remove Playlist %s or its items", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public Playlist read(Long id)
  {
    log.debug_(String.format("Reading a Playlist (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, file_types, title, file_path, date_updated, repository_id,all_items_found FROM playlist where id = ?");

      ps.setLong(1, id.longValue());
      ResultSet rs = ps.executeQuery();
      return mapSingleResult(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read Playlist with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void update(Playlist transientObject)
  {
    if ((transientObject is null) || (transientObject.getId() is null) || (ObjectValidator.isEmpty(transientObject.getTitle())) || (ObjectValidator.isEmpty(transientObject.getFilePath())) || (transientObject.getDateUpdated() is null) || (transientObject.getRepositoryId() is null))
    {
      throw new InvalidArgumentException("Cannot update Playlist. Required data is missing.");
    }
    log.debug_(String.format("Updating Playlist (id = %s)", cast(Object[])[ transientObject.getId() ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("UPDATE playlist SET file_types = ?, title = ?, file_path = ?, date_updated = ?, repository_id = ?,all_items_found = ? WHERE id = ?");

      ps.setString(1, MediaFileType.parseMediaFileTypesToString(transientObject.getFileTypes()));
      ps.setString(2, JdbcUtils.trimToMaxLength(transientObject.getTitle(), 128));
      ps.setString(3, transientObject.getFilePath());
      JdbcUtils.setTimestampValueOnStatement(ps, 4, transientObject.getDateUpdated());
      ps.setLong(5, transientObject.getRepositoryId().longValue());
      ps.setBoolean(6, transientObject.isAllItemsFound());

      ps.setLong(7, transientObject.getId().longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot update Playlist with id %s", cast(Object[])[ transientObject.getId() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public bool isPlaylistPresent(File playlistFile)
  {
    if (playlistFile is null) {
      throw new InvalidArgumentException("Cannot check playlist presence. Required data is missing.");
    }
    log.debug_(String.format("Checking if DB already contains playlist %s", cast(Object[])[ playlistFile.getName() ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT file_path FROM playlist WHERE file_path = ?");
      ps.setString(1, FileUtils.getProperFilePath(playlistFile));
      ResultSet rs = ps.executeQuery();
      if (rs.next()) {
        log.debug_(String.format("Playlist %s already exists in DB", cast(Object[])[ playlistFile.getName() ]));
        return true;
      }
      log.debug_(String.format("Playlist %s doesn't exist in DB yet", cast(Object[])[ playlistFile.getName() ]));
      return false;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot check if playlist exists: %s ", cast(Object[])[ playlistFile.getName() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Playlist) getPlaylistsInRepository(Long repositoryId)
  {
    log.debug_(String.format("Reading Playlists for Repository (id = %s)", cast(Object[])[ repositoryId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, file_types, title, file_path, date_updated, repository_id,all_items_found FROM playlist where repository_id = ?");

      ps.setLong(1, repositoryId.longValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read Playlists for Repository with id = %s", cast(Object[])[ repositoryId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void removeMediaItemFromPlaylists(final Long mediaItemId)
  {
    try
    {
      (new class() JdbcExecutor!(Object)
      {
        protected PreparedStatement processStatement(Connection con)
        {
          PreparedStatement ps = con.prepareStatement("DELETE FROM playlist_item WHERE media_item_id = ?");
          ps.setLong(1, mediaItemId.longValue());
          ps.executeUpdate();
          return ps;
        }
      })
      .executeUpdate();
    }
    catch (SQLException e)
    {
      throw new PersistenceException(String.format("Cannot delete MediaItem with id = %s from playlists", cast(Object[])[ mediaItemId ]), e);
    }
  }

  public List!(Playlist) findAll()
  {
    log.debug_("Reading all Playlists");
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, file_types, title, file_path, date_updated, repository_id,all_items_found FROM playlist ORDER BY id");

      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException("Cannot retrieve list of Playlists", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void removePlaylistItems(final Long playlistId)
  {
    log.debug_(String.format("Removing all items from playlist %s", cast(Object[])[ playlistId ]));
    try {
      (new class() JdbcExecutor!(Object)
      {
        protected PreparedStatement processStatement(Connection con)
        {
          PreparedStatement ps = con.prepareStatement("DELETE FROM playlist_item WHERE playlist_id = ?");
          ps.setLong(1, playlistId.longValue());
          ps.executeUpdate();
          return ps;
        }
      })
      .executeUpdate();
    }
    catch (SQLException e)
    {
      throw new PersistenceException(String.format("Cannot delete PlaylistItems from playlist with id = %s", cast(Object[])[ playlistId ]), e);
    }
  }

  public void addPlaylistItem(Integer order, Long mediaItemId, Long playlistId)
  {
    if ((order is null) || (mediaItemId is null) || (playlistId is null)) {
      throw new InvalidArgumentException("Cannot create Playlist Item. Required data is missing.");
    }
    log.debug_(String.format("Adding a new Item to playlist (media item = %s, playlist = %s)", cast(Object[])[ mediaItemId, playlistId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("INSERT INTO playlist_item (item_order, playlist_id, media_item_id) VALUES (?,?,?)", 1);

      ps.setInt(1, order.intValue());
      ps.setLong(2, playlistId.longValue());
      ps.setLong(3, mediaItemId.longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException("Cannot create Playlist Item", e);
    } finally {
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Integer) getPlaylistItemIndices(Long playlistId)
  {
    log.debug_(String.format("Reading items for playlist %s", cast(Object[])[ playlistId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT item_order FROM playlist_item WHERE playlist_id = ? ORDER BY item_order");
      ps.setLong(1, playlistId.longValue());
      ResultSet rs = ps.executeQuery();
      List!(Integer) numbers = new ArrayList!(Integer)();
      while (rs.next()) {
        numbers.add(Integer.valueOf(rs.getInt("item_order")));
      }
      return numbers;
    } catch (SQLException e) {
      throw new PersistenceException("Cannot retrieve list of playlist items", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Playlist) retrievePlaylistsWithMedia(MediaFileType mediaType, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of Playlists for %s (from=%s, count=%s) [%s]", cast(Object[])[ mediaType, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT playlist.id as id, file_types, title, file_path, date_updated, playlist.repository_id as repository_id,all_items_found FROM playlist " + accessGroupTable(accessGroup) + "WHERE LOCATE(?,file_types) > 0 " + accessGroupConditionForPlaylist(accessGroup) + "ORDER BY title " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, mediaType.toString());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of Playlists for %s", cast(Object[])[ mediaType ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int getPlaylistsWithMediaCount(MediaFileType mediaType, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of playlists for %s [%s]", cast(Object[])[ mediaType, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT COUNT(playlist.id) as c FROM playlist " + accessGroupTable(accessGroup) + "WHERE LOCATE(?,file_types) > 0" + accessGroupConditionForPlaylist(accessGroup));

      ps.setString(1, mediaType.toString());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException("Cannot read number of playlists", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  private void deletePlaylist(Connection con, final Long playlistId)
  {
    try
    {
      (new class() JdbcExecutor!(Object)
      {
        protected PreparedStatement processStatement(Connection con)
        {
          PreparedStatement ps = con.prepareStatement("DELETE FROM playlist WHERE id = ?");
          ps.setLong(1, playlistId.longValue());
          ps.executeUpdate();
          return ps;
        }
      })
      .executeUpdate();
    }
    catch (SQLException e)
    {
      throw new PersistenceException(String.format("Cannot delete Playlist with id = %s", cast(Object[])[ playlistId ]), e);
    }
  }

  protected Playlist mapSingleResult(ResultSet rs)
  {
    if (rs.next()) {
      return initPlaylist(rs);
    }
    return null;
  }

  protected List!(Playlist) mapResultSet(ResultSet rs)
  {
    List!(Playlist) result = new ArrayList!(Playlist)();
    while (rs.next()) {
      result.add(initPlaylist(rs));
    }
    return result;
  }

  private Playlist initPlaylist(ResultSet rs) {
    Long id = Long.valueOf(rs.getLong("id"));
    String title = rs.getString("title");
    String filePath = rs.getString("file_path");
    String fileTypesCSV = rs.getString("file_types");
    bool allItemsFound = rs.getBoolean("all_items_found");
    Long repositoryId = JdbcUtils.getLongFromResultSet(rs, "repository_id");
    Date dateUpdated = rs.getTimestamp("date_updated");

    Playlist playlist = new Playlist(title, MediaFileType.parseMediaFileTypesFromString(fileTypesCSV), filePath, dateUpdated, repositoryId);
    playlist.setId(id);
    playlist.setAllItemsFound(allItemsFound);

    return playlist;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.PlaylistDAOImpl
 * JD-Core Version:    0.6.2
 */