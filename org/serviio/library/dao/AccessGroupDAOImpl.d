module org.serviio.library.dao.AccessGroupDAOImpl;

import java.lang.Long;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import org.serviio.db.DatabaseManager;
import org.serviio.db.dao.InvalidArgumentException;
import org.serviio.db.dao.PersistenceException;
import org.serviio.library.entities.AccessGroup;
import org.serviio.util.JdbcUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.serviio.library.dao.AccessGroupDAO;

public class AccessGroupDAOImpl
  : AccessGroupDAO
{
  private static immutable Logger log = LoggerFactory.getLogger!(AccessGroupDAOImpl)();

  public long create(AccessGroup newInstance)
  {
    throw new RuntimeException("Operation not implemented");
  }

  public void delete_(Long id)
  {
    throw new RuntimeException("Operation not implemented");
  }

  public AccessGroup read(Long id)
  {
    log.debug_(String.format("Reading a AccessGroup (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, name FROM access_group WHERE id = ?");
      ps.setLong(1, id.longValue());
      ResultSet rs = ps.executeQuery();
      return mapSingleResult(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read AccessGroup with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void update(AccessGroup transientObject)
  {
    throw new RuntimeException("Operation not implemented");
  }

  public List!(AccessGroup) getAccessGroupsForRepository(Long repoId)
  {
    log.debug_(String.format("Reading all AccessGroups for Repository (id = %s)", cast(Object[])[ repoId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT up.id, up.name FROM access_group up, repository_access_group ap WHERE ap.access_group_id = up.id AND ap.repository_id = ?");
      ps.setLong(1, repoId.longValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read AccessGroups for repository id = %s", cast(Object[])[ repoId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(AccessGroup) getAccessGroupsForOnlineRepository(Long repoId)
  {
    log.debug_(String.format("Reading all AccessGroups for OnlineRepository (id = %s)", cast(Object[])[ repoId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT up.id, up.name FROM access_group up, online_repository_access_group ap WHERE ap.access_group_id = up.id AND ap.online_repository_id = ?");
      ps.setLong(1, repoId.longValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read AccessGroups for online repository id = %s", cast(Object[])[ repoId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(AccessGroup) findAll()
  {
    log.debug_("Reading all AccessGroups");
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT up.id, up.name FROM access_group up ORDER BY up.id");
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException("Cannot read all AccessGroups", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  protected AccessGroup mapSingleResult(ResultSet rs)
  {
    if (rs.next()) {
      return initUserProfile(rs);
    }
    return null;
  }

  protected List!(AccessGroup) mapResultSet(ResultSet rs)
  {
    List!(AccessGroup) result = new ArrayList!(AccessGroup)();
    while (rs.next()) {
      result.add(initUserProfile(rs));
    }
    return result;
  }

  private AccessGroup initUserProfile(ResultSet rs) {
    Long id = Long.valueOf(rs.getLong("id"));
    String name = rs.getString("name");

    AccessGroup profile = new AccessGroup(name);
    profile.setId(id);
    return profile;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.AccessGroupDAOImpl
 * JD-Core Version:    0.6.2
 */