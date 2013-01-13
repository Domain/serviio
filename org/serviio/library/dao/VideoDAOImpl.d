module org.serviio.library.dao.VideoDAOImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.serviio.db.DatabaseManager;
import org.serviio.db.dao.InvalidArgumentException;
import org.serviio.db.dao.PersistenceException;
import org.serviio.dlna.AudioCodec;
import org.serviio.dlna.H264Profile;
import org.serviio.dlna.VideoCodec;
import org.serviio.dlna.VideoContainer;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Person : RoleType;
import org.serviio.library.entities.Video;
import org.serviio.library.local.ContentType;
import org.serviio.library.local.H264LevelType;
import org.serviio.library.local.OnlineDBIdentifier;
import org.serviio.library.local.metadata.TransportStreamTimestamp;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.util.JdbcUtils;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class VideoDAOImpl : AbstractSortableItemDao
  , VideoDAO
{
  private static final Logger log = LoggerFactory.getLogger!(VideoDAOImpl);

  public long create(Video newInstance)
  {
    if ((newInstance is null) || (ObjectValidator.isEmpty(newInstance.getTitle())) || (ObjectValidator.isEmpty(newInstance.getFileName())) || (newInstance.getFileSize() is null) || (newInstance.getFolderId() is null))
    {
      throw new InvalidArgumentException("Cannot create Video. Required data is missing.");
    }
    log.debug_(String.format("Creating a new Video (title = %s)", cast(Object[])[ newInstance.getTitle() ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("INSERT INTO media_item (file_type, title, genre_id, duration, file_size, file_name, folder_id, container, creation_date,cover_image_id, bitrate, description, sort_title, width, height, rating,order_number, season_number, series_id, acodec, vcodec, channels, fps, sample_frequency,content_type, timestamp_type, audio_bitrate, audio_stream_index, video_stream_index,h264_profile, h264_level, ftyp, file_path, repository_id, online_identifiers, sar, vfourcc) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", 1);

      ps.setString(1, MediaFileType.VIDEO.toString());
      ps.setString(2, JdbcUtils.trimToMaxLength(newInstance.getTitle(), 128));
      JdbcUtils.setLongValueOnStatement(ps, 3, newInstance.getGenreId());
      JdbcUtils.setIntValueOnStatement(ps, 4, newInstance.getDuration());
      ps.setLong(5, newInstance.getFileSize().longValue());
      ps.setString(6, newInstance.getFileName());
      JdbcUtils.setLongValueOnStatement(ps, 7, newInstance.getFolderId());
      ps.setString(8, newInstance.getContainer().toString());
      JdbcUtils.setTimestampValueOnStatement(ps, 9, newInstance.getDate());
      JdbcUtils.setLongValueOnStatement(ps, 10, newInstance.getThumbnailId());
      JdbcUtils.setIntValueOnStatement(ps, 11, newInstance.getBitrate());
      JdbcUtils.setStringValueOnStatement(ps, 12, newInstance.getDescription());
      ps.setString(13, JdbcUtils.trimToMaxLength(createSortName(newInstance.getTitle()), 128));
      JdbcUtils.setIntValueOnStatement(ps, 14, newInstance.getWidth());
      JdbcUtils.setIntValueOnStatement(ps, 15, newInstance.getHeight());
      JdbcUtils.setStringValueOnStatement(ps, 16, newInstance.getRating());
      JdbcUtils.setIntValueOnStatement(ps, 17, newInstance.getEpisodeNumber());
      JdbcUtils.setIntValueOnStatement(ps, 18, newInstance.getSeasonNumber());
      JdbcUtils.setLongValueOnStatement(ps, 19, newInstance.getSeriesId());
      JdbcUtils.setStringValueOnStatement(ps, 20, newInstance.getAudioCodec() !is null ? newInstance.getAudioCodec().toString() : null);
      JdbcUtils.setStringValueOnStatement(ps, 21, newInstance.getVideoCodec().toString());
      JdbcUtils.setIntValueOnStatement(ps, 22, newInstance.getChannels());
      JdbcUtils.setStringValueOnStatement(ps, 23, JdbcUtils.trimToMaxLength(newInstance.getFps(), 10));
      JdbcUtils.setIntValueOnStatement(ps, 24, newInstance.getFrequency());
      JdbcUtils.setStringValueOnStatement(ps, 25, newInstance.getContentType().toString());
      JdbcUtils.setStringValueOnStatement(ps, 26, newInstance.getTimestampType() !is null ? newInstance.getTimestampType().toString() : null);
      JdbcUtils.setIntValueOnStatement(ps, 27, newInstance.getAudioBitrate());
      JdbcUtils.setIntValueOnStatement(ps, 28, newInstance.getAudioStreamIndex());
      JdbcUtils.setIntValueOnStatement(ps, 29, newInstance.getVideoStreamIndex());
      JdbcUtils.setStringValueOnStatement(ps, 30, newInstance.getH264Profile() !is null ? newInstance.getH264Profile().toString() : null);
      JdbcUtils.setStringValueOnStatement(ps, 31, H264LevelType.parseToString(newInstance.getH264Levels()));
      JdbcUtils.setStringValueOnStatement(ps, 32, newInstance.getFtyp());
      ps.setString(33, newInstance.getFilePath());
      JdbcUtils.setLongValueOnStatement(ps, 34, newInstance.getRepositoryId());
      JdbcUtils.setStringValueOnStatement(ps, 35, OnlineDBIdentifier.parseToString(newInstance.getOnlineIdentifiers()));
      JdbcUtils.setStringValueOnStatement(ps, 36, newInstance.getSar());
      JdbcUtils.setStringValueOnStatement(ps, 37, JdbcUtils.trimToMaxLength(newInstance.getVideoFourCC(), 6));
      ps.executeUpdate();
      return JdbcUtils.retrieveGeneratedID(ps);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot create Video with title %s", cast(Object[])[ newInstance.getTitle() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void delete_(Long id)
  {
    log.debug_(String.format("Deleting a Video (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("DELETE FROM media_item WHERE id = ?");
      ps.setLong(1, id.longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot delete Video with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public Video read(Long id)
  {
    log.debug_(String.format("Reading a Video (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, title, sort_title, genre_id, duration, file_size, file_name, folder_id, container, creation_date, cover_image_id, bitrate, description, width, height, rating, order_number, season_number, series_id, last_viewed_date, number_viewed, dirty, acodec, vcodec, channels,fps, sample_frequency, content_type, timestamp_type, audio_bitrate, audio_stream_index, video_stream_index,h264_profile, h264_level, bookmark, ftyp, file_path, repository_id, online_identifiers, sar, vfourcc FROM media_item WHERE id = ?");

      ps.setLong(1, id.longValue());
      ResultSet rs = ps.executeQuery();
      return mapSingleResult(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read Video with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void update(Video transientObject)
  {
    if ((transientObject is null) || (transientObject.getId() is null) || (ObjectValidator.isEmpty(transientObject.getTitle())) || (ObjectValidator.isEmpty(transientObject.getFileName())) || (transientObject.getFileSize() is null) || (transientObject.getFolderId() is null))
    {
      throw new InvalidArgumentException("Cannot update Video. Required data is missing.");
    }
    log.debug_(String.format("Updating Video (id = %s)", cast(Object[])[ transientObject.getId() ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("UPDATE media_item SET title = ?, file_size = ?, file_name = ?, folder_id = ?, container =?, creation_date = ?, description = ?, width = ?, height = ?, genre_id = ?, duration = ?, bitrate = ?, rating = ?, sort_title = ?, cover_image_id = ?, order_number = ?, season_number = ?, series_id = ?, dirty = ?, acodec = ?, vcodec = ?, channels = ?, fps = ?, sample_frequency = ?, content_type = ?, timestamp_type = ?, audio_bitrate = ?,audio_stream_index = ?, video_stream_index = ?, h264_profile = ?, h264_level = ?, ftyp = ?, file_path = ?,repository_id = ?, online_identifiers = ?, sar = ?, vfourcc = ? WHERE id = ?");

      ps.setString(1, JdbcUtils.trimToMaxLength(transientObject.getTitle(), 128));
      ps.setLong(2, transientObject.getFileSize().longValue());
      ps.setString(3, transientObject.getFileName());
      JdbcUtils.setLongValueOnStatement(ps, 4, transientObject.getFolderId());
      ps.setString(5, transientObject.getContainer().toString());
      JdbcUtils.setTimestampValueOnStatement(ps, 6, transientObject.getDate());
      JdbcUtils.setStringValueOnStatement(ps, 7, transientObject.getDescription());
      JdbcUtils.setIntValueOnStatement(ps, 8, transientObject.getWidth());
      JdbcUtils.setIntValueOnStatement(ps, 9, transientObject.getHeight());
      JdbcUtils.setLongValueOnStatement(ps, 10, transientObject.getGenreId());
      JdbcUtils.setIntValueOnStatement(ps, 11, transientObject.getDuration());
      JdbcUtils.setIntValueOnStatement(ps, 12, transientObject.getBitrate());
      JdbcUtils.setStringValueOnStatement(ps, 13, transientObject.getRating());
      ps.setString(14, JdbcUtils.trimToMaxLength(createSortName(transientObject.getTitle()), 128));
      JdbcUtils.setLongValueOnStatement(ps, 15, transientObject.getThumbnailId());
      JdbcUtils.setIntValueOnStatement(ps, 16, transientObject.getEpisodeNumber());
      JdbcUtils.setIntValueOnStatement(ps, 17, transientObject.getSeasonNumber());
      JdbcUtils.setLongValueOnStatement(ps, 18, transientObject.getSeriesId());
      ps.setInt(19, transientObject.isDirty() ? 1 : 0);
      JdbcUtils.setStringValueOnStatement(ps, 20, transientObject.getAudioCodec() !is null ? transientObject.getAudioCodec().toString() : null);
      JdbcUtils.setStringValueOnStatement(ps, 21, transientObject.getVideoCodec().toString());
      JdbcUtils.setIntValueOnStatement(ps, 22, transientObject.getChannels());
      JdbcUtils.setStringValueOnStatement(ps, 23, JdbcUtils.trimToMaxLength(transientObject.getFps(), 10));
      JdbcUtils.setIntValueOnStatement(ps, 24, transientObject.getFrequency());
      JdbcUtils.setStringValueOnStatement(ps, 25, transientObject.getContentType().toString());
      JdbcUtils.setStringValueOnStatement(ps, 26, transientObject.getTimestampType() !is null ? transientObject.getTimestampType().toString() : null);
      JdbcUtils.setIntValueOnStatement(ps, 27, transientObject.getAudioBitrate());
      JdbcUtils.setIntValueOnStatement(ps, 28, transientObject.getAudioStreamIndex());
      JdbcUtils.setIntValueOnStatement(ps, 29, transientObject.getVideoStreamIndex());
      JdbcUtils.setStringValueOnStatement(ps, 30, transientObject.getH264Profile() !is null ? transientObject.getH264Profile().toString() : null);
      JdbcUtils.setStringValueOnStatement(ps, 31, H264LevelType.parseToString(transientObject.getH264Levels()));
      JdbcUtils.setStringValueOnStatement(ps, 32, transientObject.getFtyp());
      ps.setString(33, transientObject.getFilePath());
      JdbcUtils.setLongValueOnStatement(ps, 34, transientObject.getRepositoryId());
      JdbcUtils.setStringValueOnStatement(ps, 35, OnlineDBIdentifier.parseToString(transientObject.getOnlineIdentifiers()));
      JdbcUtils.setStringValueOnStatement(ps, 36, transientObject.getSar());
      JdbcUtils.setStringValueOnStatement(ps, 37, JdbcUtils.trimToMaxLength(transientObject.getVideoFourCC(), 6));
      ps.setLong(38, transientObject.getId().longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot update Video with id %s", cast(Object[])[ transientObject.getId() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Video) retrieveVideos(int type, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of videos of type %s (from=%s, count=%s) [%s]", cast(Object[])[ Integer.valueOf(type), Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT media_item.id as id, title, sort_title, genre_id, duration, file_size, file_name, folder_id, container, creation_date, cover_image_id, bitrate, description, width, height, rating, order_number, season_number, series_id, last_viewed_date, number_viewed, dirty, acodec, vcodec, channels, fps, sample_frequency, content_type, timestamp_type, audio_bitrate, audio_stream_index, video_stream_index,h264_profile, h264_level, bookmark, ftyp, file_path, media_item.repository_id as repository_id, online_identifiers, sar, vfourcc FROM media_item").append(accessGroupTable(accessGroup)).append(" WHERE file_type = ? ").append(movieTypeCondition(type)).append(accessGroupConditionForMediaItem(accessGroup)).append("ORDER BY lower(sort_title), lower(file_name) ").append("OFFSET ").append(startingIndex).append(" ROWS FETCH FIRST ").append(requestedCount).append(" ROWS ONLY").toString());

      ps.setString(1, MediaFileType.VIDEO.toString());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of videos of type %s", cast(Object[])[ Integer.valueOf(type) ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveVideosCount(int type, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of videos of type %s [%s]", cast(Object[])[ Integer.valueOf(type), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT count(media_item.id) as c FROM media_item").append(accessGroupTable(accessGroup)).append(" WHERE file_type = ? ").append(movieTypeCondition(type)).append(accessGroupConditionForMediaItem(accessGroup)).toString());

      ps.setString(1, MediaFileType.VIDEO.toString());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of videos of type %s", cast(Object[])[ Integer.valueOf(type) ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Video) retrieveVideosForFolder(Long folderId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of videos for folder %s (from=%s, count=%s) [%s]", cast(Object[])[ folderId, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT media_item.id as id, title, sort_title, genre_id, duration, file_size, file_name, folder_id, container, creation_date, cover_image_id, bitrate, description, width, height, rating, order_number, season_number, series_id, last_viewed_date, number_viewed, dirty, acodec, vcodec, channels, fps, sample_frequency, content_type, timestamp_type, audio_bitrate, audio_stream_index, video_stream_index,h264_profile, h264_level, bookmark, ftyp, file_path, media_item.repository_id as repository_id, online_identifiers, sar, vfourcc FROM media_item").append(accessGroupTable(accessGroup)).append(" WHERE file_type = ? AND folder_id = ? ").append(accessGroupConditionForMediaItem(accessGroup)).append("ORDER BY lower(file_name) ").append("OFFSET ").append(startingIndex).append(" ROWS FETCH FIRST ").append(requestedCount).append(" ROWS ONLY").toString());

      ps.setString(1, MediaFileType.VIDEO.toString());
      ps.setLong(2, folderId.longValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of videos for folder %s", cast(Object[])[ folderId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveVideosForFolderCount(Long folderId, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of videos for folder %s [%s]", cast(Object[])[ folderId, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT count(media_item.id) as c FROM media_item").append(accessGroupTable(accessGroup)).append("WHERE file_type = ? and folder_id = ?").append(accessGroupConditionForMediaItem(accessGroup)).toString());

      ps.setString(1, MediaFileType.VIDEO.toString());
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
      throw new PersistenceException(String.format("Cannot read number of videos for folder %s", cast(Object[])[ folderId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Video) retrieveVideosForPlaylist(Long playlistId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of videos for playlist %s (from=%s, count=%s) [%s]", cast(Object[])[ playlistId, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT media_item.id as id, title, sort_title, genre_id, duration, file_size, file_name, folder_id, container, creation_date, cover_image_id, bitrate, description, width, height, rating, order_number, season_number, series_id, last_viewed_date, number_viewed, dirty, acodec, vcodec, channels, fps, sample_frequency, content_type, timestamp_type, audio_bitrate, audio_stream_index, video_stream_index,h264_profile, h264_level, bookmark, ftyp, file_path, media_item.repository_id as repository_id, online_identifiers, sar, vfourcc, p.item_order FROM media_item, playlist_item p ").append(accessGroupTable(accessGroup)).append("WHERE p.media_item_id = media_item.id AND media_item.file_type = ? and p.playlist_id = ?").append(accessGroupConditionForMediaItem(accessGroup)).append("ORDER BY p.item_order ").append("OFFSET ").append(startingIndex).append(" ROWS FETCH FIRST ").append(requestedCount).append(" ROWS ONLY").toString());

      ps.setString(1, MediaFileType.VIDEO.toString());
      ps.setLong(2, playlistId.longValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of videos for playlist %s", cast(Object[])[ playlistId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveVideosForPlaylistCount(Long playlistId, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of videos for playlist %s [%s]", cast(Object[])[ playlistId, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT count(media_item.id) as c FROM media_item, playlist_item p ").append(accessGroupTable(accessGroup)).append("WHERE p.media_item_id = media_item.id AND p.playlist_id = ? AND media_item.file_type = ?").append(accessGroupConditionForMediaItem(accessGroup)).toString());

      ps.setLong(1, playlistId.longValue());
      ps.setString(2, MediaFileType.VIDEO.toString());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of videos for playlist %s", cast(Object[])[ playlistId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Video) retrieveVideosForGenre(Long genreId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of videos for genre %s (from=%s, count=%s) [%s]", cast(Object[])[ genreId, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT media_item.id as id, title, sort_title, genre_id, duration, file_size, file_name, folder_id, container, creation_date, cover_image_id, bitrate, description, width, height, rating, order_number, season_number, series_id, last_viewed_date, number_viewed, dirty, acodec, vcodec, channels, fps, sample_frequency, content_type, timestamp_type, audio_bitrate, audio_stream_index, video_stream_index,h264_profile, h264_level, bookmark, ftyp, file_path, media_item.repository_id as repository_id, online_identifiers, sar,vfourcc FROM media_item").append(accessGroupTable(accessGroup)).append("WHERE file_type = ? and genre_id = ? ").append(accessGroupConditionForMediaItem(accessGroup)).append("ORDER BY lower(sort_title), lower(file_name) ").append("OFFSET ").append(startingIndex).append(" ROWS FETCH FIRST ").append(requestedCount).append(" ROWS ONLY").toString());

      ps.setString(1, MediaFileType.VIDEO.toString());
      ps.setLong(2, genreId.longValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of videos for genre %s", cast(Object[])[ genreId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveVideosForGenreCount(Long genreId, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of videos for genre %s [%s]", cast(Object[])[ genreId, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT count(media_item.id) as c FROM media_item ").append(accessGroupTable(accessGroup)).append("WHERE file_type = ? and genre_id = ?").append(accessGroupConditionForMediaItem(accessGroup)).toString());

      ps.setString(1, MediaFileType.VIDEO.toString());
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
      throw new PersistenceException(String.format("Cannot read number of videos for genre %s", cast(Object[])[ genreId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Video) retrieveVideosForPerson(Long personId, RoleType role, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of videos for person %s with role %s (from=%s, count=%s) [%s]", cast(Object[])[ personId, role, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT DISTINCT(media_item.id) as id, title, sort_title, genre_id, duration, file_size, file_name, folder_id, container, creation_date, cover_image_id, bitrate, description, width, height, rating, order_number, season_number, series_id, last_viewed_date, number_viewed, dirty, acodec, vcodec, channels, fps, sample_frequency, content_type, timestamp_type, audio_bitrate, audio_stream_index, video_stream_index,h264_profile, h264_level, bookmark, ftyp, file_path, media_item.repository_id as repository_id, online_identifiers, sar, vfourcc FROM media_item, person_role r, person p ").append(accessGroupTable(accessGroup)).append("WHERE media_item.file_type = ? and p.id = r.person_id and r.media_item_id = media_item.id and p.id=? and r.role_type = ? ").append(accessGroupConditionForMediaItem(accessGroup)).append("ORDER BY lower(media_item.sort_title), lower(media_item.file_name) ").append("OFFSET ").append(startingIndex).append(" ROWS FETCH FIRST ").append(requestedCount).append(" ROWS ONLY").toString());

      ps.setString(1, MediaFileType.VIDEO.toString());
      ps.setLong(2, personId.longValue());
      ps.setString(3, role.toString());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of videos for person %s with role %s", cast(Object[])[ personId, role ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveVideosForPersonCount(Long personId, RoleType role, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of videos for person %s with role %s [%s]", cast(Object[])[ personId, role, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT count(DISTINCT(media_item.id)) as c FROM media_item, person_role r, person p ").append(accessGroupTable(accessGroup)).append("WHERE media_item.file_type = ? and p.id = r.person_id and r.media_item_id = media_item.id and p.id=? and r.role_type = ?").append(accessGroupConditionForMediaItem(accessGroup)).toString());

      ps.setString(1, MediaFileType.VIDEO.toString());
      ps.setLong(2, personId.longValue());
      ps.setString(3, role.toString());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of videos for person %s with role %s", cast(Object[])[ personId, role ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Video) retrieveVideosForSeriesSeason(Long seriesId, Integer season, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of videos for series %s season %s (from=%s, count=%s) [%s]", cast(Object[])[ seriesId, season, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT media_item.id as id, title, sort_title, genre_id, duration, file_size, file_name, folder_id, container, creation_date, cover_image_id, bitrate, description, width, height, rating, order_number, season_number, series_id, last_viewed_date, number_viewed, dirty, acodec, vcodec, channels, fps, sample_frequency, content_type, timestamp_type, audio_bitrate, audio_stream_index, video_stream_index,h264_profile, h264_level, bookmark, ftyp, file_path, media_item.repository_id as repository_id, online_identifiers, sar, vfourcc FROM media_item").append(accessGroupTable(accessGroup)).append("WHERE file_type = ? and series_id = ? and season_number = ? ").append(accessGroupConditionForMediaItem(accessGroup)).append("ORDER BY order_number, lower(file_name) ").append("OFFSET ").append(startingIndex).append(" ROWS FETCH FIRST ").append(requestedCount).append(" ROWS ONLY").toString());

      ps.setString(1, MediaFileType.VIDEO.toString());
      ps.setLong(2, seriesId.longValue());
      ps.setInt(3, season.intValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of videos for series %s season %s", cast(Object[])[ seriesId, season ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveVideosForSeriesSeasonCount(Long seriesId, Integer season, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of videos for series %s season %s [%s]", cast(Object[])[ seriesId, season, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT count(media_item.id) as c FROM media_item ").append(accessGroupTable(accessGroup)).append("WHERE file_type = ? and series_id = ? and season_number = ?").append(accessGroupConditionForMediaItem(accessGroup)).toString());

      ps.setString(1, MediaFileType.VIDEO.toString());
      ps.setLong(2, seriesId.longValue());
      ps.setInt(3, season.intValue());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of videos for series %s season %s", cast(Object[])[ seriesId, season ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(String) retrieveVideoInitials(AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of video initials (from=%s, count=%s) [%s]", cast(Object[])[ Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT DISTINCT upper(substr(sort_title,1,1)) as letter from media_item ").append(accessGroupTable(accessGroup)).append("WHERE file_type = ?").append(accessGroupConditionForMediaItem(accessGroup)).append("ORDER BY letter ").append("OFFSET ").append(startingIndex).append(" ROWS FETCH FIRST ").append(requestedCount).append(" ROWS ONLY").toString());

      ps.setString(1, MediaFileType.VIDEO.toString());
      ResultSet rs = ps.executeQuery();
      List!(String) result = new ArrayList!(String)();
      while (rs.next()) {
        result.add(rs.getString("letter"));
      }
      return result;
    } catch (SQLException e) {
      throw new PersistenceException("Cannot read list of video initials", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveVideoInitialsCount(AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of video initials [%s]", cast(Object[])[ accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT COUNT(DISTINCT upper(substr(sort_title,1,1))) as c from media_item ").append(accessGroupTable(accessGroup)).append("WHERE file_type = ?").append(accessGroupConditionForMediaItem(accessGroup)).toString());

      ps.setString(1, MediaFileType.VIDEO.toString());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException("Cannot read number of video initials", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Video) retrieveVideosForInitial(String initial, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of videos with initial %s (from=%s, count=%s) [%s]", cast(Object[])[ initial, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT media_item.id as id, title, sort_title, genre_id, duration, file_size, file_name, folder_id, container, creation_date, cover_image_id, bitrate, description, width, height, rating, order_number, season_number, series_id, last_viewed_date, number_viewed, dirty, acodec, vcodec, channels, fps, sample_frequency, content_type, timestamp_type, audio_bitrate, audio_stream_index, video_stream_index,h264_profile, h264_level, bookmark, ftyp, file_path, media_item.repository_id as repository_id, online_identifiers, sar, vfourcc FROM media_item").append(accessGroupTable(accessGroup)).append("WHERE file_type = ? and substr(upper(sort_title),1,1) = ? ").append(accessGroupConditionForMediaItem(accessGroup)).append("ORDER BY lower(sort_title), lower(file_name) ").append("OFFSET ").append(startingIndex).append(" ROWS FETCH FIRST ").append(requestedCount).append(" ROWS ONLY").toString());

      ps.setString(1, MediaFileType.VIDEO.toString());
      ps.setString(2, StringUtils.localeSafeToUppercase(initial));
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of videos with initial %s", cast(Object[])[ initial ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveVideosForInitialCount(String initial, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of videos with initial %s [%s]", cast(Object[])[ initial, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT count(media_item.id) as c FROM media_item ").append(accessGroupTable(accessGroup)).append("WHERE file_type = ? and substr(upper(sort_title),1,1) = ?").append(accessGroupConditionForMediaItem(accessGroup)).toString());

      ps.setString(1, MediaFileType.VIDEO.toString());
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
      throw new PersistenceException(String.format("Cannot read number of videos with initial %s", cast(Object[])[ initial ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Video) retrieveLastViewedVideos(int maxReturned, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of %s last viewed videos (from=%s, count=%s) [%s]", cast(Object[])[ Integer.valueOf(maxReturned), Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));

    int availableCount = maxReturned - startingIndex;
    if (availableCount < 0) {
      throw new InvalidArgumentException("Impossible request parameters.");
    }
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT media_item.id as id, title, sort_title, genre_id, duration, file_size, file_name, folder_id, container, creation_date, cover_image_id, bitrate, description, width, height, rating, order_number, season_number, series_id, last_viewed_date, number_viewed, dirty, acodec, vcodec, channels, fps, sample_frequency, content_type, timestamp_type, audio_bitrate, audio_stream_index, video_stream_index,h264_profile, h264_level, bookmark, ftyp, file_path, media_item.repository_id as repository_id, online_identifiers, sar, vfourcc FROM media_item ").append(accessGroupTable(accessGroup)).append("WHERE file_type = ? AND last_viewed_date IS NOT NULL ").append(accessGroupConditionForMediaItem(accessGroup)).append("ORDER BY last_viewed_date DESC ").append("OFFSET ").append(startingIndex).append(" ROWS FETCH FIRST ").append(requestedCount < availableCount ? requestedCount : availableCount).append(" ROWS ONLY").toString());

      ps.setString(1, MediaFileType.VIDEO.toString());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of %s last viewed videos", cast(Object[])[ Integer.valueOf(maxReturned) ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveLastViewedVideosCount(int maxReturned, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of %s last viewed videos [%s]", cast(Object[])[ Integer.valueOf(maxReturned), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT count(media_item.id) as c FROM media_item ").append(accessGroupTable(accessGroup)).append("WHERE file_type = ? AND last_viewed_date IS NOT NULL ").append(accessGroupConditionForMediaItem(accessGroup)).toString());

      ps.setString(1, MediaFileType.VIDEO.toString());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue() < maxReturned ? count.intValue() : maxReturned;
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of %s last viewed videos", cast(Object[])[ Integer.valueOf(maxReturned) ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Video) retrieveLastAddedVideos(int maxReturned, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of %s last added videos (from=%s, count=%s) [%s]", cast(Object[])[ Integer.valueOf(maxReturned), Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));

    int availableCount = maxReturned - startingIndex;
    if (availableCount < 0) {
      throw new InvalidArgumentException("Impossible request parameters.");
    }

    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement((new StringBuilder()).append("SELECT media_item.id as id, title, sort_title, genre_id, duration, file_size, file_name, folder_id, container, creation_date, cover_image_id, bitrate, description, width, height, rating, order_number, season_number, series_id, last_viewed_date, number_viewed, dirty, acodec, vcodec, channels, fps, sample_frequency, content_type, timestamp_type, audio_bitrate, audio_stream_index, video_stream_index,h264_profile, h264_level, bookmark, ftyp, file_path, media_item.repository_id as repository_id, online_identifiers, sar, vfourcc FROM media_item ").append(accessGroupTable(accessGroup)).append("WHERE file_type = ? ").append(accessGroupConditionForMediaItem(accessGroup)).append("ORDER BY date_added DESC ").append("OFFSET ").append(startingIndex).append(" ROWS FETCH FIRST ").append(requestedCount < availableCount ? requestedCount : availableCount).append(" ROWS ONLY").toString());

      ps.setString(1, MediaFileType.VIDEO.toString());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of %s last added videos", cast(Object[])[ Integer.valueOf(maxReturned) ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveLastAddedVideosCount(int maxReturned, AccessGroup userProfile)
  {
    log.debug_(String.format("Retrieving number of %s last added videos", cast(Object[])[ Integer.valueOf(maxReturned) ]));
    Integer count = Integer.valueOf(retrieveVideosCount(0, userProfile));
    return count.intValue() < maxReturned ? count.intValue() : maxReturned;
  }

  public Map!(Long, Integer) retrieveLastViewedEpisode(Long seriesId)
  {
    log.debug_(String.format("Retrieving last episode for series %s", cast(Object[])[ seriesId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id,season_number FROM media_item WHERE file_type = ? AND last_viewed_date IS NOT NULL AND series_id = ? ORDER BY last_viewed_date DESC FETCH FIRST 1 ROW ONLY");

      ps.setString(1, MediaFileType.VIDEO.toString());
      ps.setLong(2, seriesId.longValue());
      ResultSet rs = ps.executeQuery();
      Map!(Long, Integer) result;
      if (rs.next()) {
        result = new HashMap!(Long, Integer)();
        result.put(Long.valueOf(rs.getLong(1)), Integer.valueOf(rs.getInt(2)));
        return result;
      }
      return null;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read last episode for series %s", cast(Object[])[ seriesId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  protected Video mapSingleResult(ResultSet rs)
  {
    if (rs.next()) {
      return initVideo(rs);
    }
    return null;
  }

  protected List!(Video) mapResultSet(ResultSet rs)
  {
    List!(Video) result = new ArrayList!(Video)();
    while (rs.next()) {
      result.add(initVideo(rs));
    }
    return result;
  }

  private Video initVideo(ResultSet rs) {
    Long id = Long.valueOf(rs.getLong("id"));
    String title = rs.getString("title");
    String sortTitle = rs.getString("sort_title");
    Long genreId = Long.valueOf(rs.getLong("genre_id"));
    Integer duration = JdbcUtils.getIntFromResultSet(rs, "duration");
    Long fileSize = JdbcUtils.getLongFromResultSet(rs, "file_size");
    String fileName = rs.getString("file_name");
    String filePath = rs.getString("file_path");
    Long folderId = Long.valueOf(rs.getLong("folder_id"));
    Long repositoryId = Long.valueOf(rs.getLong("repository_id"));
    VideoContainer container = rs.getString("container") !is null ? VideoContainer.valueOf(rs.getString("container")) : null;
    VideoCodec vCodec = rs.getString("vcodec") !is null ? VideoCodec.valueOf(rs.getString("vcodec")) : null;
    AudioCodec aCodec = rs.getString("acodec") !is null ? AudioCodec.valueOf(rs.getString("acodec")) : null;
    Date date = rs.getTimestamp("creation_date");
    Long thumbnailId = JdbcUtils.getLongFromResultSet(rs, "cover_image_id");
    String description = rs.getString("description");
    Integer bitrate = JdbcUtils.getIntFromResultSet(rs, "bitrate");
    Integer width = JdbcUtils.getIntFromResultSet(rs, "width");
    Integer height = JdbcUtils.getIntFromResultSet(rs, "height");
    Integer channels = JdbcUtils.getIntFromResultSet(rs, "channels");
    Integer frequency = JdbcUtils.getIntFromResultSet(rs, "sample_frequency");
    String fps = rs.getString("fps");
    String rating = rs.getString("rating");
    ContentType contentType = rs.getString("content_type") !is null ? ContentType.valueOf(rs.getString("content_type")) : null;
    Integer episodeNumber = JdbcUtils.getIntFromResultSet(rs, "order_number");
    Integer seasonNumber = JdbcUtils.getIntFromResultSet(rs, "season_number");
    Long seriesId = JdbcUtils.getLongFromResultSet(rs, "series_id");
    Date lastViewed = rs.getTimestamp("last_viewed_date");
    Integer numberViewed = Integer.valueOf(rs.getInt("number_viewed"));
    TransportStreamTimestamp timestampType = rs.getString("timestamp_type") !is null ? TransportStreamTimestamp.valueOf(rs.getString("timestamp_type")) : null;
    Integer audioBitrate = JdbcUtils.getIntFromResultSet(rs, "audio_bitrate");
    Integer audioStreamIndex = JdbcUtils.getIntFromResultSet(rs, "audio_stream_index");
    Integer videoStreamIndex = JdbcUtils.getIntFromResultSet(rs, "video_stream_index");
    H264Profile h264Profile = rs.getString("h264_profile") !is null ? H264Profile.valueOf(rs.getString("h264_profile")) : null;
    String h264LevelsSCV = rs.getString("h264_level");
    String ftyp = rs.getString("ftyp");
    Integer bookmark = JdbcUtils.getIntFromResultSet(rs, "bookmark");
    String onlineIdentifiersCSV = rs.getString("online_identifiers");
    String sar = rs.getString("sar");
    String videoFourCC = rs.getString("vfourcc");
    bool dirty = rs.getBoolean("dirty");

    Video video = new Video(title, container, fileName, filePath, fileSize, folderId, repositoryId, date);
    video.setId(id);
    video.setSortTitle(sortTitle);
    video.setDuration(duration);
    video.setGenreId(genreId);
    video.setThumbnailId(thumbnailId);
    video.setDescription(description);
    video.setBitrate(bitrate);
    video.setWidth(width);
    video.setHeight(height);
    video.setChannels(channels);
    video.setFps(fps);
    video.setFrequency(frequency);
    video.setRating(rating);
    video.setEpisodeNumber(episodeNumber);
    video.setSeasonNumber(seasonNumber);
    video.setSeriesId(seriesId);
    video.setLastViewedDate(lastViewed);
    video.setNumberViewed(numberViewed);
    video.setAudioCodec(aCodec);
    video.setVideoCodec(vCodec);
    video.setContentType(contentType);
    video.setTimestampType(timestampType);
    video.setAudioBitrate(audioBitrate);
    video.setAudioStreamIndex(audioStreamIndex);
    video.setVideoStreamIndex(videoStreamIndex);
    video.setH264Profile(h264Profile);
    video.setH264Levels(H264LevelType.parseFromString(h264LevelsSCV));
    video.setBookmark(bookmark);
    video.setFtyp(ftyp);
    video.setSar(sar);
    video.setOnlineIdentifiers(OnlineDBIdentifier.parseFromString(onlineIdentifiersCSV));
    video.setVideoFourCC(videoFourCC);
    video.setDirty(dirty);

    return video;
  }

  private String movieTypeCondition(int type) {
    String seriesSegment = "";
    if (type == 2)
      seriesSegment = (new StringBuilder()).append("AND content_type = '").append(ContentType.MOVIE).append("' ").toString();
    else if (type == 1) {
      seriesSegment = (new StringBuilder()).append("AND content_type = '").append(ContentType.EPISODE).append("' ").toString();
    }
    return seriesSegment;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.VideoDAOImpl
 * JD-Core Version:    0.6.2
 */