module org.serviio.renderer.dao.RendererDAOImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import org.serviio.db.DatabaseManager;
import org.serviio.db.dao.InvalidArgumentException;
import org.serviio.db.dao.PersistenceException;
import org.serviio.renderer.entities.Renderer;
import org.serviio.util.JdbcUtils;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RendererDAOImpl
  : RendererDAO
{
  private static final Logger log = LoggerFactory.getLogger!(RendererDAOImpl)();

  public void create(Renderer newInstance)
  {
    if ((newInstance is null) || (ObjectValidator.isEmpty(newInstance.getUuid()))) {
      throw new InvalidArgumentException("Cannot create Renderer. Required data is missing.");
    }
    log.debug_(String.format("Creating a new Renderer (uuid = %s)", cast(Object[])[ newInstance.getUuid() ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("INSERT INTO renderer (uuid, name, ip_address, profile_id, manually_added, profile_forced, enabled, access_group_id) VALUES (?,?,?,?,?,?,?,?)");
      ps.setString(1, newInstance.getUuid());
      JdbcUtils.setStringValueOnStatement(ps, 2, newInstance.getName());
      JdbcUtils.setStringValueOnStatement(ps, 3, newInstance.getIpAddress());
      JdbcUtils.setStringValueOnStatement(ps, 4, newInstance.getProfileId());
      ps.setBoolean(5, newInstance.isManuallyAdded());
      ps.setBoolean(6, newInstance.isForcedProfile());
      ps.setBoolean(7, newInstance.isEnabled());
      JdbcUtils.setLongValueOnStatement(ps, 8, newInstance.getAccessGroupId());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot create Renderer with uuid %s", cast(Object[])[ newInstance.getUuid() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void delete_(String uuid)
  {
    log.debug_(String.format("Deleting a Renderer (uuid = %s)", cast(Object[])[ uuid ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("DELETE FROM renderer WHERE uuid = ?");
      ps.setString(1, uuid);
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot delete Renderer with uuid = %s", cast(Object[])[ uuid ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public Renderer read(String uuid)
  {
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT uuid,name,ip_address,profile_id,manually_added,profile_forced,enabled,access_group_id FROM renderer where lower(uuid) = ?");
      ps.setString(1, StringUtils.localeSafeToLowercase(uuid));
      ResultSet rs = ps.executeQuery();
      return mapSingleResult(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read Renderer with uuid = %s", cast(Object[])[ uuid ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void update(Renderer transientObject)
  {
    if ((transientObject is null) || (transientObject.getUuid() is null) || (transientObject.getIpAddress() is null)) {
      throw new InvalidArgumentException("Cannot update Renderer. Required data is missing.");
    }
    log.debug_(String.format("Updating Renderer (uuid = %s, ipAddress = %s)", cast(Object[])[ transientObject.getUuid(), transientObject.getIpAddress() ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("UPDATE renderer SET name = ?, ip_address = ?, profile_id = ?, manually_added = ?, profile_forced = ?, enabled = ?, access_group_id = ? WHERE uuid = ?");

      JdbcUtils.setStringValueOnStatement(ps, 1, transientObject.getName());
      JdbcUtils.setStringValueOnStatement(ps, 2, transientObject.getIpAddress());
      JdbcUtils.setStringValueOnStatement(ps, 3, transientObject.getProfileId());
      ps.setBoolean(4, transientObject.isManuallyAdded());
      ps.setBoolean(5, transientObject.isForcedProfile());
      ps.setBoolean(6, transientObject.isEnabled());
      JdbcUtils.setLongValueOnStatement(ps, 7, transientObject.getAccessGroupId());
      ps.setString(8, transientObject.getUuid());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot update Renderer with uuid %s", cast(Object[])[ transientObject.getUuid() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Renderer) findByIPAddress(String ipAddress) {
    log.debug_(String.format("Reading a Renderer with ip address %s", cast(Object[])[ ipAddress ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT uuid,name,ip_address,profile_id,manually_added,profile_forced,enabled,access_group_id FROM renderer where ip_address = ?");
      ps.setString(1, ipAddress);
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read Renderer with ip address %s", cast(Object[])[ ipAddress ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Renderer) findAll() {
    log.debug_("Retrieving list of all stored renderers");
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT uuid,name,ip_address,profile_id,manually_added,profile_forced,enabled,access_group_id FROM renderer");
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException("Cannot read list of all stored renderers", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  protected Renderer mapSingleResult(ResultSet rs)
  {
    if (rs.next()) {
      return initRenderer(rs);
    }
    return null;
  }

  protected List!(Renderer) mapResultSet(ResultSet rs)
  {
    List!(Renderer) result = new ArrayList!(Renderer)();
    while (rs.next()) {
      result.add(initRenderer(rs));
    }
    return result;
  }

  private Renderer initRenderer(ResultSet rs) {
    String uuid = rs.getString("uuid");
    String name = rs.getString("name");
    String ipAddress = rs.getString("ip_address");
    String profileId = rs.getString("profile_id");
    bool manuallyAdded = rs.getBoolean("manually_added");
    bool forcedprofile = rs.getBoolean("profile_forced");
    bool enabled = rs.getBoolean("enabled");
    Long accessGroupId = Long.valueOf(rs.getLong("access_group_id"));

    Renderer renderer = new Renderer(uuid, ipAddress, name, profileId, manuallyAdded, forcedprofile, enabled, accessGroupId);
    return renderer;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.renderer.dao.RendererDAOImpl
 * JD-Core Version:    0.6.2
 */