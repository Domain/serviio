module org.serviio.library.dao.MetadataExtractorConfigDAOImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import org.serviio.db.DatabaseManager;
import org.serviio.db.dao.InvalidArgumentException;
import org.serviio.db.dao.PersistenceException;
import org.serviio.library.entities.MetadataExtractorConfig;
import org.serviio.library.local.metadata.extractor.ExtractorType;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.util.JdbcUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MetadataExtractorConfigDAOImpl
  : MetadataExtractorConfigDAO
{
  private static final Logger log = LoggerFactory.getLogger!(MetadataExtractorConfigDAOImpl);

  public long create(MetadataExtractorConfig newInstance)
  {
    if ((newInstance is null) || (newInstance.getExtractorType() is null) || (newInstance.getOrderNumber() == 0) || (newInstance.getFileType() is null))
    {
      throw new InvalidArgumentException("Cannot create MetadataExtractorConfig. Required data is missing.");
    }
    log.debug_(String.format("Creating a new MetadataExtractorConfig (extractor = %s, file type = %s)", cast(Object[])[ newInstance.getExtractorType(), newInstance.getFileType() ]));

    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("INSERT INTO metadata_extractor_config (media_file_type, extractor_type, order_number) VALUES (?,?,?)", 1);

      ps.setString(1, newInstance.getFileType().toString());
      ps.setString(2, newInstance.getExtractorType().toString());
      ps.setInt(3, newInstance.getOrderNumber());
      ps.executeUpdate();
      return JdbcUtils.retrieveGeneratedID(ps);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot create MetadataExtractorConfig %s for file type %s", cast(Object[])[ newInstance.getExtractorType(), newInstance.getFileType() ]), e);
    }
    finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void delete_(Long id)
  {
    log.debug_(String.format("Deleting a MetadataExtractorConfig (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("DELETE FROM metadata_extractor_config WHERE id = ?");
      ps.setLong(1, id.longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot delete MetadataExtractorConfig with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(MetadataExtractorConfig) retrieveByMediaFileType(MediaFileType type)
  {
    log.debug_(String.format("Reading a list of Extractor configuration for type %s", cast(Object[])[ type.toString() ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, media_file_type, extractor_type, order_number FROM metadata_extractor_config where media_file_type = ? order by order_number");
      ps.setString(1, type.toString());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read a list of Extractor configuration for type %s", cast(Object[])[ type.toString() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  protected MetadataExtractorConfig mapSingleResult(ResultSet rs)
  {
    if (rs.next()) {
      return initConfig(rs);
    }
    return null;
  }

  protected List!(MetadataExtractorConfig) mapResultSet(ResultSet rs)
  {
    List!(MetadataExtractorConfig) result = new ArrayList!(MetadataExtractorConfig)();
    while (rs.next()) {
      result.add(initConfig(rs));
    }
    return result;
  }

  private MetadataExtractorConfig initConfig(ResultSet rs) {
    Long id = Long.valueOf(rs.getLong("id"));
    MediaFileType mediaType = MediaFileType.valueOf(rs.getString("media_file_type"));
    ExtractorType extractorType = ExtractorType.valueOf(rs.getString("extractor_type"));
    Integer orderNumber = JdbcUtils.getIntFromResultSet(rs, "order_number");

    MetadataExtractorConfig config = new MetadataExtractorConfig(mediaType, extractorType, orderNumber.intValue());
    config.setId(id);

    return config;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.MetadataExtractorConfigDAOImpl
 * JD-Core Version:    0.6.2
 */