module org.serviio.config.dao.ConfigEntryDAOImpl;

import java.lang.String;
import java.lang.Long;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import org.serviio.config.entities.ConfigEntry;
import org.serviio.db.DatabaseManager;
import org.serviio.db.dao.InvalidArgumentException;
import org.serviio.db.dao.PersistenceException;
import org.serviio.util.JdbcUtils;
import org.serviio.util.ObjectValidator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.serviio.config.dao.ConfigEntryDAO;

public class ConfigEntryDAOImpl
  : ConfigEntryDAO
{
  private static immutable Logger log = LoggerFactory.getLogger!(ConfigEntryDAOImpl);

  public long create(ConfigEntry newInstance)
  {
    if ((newInstance is null) || (ObjectValidator.isEmpty(newInstance.getName()))) {
      throw new InvalidArgumentException("Cannot create ConfigEntry. Required data is missing.");
    }
    log.debug_(String.format("Creating a new ConfigEntry (name = %s, value = %s)", cast(Object[])[ newInstance.getName(), newInstance.getValue() ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("INSERT INTO config (name, value) VALUES (?,?)", 1);
      ps.setString(1, newInstance.getName());
      ps.setString(2, newInstance.getValue());
      ps.executeUpdate();
      return JdbcUtils.retrieveGeneratedID(ps);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot create ConfigEntry with name %s", cast(Object[])[ newInstance.getName() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void delete_(Long id)
  {
    log.debug_(String.format("Deleting a ConfigEntry (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("DELETE FROM config WHERE id = ?");
      ps.setLong(1, id.longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot delete ConfigEntry with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public ConfigEntry read(Long id)
  {
    log.debug_(String.format("Reading a ConfigEntry (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, name, value FROM config where id = ?");
      ps.setLong(1, id.longValue());
      ResultSet rs = ps.executeQuery();
      return mapSingleResult(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read ConfigEntry with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void update(ConfigEntry transientObject)
  {
    if ((transientObject is null) || (transientObject.getId() is null) || (ObjectValidator.isEmpty(transientObject.getName()))) {
      throw new InvalidArgumentException("Cannot update ConfigEntry. Required data is missing.");
    }
    log.debug_(String.format("Updating ConfigEntry (name = %s, value = %s)", cast(Object[])[ transientObject.getName(), transientObject.getValue() ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("UPDATE config SET value = ? WHERE id = ?");
      ps.setString(1, transientObject.getValue());
      ps.setLong(2, transientObject.getId().longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot update ConfigEntry with id %s", cast(Object[])[ transientObject.getId() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public ConfigEntry findConfigEntryByName(String name)
  {
    log.debug_(String.format("Reading a ConfigEntry (name = %s)", cast(Object[])[ name ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, name, value FROM config where name = ?");
      ps.setString(1, name);
      ResultSet rs = ps.executeQuery();
      return mapSingleResult(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read ConfigEntry with name = %s", cast(Object[])[ name ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(ConfigEntry) findAllConfigEntries()
  {
    log.debug_("Reading all ConfigEntries");
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, name, value FROM config");
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException("Cannot read all ConfigEntries", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  protected ConfigEntry mapSingleResult(ResultSet rs)
  {
    if (rs.next()) {
      return initConfigEntry(rs);
    }
    return null;
  }

  protected List!(ConfigEntry) mapResultSet(ResultSet rs)
  {
    List!(ConfigEntry) result = new ArrayList!(ConfigEntry)();
    while (rs.next()) {
      result.add(initConfigEntry(rs));
    }
    return result;
  }

  private ConfigEntry initConfigEntry(ResultSet rs) {
    Long id = Long.valueOf(rs.getLong("id"));
    String name = rs.getString("name");
    String value = rs.getString("value");

    ConfigEntry entry = new ConfigEntry(name, value);
    entry.setId(id);

    return entry;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.config.dao.ConfigEntryDAOImpl
 * JD-Core Version:    0.6.2
 */