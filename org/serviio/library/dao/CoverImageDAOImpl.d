module org.serviio.library.dao.CoverImageDAOImpl;

import java.lang.Long;
import java.io.ByteArrayInputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import org.serviio.db.DatabaseManager;
import org.serviio.db.dao.InvalidArgumentException;
import org.serviio.db.dao.PersistenceException;
import org.serviio.library.entities.CoverImage;
import org.serviio.util.JdbcUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.serviio.library.dao.CoverImageDAO;

public class CoverImageDAOImpl
  : CoverImageDAO
{
  private static immutable Logger log = LoggerFactory.getLogger!(CoverImageDAOImpl)();

  public long create(CoverImage newInstance)
  {
    if ((newInstance is null) || (newInstance.getImageBytes() is null)) {
      throw new InvalidArgumentException("Cannot create CoverImage. Required data is missing.");
    }
    log.debug_(String.format("Creating a new ImageCover (length = %s)", cast(Object[])[ Integer.valueOf(newInstance.getImageBytes().length) ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("INSERT INTO cover_image (image_data, mime_type, width, height) VALUES (?,?,?,?)", 1);

      ps.setBinaryStream(1, new ByteArrayInputStream(newInstance.getImageBytes()));
      ps.setString(2, newInstance.getMimeType());
      JdbcUtils.setIntValueOnStatement(ps, 3, Integer.valueOf(newInstance.getWidth()));
      JdbcUtils.setIntValueOnStatement(ps, 4, Integer.valueOf(newInstance.getHeight()));
      ps.executeUpdate();
      return JdbcUtils.retrieveGeneratedID(ps);
    } catch (SQLException e) {
      throw new PersistenceException("Cannot create CoverImage", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void delete_(Long id)
  {
    log.debug_(String.format("Deleting a CoverImage (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("DELETE FROM cover_image WHERE id = ?");
      ps.setLong(1, id.longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot delete CoverImage with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public CoverImage read(Long id)
  {
    log.debug_(String.format("Reading a CoverImage (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, image_data, mime_type, width, height FROM cover_image where id = ?");
      ps.setLong(1, id.longValue());
      ResultSet rs = ps.executeQuery();
      return mapSingleResult(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read CoverImage with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void update(CoverImage transientObject)
  {
    throw new UnsupportedOperationException("CoverImage update is not supported");
  }

  protected CoverImage mapSingleResult(ResultSet rs)
  {
    if (rs.next()) {
      Long id = Long.valueOf(rs.getLong("id"));
      byte[] allBytesInBlob = JdbcUtils.convertBlob(rs.getBlob("image_data"));
      String mimeType = rs.getString("mime_type");
      Integer width = Integer.valueOf(rs.getInt("width"));
      Integer height = Integer.valueOf(rs.getInt("height"));
      CoverImage coverImage = new CoverImage(allBytesInBlob, mimeType, width.intValue(), height.intValue());
      coverImage.setId(id);

      return coverImage;
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.CoverImageDAOImpl
 * JD-Core Version:    0.6.2
 */