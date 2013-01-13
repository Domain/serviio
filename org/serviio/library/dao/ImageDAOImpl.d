module org.serviio.library.dao.ImageDAOImpl;

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
import org.serviio.dlna.ImageContainer;
import org.serviio.dlna.SamplingMode;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Image;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.util.JdbcUtils;
import org.serviio.util.ObjectValidator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ImageDAOImpl : AbstractSortableItemDao
  , ImageDAO
{
  private static final Logger log = LoggerFactory.getLogger!(ImageDAOImpl);

  public long create(Image newInstance)
  {
    if (newInstance is null) {
      throw new InvalidArgumentException("Cannot create Image. Required data is missing.");
    }
    log.debug_(String.format("Creating a new Image (name = %s)", cast(Object[])[ newInstance.getTitle() ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("INSERT INTO media_item (file_type, title, file_size, file_name, folder_id,container, creation_date, description, sort_title, width, height, color_depth, cover_image_id, rotation, file_path, repository_id, subsampling) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", 1);

      ps.setString(1, MediaFileType.IMAGE.toString());
      ps.setString(2, JdbcUtils.trimToMaxLength(newInstance.getTitle(), 128));
      ps.setLong(3, newInstance.getFileSize().longValue());
      ps.setString(4, newInstance.getFileName());
      JdbcUtils.setLongValueOnStatement(ps, 5, newInstance.getFolderId());
      ps.setString(6, newInstance.getContainer().toString());
      JdbcUtils.setTimestampValueOnStatement(ps, 7, newInstance.getDate());
      JdbcUtils.setStringValueOnStatement(ps, 8, newInstance.getDescription());
      ps.setString(9, JdbcUtils.trimToMaxLength(createSortName(newInstance.getTitle()), 128));
      JdbcUtils.setIntValueOnStatement(ps, 10, newInstance.getWidth());
      JdbcUtils.setIntValueOnStatement(ps, 11, newInstance.getHeight());
      JdbcUtils.setIntValueOnStatement(ps, 12, newInstance.getColorDepth());
      JdbcUtils.setLongValueOnStatement(ps, 13, newInstance.getThumbnailId());
      JdbcUtils.setIntValueOnStatement(ps, 14, newInstance.getRotation());
      ps.setString(15, newInstance.getFilePath());
      JdbcUtils.setLongValueOnStatement(ps, 16, newInstance.getRepositoryId());
      JdbcUtils.setStringValueOnStatement(ps, 17, newInstance.getChromaSubsampling() !is null ? newInstance.getChromaSubsampling().toString() : null);

      ps.executeUpdate();
      return JdbcUtils.retrieveGeneratedID(ps);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot create Image with name %s", cast(Object[])[ newInstance.getTitle() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void delete_(Long id)
  {
    log.debug_(String.format("Deleting an Image (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("DELETE FROM media_item WHERE id = ?");
      ps.setLong(1, id.longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot delete Image with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public Image read(Long id)
  {
    log.debug_(String.format("Reading an Image (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, title, sort_title, file_size, file_name, folder_id, container, creation_date, description, width, height, color_depth, cover_image_id, last_viewed_date, number_viewed, rotation, dirty, file_path, repository_id, subsampling FROM media_item WHERE id = ?");

      ps.setLong(1, id.longValue());
      ResultSet rs = ps.executeQuery();
      return mapSingleResult(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read Image with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void update(Image transientObject)
  {
    if ((transientObject is null) || (transientObject.getId() is null) || (ObjectValidator.isEmpty(transientObject.getTitle())) || (ObjectValidator.isEmpty(transientObject.getFileName())) || (transientObject.getFileSize() is null) || (transientObject.getFolderId() is null))
    {
      throw new InvalidArgumentException("Cannot update Image. Required data is missing.");
    }
    log.debug_(String.format("Updating Image (id = %s)", cast(Object[])[ transientObject.getId() ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("UPDATE media_item SET title = ?, file_size = ?, file_name = ?, folder_id = ?, container =?, creation_date = ?, description = ?, width = ?, height = ?, color_depth = ?, sort_title = ?, cover_image_id = ?, rotation = ?, file_path = ?, repository_id = ?, subsampling = ?, dirty = ? WHERE id = ?");

      ps.setString(1, JdbcUtils.trimToMaxLength(transientObject.getTitle(), 128));
      ps.setLong(2, transientObject.getFileSize().longValue());
      ps.setString(3, transientObject.getFileName());
      JdbcUtils.setLongValueOnStatement(ps, 4, transientObject.getFolderId());
      ps.setString(5, transientObject.getContainer().toString());
      JdbcUtils.setTimestampValueOnStatement(ps, 6, transientObject.getDate());
      JdbcUtils.setStringValueOnStatement(ps, 7, transientObject.getDescription());
      JdbcUtils.setIntValueOnStatement(ps, 8, transientObject.getWidth());
      JdbcUtils.setIntValueOnStatement(ps, 9, transientObject.getHeight());
      JdbcUtils.setIntValueOnStatement(ps, 10, transientObject.getColorDepth());
      ps.setString(11, JdbcUtils.trimToMaxLength(createSortName(transientObject.getTitle()), 128));
      JdbcUtils.setLongValueOnStatement(ps, 12, transientObject.getThumbnailId());
      JdbcUtils.setIntValueOnStatement(ps, 13, transientObject.getRotation());
      ps.setString(14, transientObject.getFilePath());
      JdbcUtils.setLongValueOnStatement(ps, 15, transientObject.getRepositoryId());
      JdbcUtils.setStringValueOnStatement(ps, 16, transientObject.getChromaSubsampling() !is null ? transientObject.getChromaSubsampling().toString() : null);
      ps.setInt(17, transientObject.isDirty() ? 1 : 0);

      ps.setLong(18, transientObject.getId().longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot update Image with id %s", cast(Object[])[ transientObject.getId() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Image) retrieveImagesForFolder(Long folderId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of images for folder %s (from=%s, count=%s) [%s]", cast(Object[])[ folderId, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT media_item.id as id, title, sort_title, file_size, file_name, folder_id, container, creation_date, description, width, height, color_depth, cover_image_id, last_viewed_date, number_viewed, rotation, file_path, media_item.repository_id as repository_id, subsampling, dirty FROM media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ? AND folder_id = ? " + accessGroupConditionForMediaItem(accessGroup) + "ORDER BY lower(file_name) " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, MediaFileType.IMAGE.toString());
      ps.setLong(2, folderId.longValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of images for folder %s", cast(Object[])[ folderId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveImagesForFolderCount(Long folderId, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of images for folder %s [%s]", cast(Object[])[ folderId, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT count(media_item.id) as c FROM media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ? AND folder_id = ?" + accessGroupConditionForMediaItem(accessGroup));

      ps.setString(1, MediaFileType.IMAGE.toString());
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
      throw new PersistenceException(String.format("Cannot read number of images for folder %s", cast(Object[])[ folderId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Image) retrieveImagesForPlaylist(Long playlistId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of images for Playlist %s (from=%s, count=%s) [%s]", cast(Object[])[ playlistId, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT media_item.id as id, title, sort_title, file_size, file_name, folder_id, container, creation_date, description, width, height, color_depth, cover_image_id, last_viewed_date, number_viewed, rotation, file_path, media_item.repository_id as repository_id, subsampling, dirty FROM media_item, playlist_item p " + accessGroupTable(accessGroup) + "WHERE p.media_item_id = media_item.id AND file_type = ? and p.playlist_id = ? " + accessGroupConditionForMediaItem(accessGroup) + "ORDER BY p.item_order " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, MediaFileType.IMAGE.toString());
      ps.setLong(2, playlistId.longValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of images for playlist %s", cast(Object[])[ playlistId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveImagesForPlaylistCount(Long playlistId, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of images for playlist %s [%s]", cast(Object[])[ playlistId, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT count(media_item.id) as c FROM media_item, playlist_item p " + accessGroupTable(accessGroup) + "WHERE p.media_item_id = media_item.id AND p.playlist_id = ? AND media_item.file_type = ?" + accessGroupConditionForMediaItem(accessGroup));

      ps.setLong(1, playlistId.longValue());
      ps.setString(2, MediaFileType.IMAGE.toString());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of images for playlist %s", cast(Object[])[ playlistId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Integer) retrieveImagesCreationYears(AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of images' years (from=%s, count=%s) [%s]", cast(Object[])[ Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT distinct YEAR(creation_date) as creation_year FROM media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ? " + accessGroupConditionForMediaItem(accessGroup) + "ORDER BY creation_year desc " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, MediaFileType.IMAGE.toString());
      ResultSet rs = ps.executeQuery();
      List!(Integer) years = new ArrayList!(Integer)();
      while (rs.next()) {
        years.add(Integer.valueOf(rs.getInt("creation_year")));
      }
      return years;
    } catch (SQLException e) {
      throw new PersistenceException("Cannot read list of images' years", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveImagesCreationYearsCount(AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of images' years [%s]", cast(Object[])[ accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT count(distinct YEAR(creation_date)) as c FROM media_item" + accessGroupTable(accessGroup) + "WHERE file_type = ?" + accessGroupConditionForMediaItem(accessGroup));

      ps.setString(1, MediaFileType.IMAGE.toString());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException("Cannot read number of images' years", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Image) retrieveImagesForYear(Integer year, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of images for year %s (from=%s, count=%s) [%s]", cast(Object[])[ year, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT media_item.id as id, title, sort_title, file_size, file_name, folder_id, container, creation_date, description, width, height, color_depth, cover_image_id, last_viewed_date, number_viewed, rotation, file_path, media_item.repository_id as repository_id, subsampling, dirty FROM media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ? and YEAR(creation_date) = ? " + accessGroupConditionForMediaItem(accessGroup) + "ORDER BY creation_date, lower(sort_title) " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, MediaFileType.IMAGE.toString());
      ps.setInt(2, year.intValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of images for year %s", cast(Object[])[ year ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveImagesForYearCount(Integer year, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of images for year %s [%s]", cast(Object[])[ year, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT count(media_item.id) as c FROM media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ? and year(creation_date) = ?" + accessGroupConditionForMediaItem(accessGroup));

      ps.setString(1, MediaFileType.IMAGE.toString());
      ps.setInt(2, year.intValue());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of images for year %s", cast(Object[])[ year ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Integer) retrieveImagesCreationMonths(Integer year, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of creation date months for year %s (from=%s, count=%s) [%s]", cast(Object[])[ year, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT distinct MONTH(creation_date) as creation_month FROM media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ? and YEAR(creation_date) = ? " + accessGroupConditionForMediaItem(accessGroup) + "ORDER BY creation_month " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, MediaFileType.IMAGE.toString());
      ps.setInt(2, year.intValue());
      ResultSet rs = ps.executeQuery();
      List!(Integer) months = new ArrayList!(Integer)();
      while (rs.next()) {
        months.add(Integer.valueOf(rs.getInt("creation_month")));
      }
      return months;
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of creation date months for year %s", cast(Object[])[ year ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveImagesCreationMonthsCount(Integer year, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of  creation date months for year %s [%s]", cast(Object[])[ year, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT count(distinct MONTH(creation_date)) as c FROM media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ? and year(creation_date) = ?" + accessGroupConditionForMediaItem(accessGroup));

      ps.setString(1, MediaFileType.IMAGE.toString());
      ps.setInt(2, year.intValue());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of creation date months for year %s", cast(Object[])[ year ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Image) retrieveImagesForMonthOfYear(Integer month, Integer year, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of images for year %s and month %s (from=%s, count=%s) [%s]", cast(Object[])[ year, month, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT media_item.id as id, title, sort_title, file_size, file_name, folder_id, container, creation_date, description, width, height, color_depth, cover_image_id, last_viewed_date, number_viewed, rotation, file_path, media_item.repository_id as repository_id, subsampling, dirty FROM media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ? and YEAR(creation_date) = ? and MONTH(creation_date) = ? " + accessGroupConditionForMediaItem(accessGroup) + "ORDER BY creation_date, lower(sort_title) " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, MediaFileType.IMAGE.toString());
      ps.setInt(2, year.intValue());
      ps.setInt(3, month.intValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of images for year %s and month %s", cast(Object[])[ year, month ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveImagesForMonthOfYearCount(Integer month, Integer year, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of images for year %s and month %s [%s]", cast(Object[])[ year, month, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT count(media_item.id) as c FROM media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ? and year(creation_date) = ? and month(creation_date) = ?" + accessGroupConditionForMediaItem(accessGroup));

      ps.setString(1, MediaFileType.IMAGE.toString());
      ps.setInt(2, year.intValue());
      ps.setInt(3, month.intValue());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of images for year %s and month %s", cast(Object[])[ year, month ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Image) retrieveAllImages(AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of all images (from=%s, count=%s) [%s]", cast(Object[])[ Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT media_item.id as id, title, sort_title, file_size, file_name, folder_id, container, creation_date, description, width, height, color_depth, cover_image_id, last_viewed_date, number_viewed, rotation, file_path, media_item.repository_id as repository_id, subsampling, dirty FROM media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ? " + accessGroupConditionForMediaItem(accessGroup) + "ORDER BY creation_date, lower(file_name) " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, MediaFileType.IMAGE.toString());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException("Cannot read list of all images", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrieveAllImagesCount(AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of all images [%s]", cast(Object[])[ accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT count(media_item.id) as c FROM media_item " + accessGroupTable(accessGroup) + "WHERE file_type = ?" + accessGroupConditionForMediaItem(accessGroup));

      ps.setString(1, MediaFileType.IMAGE.toString());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException("Cannot read number of all images", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  protected Image mapSingleResult(ResultSet rs)
  {
    if (rs.next()) {
      return initImage(rs);
    }
    return null;
  }

  protected List!(Image) mapResultSet(ResultSet rs)
  {
    List!(Image) result = new ArrayList!(Image)();
    while (rs.next()) {
      result.add(initImage(rs));
    }
    return result;
  }

  private Image initImage(ResultSet rs) {
    Long id = Long.valueOf(rs.getLong("id"));
    String title = rs.getString("title");
    String sortTitle = rs.getString("sort_title");
    Long fileSize = JdbcUtils.getLongFromResultSet(rs, "file_size");
    String fileName = rs.getString("file_name");
    String filePath = rs.getString("file_path");
    Long folderId = Long.valueOf(rs.getLong("folder_id"));
    Long repositoryId = Long.valueOf(rs.getLong("repository_id"));
    ImageContainer container = rs.getString("container") !is null ? ImageContainer.valueOf(rs.getString("container")) : null;
    Date date = rs.getTimestamp("creation_date");
    String description = rs.getString("description");
    Integer width = JdbcUtils.getIntFromResultSet(rs, "width");
    Integer height = JdbcUtils.getIntFromResultSet(rs, "height");
    Integer colorDepth = JdbcUtils.getIntFromResultSet(rs, "color_depth");
    Long thumbnailId = JdbcUtils.getLongFromResultSet(rs, "cover_image_id");
    Date lastViewed = rs.getTimestamp("last_viewed_date");
    Integer numberViewed = Integer.valueOf(rs.getInt("number_viewed"));
    Integer rotation = Integer.valueOf(rs.getInt("rotation"));
    SamplingMode chromaSubsampling = rs.getString("subsampling") !is null ? SamplingMode.valueOf(rs.getString("subsampling")) : null;
    bool dirty = rs.getBoolean("dirty");

    Image image = new Image(title, container, fileName, filePath, fileSize, folderId, repositoryId, date);
    image.setId(id);
    image.setSortTitle(sortTitle);
    image.setDescription(description);
    image.setWidth(width);
    image.setHeight(height);
    image.setColorDepth(colorDepth);
    image.setThumbnailId(thumbnailId);
    image.setLastViewedDate(lastViewed);
    image.setNumberViewed(numberViewed);
    image.setRotation(rotation);
    image.setChromaSubsampling(chromaSubsampling);
    image.setDirty(dirty);

    return image;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.ImageDAOImpl
 * JD-Core Version:    0.6.2
 */