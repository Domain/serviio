module org.serviio.library.dao.MetadataDescriptorDAOImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import org.serviio.db.DatabaseManager;
import org.serviio.db.dao.InvalidArgumentException;
import org.serviio.db.dao.PersistenceException;
import org.serviio.library.entities.MetadataDescriptor;
import org.serviio.library.local.metadata.extractor.ExtractorType;
import org.serviio.util.JdbcUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MetadataDescriptorDAOImpl
  : MetadataDescriptorDAO
{
  private static final Logger log = LoggerFactory.getLogger!(MetadataDescriptorDAOImpl);

  public long create(MetadataDescriptor newInstance)
  {
    if ((newInstance is null) || (newInstance.getExtractorType() is null) || (newInstance.getMediaItemId() is null) || (newInstance.getDateUpdated() is null))
    {
      throw new InvalidArgumentException("Cannot create MetadataDescriptor. Required data is missing.");
    }
    log.debug_(String.format("Creating a new MetadataDescriptor (type = %s, mediaItemId = %s)", cast(Object[])[ newInstance.getExtractorType(), newInstance.getMediaItemId() ]));

    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("INSERT INTO metadata_descriptor (extractor_type, date_updated, media_item_id, identifier) VALUES (?,?,?,?)", 1);

      ps.setString(1, newInstance.getExtractorType().toString());
      ps.setTimestamp(2, new Timestamp(newInstance.getDateUpdated().getTime()));
      ps.setLong(3, newInstance.getMediaItemId().longValue());
      JdbcUtils.setStringValueOnStatement(ps, 4, newInstance.getIdentifier());
      ps.executeUpdate();
      return JdbcUtils.retrieveGeneratedID(ps);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot create MetadataDescriptor with type %s for mediaItem %s", cast(Object[])[ newInstance.getExtractorType(), newInstance.getMediaItemId() ]), e);
    }
    finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void delete_(Long id)
  {
    log.debug_(String.format("Deleting a MetadataDescriptor (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("DELETE FROM metadata_descriptor WHERE id = ?");
      ps.setLong(1, id.longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot delete MetadataDescriptor with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public MetadataDescriptor read(Long id)
  {
    log.debug_(String.format("Reading a MetadataDescriptor (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, extractor_type, date_updated, media_item_id, identifier FROM metadata_descriptor where id = ?");
      ps.setLong(1, id.longValue());
      ResultSet rs = ps.executeQuery();
      return mapSingleResult(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read MetadataDescriptor with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void update(MetadataDescriptor transientObject)
  {
    throw new UnsupportedOperationException("MetadataDescriptor update is not supported");
  }

  public void removeMetadataDescriptorsForMedia(Long mediaItemId)
  {
    log.debug_(String.format("Deleting all MetadataDescriptors for MediaItem (id = %s)", cast(Object[])[ mediaItemId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("DELETE FROM metadata_descriptor WHERE media_item_id = ?");
      ps.setLong(1, mediaItemId.longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot delete all MetadataDescriptors for MediaItem id = %s", cast(Object[])[ mediaItemId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public MetadataDescriptor retrieveMetadataDescriptorForMedia(Long mediaItemId, ExtractorType extractorType)
  {
    log.debug_(String.format("Reading MetadataDescriptor for MediaItem (id = %s) and extractor %s", cast(Object[])[ mediaItemId, extractorType.toString() ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, extractor_type, date_updated, media_item_id, identifier FROM metadata_descriptor where media_item_id = ? and extractor_type = ?");
      ps.setLong(1, mediaItemId.longValue());
      ps.setString(2, extractorType.toString());
      ResultSet rs = ps.executeQuery();
      return mapSingleResult(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read MetadataDescriptor for MediaItem id = %s and extractor %s", cast(Object[])[ mediaItemId, extractorType.toString() ]), e);
    }
    finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  protected MetadataDescriptor mapSingleResult(ResultSet rs)
  {
    if (rs.next()) {
      return initDescriptor(rs);
    }
    return null;
  }

  protected List!(MetadataDescriptor) mapResultSet(ResultSet rs)
  {
    List!(MetadataDescriptor) result = new ArrayList!(MetadataDescriptor)();
    while (rs.next()) {
      result.add(initDescriptor(rs));
    }
    return result;
  }

  private MetadataDescriptor initDescriptor(ResultSet rs) {
    Long id = Long.valueOf(rs.getLong("id"));
    ExtractorType extractorType = ExtractorType.valueOf(rs.getString("extractor_type"));
    Date dateUpdated = rs.getTimestamp("date_updated");
    Long mediaItemId = Long.valueOf(rs.getLong("media_item_id"));
    String identifier = rs.getString("identifier");

    MetadataDescriptor descriptor = new MetadataDescriptor(extractorType, mediaItemId, dateUpdated, identifier);
    descriptor.setId(id);

    return descriptor;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.MetadataDescriptorDAOImpl
 * JD-Core Version:    0.6.2
 */