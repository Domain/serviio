module org.serviio.library.dao.MusicTrackDAOImpl;

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
import org.serviio.dlna.AudioContainer;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.MusicTrack;
import org.serviio.library.entities.Person : RoleType;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.util.JdbcUtils;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MusicTrackDAOImpl : AbstractSortableItemDao
  , MusicTrackDAO
{
  private static final Logger log = LoggerFactory.getLogger!(MusicTrackDAOImpl)();

  public long create(MusicTrack newInstance)
  {
    if ((newInstance is null) || (ObjectValidator.isEmpty(newInstance.getTitle())) || (ObjectValidator.isEmpty(newInstance.getFileName())) || (newInstance.getFileSize() is null) || (newInstance.getFolderId() is null))
    {
      throw new InvalidArgumentException("Cannot create MusicTrack. Required data is missing.");
    }
    log.debug_(String.format("Creating a new MusicTrack (title = %s)", cast(Object[])[ newInstance.getTitle() ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("INSERT INTO media_item (file_type, title, order_number, genre_id, duration, release_year, file_size, file_name, folder_id, album_id, container, creation_date,cover_image_id, audio_bitrate, description, channels, sample_frequency, sort_title, file_path, repository_id) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", 1);

      ps.setString(1, MediaFileType.AUDIO.toString());
      ps.setString(2, JdbcUtils.trimToMaxLength(newInstance.getTitle(), 128));
      JdbcUtils.setIntValueOnStatement(ps, 3, newInstance.getTrackNumber());
      JdbcUtils.setLongValueOnStatement(ps, 4, newInstance.getGenreId());
      JdbcUtils.setIntValueOnStatement(ps, 5, newInstance.getDuration());
      JdbcUtils.setIntValueOnStatement(ps, 6, newInstance.getReleaseYear());
      ps.setLong(7, newInstance.getFileSize().longValue());
      ps.setString(8, newInstance.getFileName());
      JdbcUtils.setLongValueOnStatement(ps, 9, newInstance.getFolderId());
      JdbcUtils.setLongValueOnStatement(ps, 10, newInstance.getAlbumId());
      ps.setString(11, newInstance.getContainer().toString());
      JdbcUtils.setTimestampValueOnStatement(ps, 12, newInstance.getDate());
      JdbcUtils.setLongValueOnStatement(ps, 13, newInstance.getThumbnailId());
      JdbcUtils.setIntValueOnStatement(ps, 14, newInstance.getBitrate());
      JdbcUtils.setStringValueOnStatement(ps, 15, newInstance.getDescription());
      JdbcUtils.setIntValueOnStatement(ps, 16, newInstance.getChannels());
      JdbcUtils.setIntValueOnStatement(ps, 17, newInstance.getSampleFrequency());
      ps.setString(18, JdbcUtils.trimToMaxLength(createSortName(newInstance.getTitle()), 128));
      ps.setString(19, newInstance.getFilePath());
      JdbcUtils.setLongValueOnStatement(ps, 20, newInstance.getRepositoryId());
      ps.executeUpdate();
      return JdbcUtils.retrieveGeneratedID(ps);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot create MusicTrack with title %s", cast(Object[])[ newInstance.getTitle() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void delete_(Long id)
  {
    log.debug_(String.format("Deleting a MusicTrack (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("DELETE FROM media_item WHERE id = ?");
      ps.setLong(1, id.longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot delete MusicTrack with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public MusicTrack read(Long id)
  {
    log.debug_(String.format("Reading a MusicTrack (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, title, sort_title, order_number, genre_id, duration, release_year, file_size, file_name, folder_id, album_id, container, creation_date, cover_image_id, audio_bitrate, description, channels, sample_frequency, last_viewed_date, number_viewed, file_path, dirty,bookmark, repository_id FROM media_item WHERE id = ?");

      ps.setLong(1, id.longValue());
      ResultSet rs = ps.executeQuery();
      return mapSingleResult(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read MusicTrack with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void update(MusicTrack transientObject)
  {
    if ((transientObject is null) || (transientObject.getId() is null) || (ObjectValidator.isEmpty(transientObject.getTitle())) || (ObjectValidator.isEmpty(transientObject.getFileName())) || (transientObject.getFileSize() is null) || (transientObject.getFolderId() is null))
    {
      throw new InvalidArgumentException("Cannot update MusicTrack. Required data is missing.");
    }
    log.debug_(String.format("Updating MusicTrack (id = %s)", cast(Object[])[ transientObject.getId() ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("UPDATE media_item SET title = ?, order_number = ?, genre_id = ?, duration = ?, release_year =?, file_size = ?, file_name = ?, folder_id = ?, album_id =?, container =?, creation_date = ?, cover_image_id = ?, audio_bitrate = ?, description = ?, channels = ?, sample_frequency = ?, sort_title = ?, file_path = ?, repository_id = ?, dirty = ? WHERE id = ?");

      ps.setString(1, JdbcUtils.trimToMaxLength(transientObject.getTitle(), 128));
      JdbcUtils.setIntValueOnStatement(ps, 2, transientObject.getTrackNumber());
      JdbcUtils.setLongValueOnStatement(ps, 3, transientObject.getGenreId());
      JdbcUtils.setIntValueOnStatement(ps, 4, transientObject.getDuration());
      JdbcUtils.setIntValueOnStatement(ps, 5, transientObject.getReleaseYear());
      ps.setLong(6, transientObject.getFileSize().longValue());
      ps.setString(7, transientObject.getFileName());
      JdbcUtils.setLongValueOnStatement(ps, 8, transientObject.getFolderId());
      JdbcUtils.setLongValueOnStatement(ps, 9, transientObject.getAlbumId());
      ps.setString(10, transientObject.getContainer().toString());
      JdbcUtils.setTimestampValueOnStatement(ps, 11, transientObject.getDate());
      JdbcUtils.setLongValueOnStatement(ps, 12, transientObject.getThumbnailId());
      JdbcUtils.setIntValueOnStatement(ps, 13, transientObject.getBitrate());
      JdbcUtils.setStringValueOnStatement(ps, 14, transientObject.getDescription());
      JdbcUtils.setIntValueOnStatement(ps, 15, transientObject.getChannels());
      JdbcUtils.setIntValueOnStatement(ps, 16, transientObject.getSampleFrequency());
      ps.setString(17, JdbcUtils.trimToMaxLength(createSortName(transientObject.getTitle()), 128));
      ps.setString(18, transientObject.getFilePath());
      JdbcUtils.setLongValueOnStatement(ps, 19, transientObject.getRepositoryId());
      ps.setInt(20, transientObject.isDirty() ? 1 : 0);

      ps.setLong(21, transientObject.getId().longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot update MusicTrack with id %s", cast(Object[])[ transientObject.getId() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(MusicTrack) retrieveMusicTracksForArtist(Long artistId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of music tracks for artist %s (from=%s, count=%s) [%s]", cast(Object[])[ artistId, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT media_item.id as id, media_item.title as title, media_item.sort_title as sort_title, order_number, genre_id,duration, release_year, file_size, file_name, folder_id, album_id, container, creation_date, cover_image_id, audio_bitrate, description, channels, sample_frequency, last_viewed_date, number_viewed, file_path, dirty, bookmark, media_item.repository_id as repository_id FROM media_item LEFT OUTER JOIN music_album a ON media_item.album_id = a.id, person_role r, person p " + accessGroupTable(accessGroup) + "WHERE media_item.file_type = ? and p.id = r.person_id and r.media_item_id = media_item.id and p.id=? AND r.role_type=? " + accessGroupConditionForMediaItem(accessGroup) + "ORDER BY lower(a.title), media_item.order_number, lower(media_item.sort_title) " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, MediaFileType.AUDIO.toString());
      ps.setLong(2, artistId.longValue());
      ps.setString(3, RoleType.ARTIST.toString());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of music tracks for artist %s", cast(Object[])[ artistId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveMusicTracksForArtistCount(Long artistId, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of music tracks for artist %s [%s]", cast(Object[])[ artistId, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT count(media_item.id) as c FROM media_item, person_role r, person p " + accessGroupTable(accessGroup) + "WHERE media_item.file_type = ? and p.id = r.person_id and r.media_item_id = media_item.id and p.id=? and r.role_type=?" + accessGroupConditionForMediaItem(accessGroup));

      ps.setString(1, MediaFileType.AUDIO.toString());
      ps.setLong(2, artistId.longValue());
      ps.setString(3, RoleType.ARTIST.toString());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of music tracks for artist %s", cast(Object[])[ artistId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(MusicTrack) retrieveMusicTracksForGenre(Long genreId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of music tracks for genre %s (from=%s, count=%s) [%s]", cast(Object[])[ genreId, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT media_item.id as id, title, sort_title, order_number, genre_id,duration, release_year, file_size, file_name, folder_id, album_id, container, creation_date, cover_image_id, audio_bitrate, description, channels, sample_frequency, last_viewed_date, number_viewed, file_path, dirty, bookmark, media_item.repository_id as repository_id FROM media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ? and genre_id = ? " + accessGroupConditionForMediaItem(accessGroup) + "ORDER BY lower(sort_title) " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, MediaFileType.AUDIO.toString());
      ps.setLong(2, genreId.longValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of music tracks for genre %s", cast(Object[])[ genreId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveMusicTracksForGenreCount(Long genreId, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of music tracks for genre %s [%s]", cast(Object[])[ genreId, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT count(media_item.id) as c FROM media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ? and genre_id = ?" + accessGroupConditionForMediaItem(accessGroup));

      ps.setString(1, MediaFileType.AUDIO.toString());
      ps.setLong(2, genreId.longValue());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of music tracks for genre %s", cast(Object[])[ genreId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(MusicTrack) retrieveMusicTracksForFolder(Long folderId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of music tracks for folder %s (from=%s, count=%s) [%s]", cast(Object[])[ folderId, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT media_item.id as id, title, sort_title, order_number, genre_id,duration, release_year, file_size, file_name, folder_id, album_id, container, creation_date, cover_image_id, audio_bitrate, description, channels, sample_frequency, last_viewed_date, number_viewed, file_path, dirty, bookmark, media_item.repository_id as repository_id FROM media_item" + accessGroupTable(accessGroup) + " WHERE file_type = ? and folder_id = ? " + accessGroupConditionForMediaItem(accessGroup) + "ORDER BY lower(file_name) " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, MediaFileType.AUDIO.toString());
      ps.setLong(2, folderId.longValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of music tracks for folder %s", cast(Object[])[ folderId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveMusicTracksForFolderCount(Long folderId, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of music tracks for folder %s [%s]", cast(Object[])[ folderId, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT count(media_item.id) as c FROM media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ? AND folder_id = ?" + accessGroupConditionForMediaItem(accessGroup));

      ps.setString(1, MediaFileType.AUDIO.toString());
      ps.setLong(2, folderId.longValue());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of music tracks for folder %s", cast(Object[])[ folderId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(String) retrieveMusicTracksInitials(AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of music track initials (from=%s, count=%s) [%s]", cast(Object[])[ Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT DISTINCT upper(substr(sort_title,1,1)) as letter from media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ? " + accessGroupConditionForMediaItem(accessGroup) + "ORDER BY letter " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, MediaFileType.AUDIO.toString());
      ResultSet rs = ps.executeQuery();
      List!(String) result = new ArrayList!(String)();
      while (rs.next()) {
        result.add(rs.getString("letter"));
      }
      return result;
    } catch (SQLException e) {
      throw new PersistenceException("Cannot read list of music track initials", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveMusicTracksInitialsCount(AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of music track initials [%s]", cast(Object[])[ accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT COUNT(DISTINCT upper(substr(sort_title,1,1))) as c from media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ?" + accessGroupConditionForMediaItem(accessGroup));

      ps.setString(1, MediaFileType.AUDIO.toString());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException("Cannot read number of music track initials", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(MusicTrack) retrieveMusicTracksForInitial(String initial, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of music tracks with initial %s (from=%s, count=%s) [%s]", cast(Object[])[ initial, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT media_item.id as id, title, sort_title, order_number, genre_id,duration, release_year, file_size, file_name, folder_id, album_id, container, creation_date, cover_image_id, audio_bitrate, description, channels, sample_frequency, last_viewed_date, number_viewed, file_path, dirty, bookmark, media_item.repository_id as repository_id FROM media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ? and substr(upper(sort_title),1,1) = ? " + accessGroupConditionForMediaItem(accessGroup) + "ORDER BY lower(sort_title) " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, MediaFileType.AUDIO.toString());
      ps.setString(2, StringUtils.localeSafeToUppercase(initial));
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of music tracks with initial %s", cast(Object[])[ initial ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveMusicTracksForInitialCount(String initial, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of music tracks with initial %s [%s]", cast(Object[])[ initial, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT count(media_item.id) as c FROM media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ? and substr(upper(sort_title),1,1) = ?" + accessGroupConditionForMediaItem(accessGroup));

      ps.setString(1, MediaFileType.AUDIO.toString());
      ps.setString(2, StringUtils.localeSafeToUppercase(initial));
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of music tracks with initial %s", cast(Object[])[ initial ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(MusicTrack) retrieveMusicTracksForAlbum(Long albumId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of music tracks for album %s (from=%s, count=%s) [%s]", cast(Object[])[ albumId, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT media_item.id as id, title, sort_title, order_number, genre_id,duration, release_year, file_size, file_name, folder_id, album_id, container, creation_date, cover_image_id, audio_bitrate, description, channels, sample_frequency, last_viewed_date, number_viewed, file_path, dirty, bookmark, media_item.repository_id as repository_id FROM media_item" + accessGroupTable(accessGroup) + "WHERE media_item.album_id=? " + accessGroupConditionForMediaItem(accessGroup) + "ORDER BY media_item.order_number, lower(media_item.sort_title) " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setLong(1, albumId.longValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of music tracks for album %s", cast(Object[])[ albumId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveMusicTracksForAlbumCount(Long albumId, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of music tracks for album %s [%s]", cast(Object[])[ albumId, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT count(media_item.id) as c FROM media_item" + accessGroupTable(accessGroup) + "WHERE media_item.album_id = ?" + accessGroupConditionForMediaItem(accessGroup));

      ps.setLong(1, albumId.longValue());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of music tracks for an album %s", cast(Object[])[ albumId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(MusicTrack) retrieveAllMusicTracks(AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of all music tracks (from=%s, count=%s) [%s]", cast(Object[])[ Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT media_item.id as id, title, sort_title, order_number, genre_id,duration, release_year, file_size, file_name, folder_id, album_id, container, creation_date, cover_image_id, audio_bitrate, description, channels, sample_frequency, last_viewed_date, number_viewed, file_path, dirty, bookmark, media_item.repository_id as repository_id FROM media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ? " + accessGroupConditionForMediaItem(accessGroup) + "ORDER BY lower(sort_title) " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, MediaFileType.AUDIO.toString());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException("Cannot read list  all music tracks for artist", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveAllMusicTracksCount(AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of all music tracks [%s]", cast(Object[])[ accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT count(media_item.id) as c FROM media_item " + accessGroupTable(accessGroup) + "WHERE media_item.file_type = ?" + accessGroupConditionForMediaItem(accessGroup));

      ps.setString(1, MediaFileType.AUDIO.toString());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException("Cannot read number of all music tracks", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(MusicTrack) retrieveRandomMusicTracks(int startingIndex, int requestedCount, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving list of random music tracks (start =%s, count=%s) [%s]", cast(Object[])[ Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT random() as r, media_item.id as id, title, sort_title, order_number, genre_id,duration, release_year, file_size, file_name, folder_id, album_id, container, creation_date, cover_image_id, audio_bitrate, description, channels, sample_frequency, last_viewed_date, number_viewed, file_path, dirty, bookmark, media_item.repository_id as repository_id FROM media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ? " + accessGroupConditionForMediaItem(accessGroup) + "ORDER BY r " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, MediaFileType.AUDIO.toString());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException("Cannot read list random music tracks", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveRandomMusicTracksCount(int max, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of random music tracks [%s]", cast(Object[])[ accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT count(media_item.id) as c FROM media_item " + accessGroupTable(accessGroup) + "WHERE media_item.file_type = ?" + accessGroupConditionForMediaItem(accessGroup));

      ps.setString(1, MediaFileType.AUDIO.toString());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return Math.min(count.intValue(), max);
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException("Cannot read number of random music tracks", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(MusicTrack) retrieveMusicTracksForTrackRoleAndAlbum(Long artistId, RoleType role, Long albumId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of music tracks for person %s with role %s on album %s (from=%s, count=%s) [%s]", cast(Object[])[ artistId, role, albumId, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));

    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT media_item.id as id, media_item.title, media_item.sort_title, order_number, genre_id,duration, release_year, file_size, file_name, folder_id, album_id, container, creation_date, cover_image_id, audio_bitrate, description, channels, sample_frequency, last_viewed_date, number_viewed, file_path, dirty, bookmark, media_item.repository_id as repository_id FROM media_item, person_role r, person p " + accessGroupTable(accessGroup) + "WHERE media_item.file_type = ? and p.id = r.person_id and r.media_item_id = media_item.id and p.id=? and r.role_type=? and media_item.album_id=? " + accessGroupConditionForMediaItem(accessGroup) + "ORDER BY media_item.order_number, lower(media_item.sort_title) " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, MediaFileType.AUDIO.toString());
      ps.setLong(2, artistId.longValue());
      ps.setString(3, role.toString());
      ps.setLong(4, albumId.longValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of music tracks for person %s with role %s on album %s", cast(Object[])[ artistId, role, albumId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveMusicTracksForTrackRoleAndAlbumCount(Long artistId, RoleType role, Long albumId, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of music tracks for person %s with role %s on album %s [%s]", cast(Object[])[ artistId, role, albumId, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT count(media_item.id) as c FROM media_item, person_role r, person p " + accessGroupTable(accessGroup) + "WHERE media_item.file_type = ? and p.id = r.person_id and r.media_item_id = media_item.id and p.id=? and r.role_type=? and media_item.album_id=?" + accessGroupConditionForMediaItem(accessGroup));

      ps.setString(1, MediaFileType.AUDIO.toString());
      ps.setLong(2, artistId.longValue());
      ps.setString(3, role.toString());
      ps.setLong(4, albumId.longValue());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of music tracks for person %s with role %s on album %s", cast(Object[])[ artistId, role, albumId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(MusicTrack) retrieveMusicTracksForPlaylist(Long playlistId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of music tracks for playlist %s (from=%s, count=%s) [%s]", cast(Object[])[ playlistId, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT media_item.id as id, title, sort_title, order_number, genre_id,duration, release_year, file_size, file_name, folder_id, album_id, container, creation_date, cover_image_id, audio_bitrate, description, channels, sample_frequency, last_viewed_date, number_viewed, file_path, dirty, bookmark, media_item.repository_id as repository_id FROM media_item, playlist_item p " + accessGroupTable(accessGroup) + "WHERE p.media_item_id = media_item.id AND media_item.file_type = ? and p.playlist_id = ? " + accessGroupConditionForMediaItem(accessGroup) + "ORDER BY p.item_order " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, MediaFileType.AUDIO.toString());
      ps.setLong(2, playlistId.longValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of music tracks for playlist %s", cast(Object[])[ playlistId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveMusicTracksForPlaylistCount(Long playlistId, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of music tracks for playlist %s [%s]", cast(Object[])[ playlistId, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT count(media_item.id) as c FROM media_item, playlist_item p " + accessGroupTable(accessGroup) + "WHERE p.media_item_id = media_item.id AND p.playlist_id = ? AND media_item.file_type = ?" + accessGroupConditionForMediaItem(accessGroup));

      ps.setLong(1, playlistId.longValue());
      ps.setString(2, MediaFileType.AUDIO.toString());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of music tracks for playlist %s", cast(Object[])[ playlistId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  protected MusicTrack mapSingleResult(ResultSet rs)
  {
    if (rs.next()) {
      return initMusicTrack(rs);
    }
    return null;
  }

  protected List!(MusicTrack) mapResultSet(ResultSet rs)
  {
    List!(MusicTrack) result = new ArrayList!(MusicTrack)();
    while (rs.next()) {
      result.add(initMusicTrack(rs));
    }
    return result;
  }

  private MusicTrack initMusicTrack(ResultSet rs) {
    Long id = Long.valueOf(rs.getLong("id"));
    String title = rs.getString("title");
    String sortTitle = rs.getString("sort_title");
    Long genreId = Long.valueOf(rs.getLong("genre_id"));
    Integer trackNumber = JdbcUtils.getIntFromResultSet(rs, "order_number");
    Integer duration = JdbcUtils.getIntFromResultSet(rs, "duration");
    Integer year = JdbcUtils.getIntFromResultSet(rs, "release_year");
    Long fileSize = JdbcUtils.getLongFromResultSet(rs, "file_size");
    String fileName = rs.getString("file_name");
    String filePath = rs.getString("file_path");
    Long folderId = Long.valueOf(rs.getLong("folder_id"));
    Long repositoryId = Long.valueOf(rs.getLong("repository_id"));
    AudioContainer container = rs.getString("container") !is null ? AudioContainer.valueOf(rs.getString("container")) : null;
    Long albumId = JdbcUtils.getLongFromResultSet(rs, "album_id");
    Date date = rs.getTimestamp("creation_date");
    Long albumArtId = JdbcUtils.getLongFromResultSet(rs, "cover_image_id");
    String description = rs.getString("description");
    Integer bitrate = JdbcUtils.getIntFromResultSet(rs, "audio_bitrate");
    Integer channels = JdbcUtils.getIntFromResultSet(rs, "channels");
    Integer sampleFrequency = JdbcUtils.getIntFromResultSet(rs, "sample_frequency");
    Date lastViewed = rs.getTimestamp("last_viewed_date");
    Integer numberViewed = Integer.valueOf(rs.getInt("number_viewed"));
    Integer bookmark = JdbcUtils.getIntFromResultSet(rs, "bookmark");
    bool dirty = rs.getBoolean("dirty");

    MusicTrack track = new MusicTrack(title, container, fileName, filePath, fileSize, folderId, repositoryId, date);
    track.setId(id);
    track.setSortTitle(sortTitle);
    track.setAlbumId(albumId);
    track.setDuration(duration);
    track.setGenreId(genreId);
    track.setTrackNumber(trackNumber);
    track.setReleaseYear(year);
    track.setThumbnailId(albumArtId);
    track.setDescription(description);
    track.setBitrate(bitrate);
    track.setChannels(channels);
    track.setSampleFrequency(sampleFrequency);
    track.setDirty(dirty);
    track.setLastViewedDate(lastViewed);
    track.setNumberViewed(numberViewed);
    track.setBookmark(bookmark);

    return track;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.MusicTrackDAOImpl
 * JD-Core Version:    0.6.2
 */