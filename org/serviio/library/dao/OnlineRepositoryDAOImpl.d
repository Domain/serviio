module org.serviio.library.dao.OnlineRepositoryDAOImpl;

import java.net.MalformedURLException;
import java.net.URL;
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
import org.serviio.library.entities.OnlineRepository;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.util.JdbcUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class OnlineRepositoryDAOImpl : AbstractAccessibleDao
  , OnlineRepositoryDAO
{
  private static final Logger log = LoggerFactory.getLogger!(OnlineRepositoryDAOImpl)();

  public long create(OnlineRepository newInstance)
  {
    if ((newInstance is null) || (newInstance.getRepositoryUrl() is null) || (newInstance.getFileType() is null) || (newInstance.getRepoType() is null)) {
      throw new InvalidArgumentException("Cannot create OnlineRepository. Required data is missing.");
    }
    log.debug_(String.format("Creating a new Repository (url = %s)", cast(Object[])[ newInstance.getRepositoryUrl().toString() ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("INSERT INTO online_repository (repo_type, file_type, url, thumbnail_url, name, enabled, order_number) VALUES (?,?,?,?,?,?,?)", 1);
      ps.setString(1, newInstance.getRepoType().toString());
      ps.setString(2, newInstance.getFileType().toString());
      ps.setString(3, newInstance.getRepositoryUrl());
      JdbcUtils.setURLValueOnStatement(ps, 4, newInstance.getThumbnailUrl());
      ps.setString(5, newInstance.getRepositoryName());
      ps.setBoolean(6, newInstance.isEnabled());
      ps.setInt(7, newInstance.getOrder().intValue());
      ps.executeUpdate();
      Long repoId = Long.valueOf(JdbcUtils.retrieveGeneratedID(ps));

      log.debug_("Adding Access Groups to the new OnlineRepository");
      foreach (Long accessGroupId ; newInstance.getAccessGroupIds()) {
        addAccessGroup(con, repoId, accessGroupId);
      }
      return repoId.longValue();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot create OnlineRepository for url %s", cast(Object[])[ newInstance.getRepositoryUrl().toString() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void delete_(Long id)
  {
    log.debug_(String.format("Deleting an OnlineRepository (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();

      removeAllAccessGroupsFromRepository(con, id);

      ps = con.prepareStatement("DELETE FROM online_repository WHERE id = ?");
      ps.setLong(1, id.longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot delete OnlineRepository with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public OnlineRepository read(Long id)
  {
    log.debug_(String.format("Reading an OnlineRepository (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, repo_type, file_type, url, thumbnail_url, name, enabled, order_number FROM online_repository WHERE id = ?");
      ps.setLong(1, id.longValue());
      ResultSet rs = ps.executeQuery();
      return mapSingleResult(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read OnlineRepository with id = %s", cast(Object[])[ id ]), e);
    } catch (MalformedURLException e) {
      throw new PersistenceException(String.format("Cannot read OnlineRepository with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void update(OnlineRepository transientObject)
  {
    if ((transientObject is null) || (transientObject.getId() is null) || (transientObject.getRepositoryUrl() is null) || (transientObject.getFileType() is null) || (transientObject.getRepoType() is null))
    {
      throw new InvalidArgumentException("Cannot update OnlineRepository. Required data is missing.");
    }
    log.debug_(String.format("Updating OnlineRepository (id = %s)", cast(Object[])[ transientObject.getId() ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("UPDATE online_repository SET repo_type = ?, file_type = ?, url = ?, thumbnail_url = ?, name = ?, enabled = ?, order_number = ? WHERE id = ?");
      ps.setString(1, transientObject.getRepoType().toString());
      ps.setString(2, transientObject.getFileType().toString());
      ps.setString(3, transientObject.getRepositoryUrl());
      JdbcUtils.setURLValueOnStatement(ps, 4, transientObject.getThumbnailUrl());
      ps.setString(5, transientObject.getRepositoryName());
      ps.setBoolean(6, transientObject.isEnabled());
      ps.setInt(7, transientObject.getOrder().intValue());
      ps.setLong(8, transientObject.getId().longValue());
      ps.executeUpdate();

      removeAllAccessGroupsFromRepository(con, transientObject.getId());
      foreach (Long accessGroupId ; transientObject.getAccessGroupIds())
        addAccessGroup(con, transientObject.getId(), accessGroupId);
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot update OnlineRepository with id %s", cast(Object[])[ transientObject.getId() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(OnlineRepository) findAll()
  {
    log.debug_("Reading all OnlineRepositories");
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, repo_type, file_type, url, thumbnail_url, name, enabled, order_number FROM online_repository ORDER BY order_number");
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException("Cannot retrieve list of OnlineRepositories", e);
    } catch (MalformedURLException e) {
      throw new PersistenceException("Cannot retrieve list of OnlineRepositories", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(OnlineRepository) getRepositories(List!(OnlineRepository.OnlineRepositoryType) repoTypes, MediaFileType fileType, AccessGroup accessGroup, bool onlyEnabled)
  {
    log.debug_(String.format("Retrieving list of %s OnlineRepositories for %s [%s]", cast(Object[])[ repoTypes, fileType, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      String query = "SELECT online_repository.id as id, repo_type, file_type, url, thumbnail_url, name, enabled, order_number FROM online_repository " + onlineAccessGroupTable(accessGroup) + "WHERE file_type = ? and repo_type in (" + JdbcUtils.createInClause(repoTypes.size()) + ") " + accessGroupConditionForOnlineRepository(accessGroup);

      if (onlyEnabled) {
        query = query + "and enabled = 1 ";
      }
      query = query + "ORDER BY order_number ";
      ps = con.prepareStatement(query);
      ps.setString(1, fileType.toString());
      for (int i = 0; i < repoTypes.size(); i++) {
        ps.setString(i + 2, (cast(OnlineRepository.OnlineRepositoryType)repoTypes.get(i)).toString());
      }
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of OnlineRepositories for %s", cast(Object[])[ fileType ]), e);
    } catch (MalformedURLException e) {
      throw new PersistenceException(String.format("Cannot read list of OnlineRepositories for %s", cast(Object[])[ fileType ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  private void addAccessGroup(Connection con, Long repositoryId, Long accessGroupId)
  {
    PreparedStatement ps = null;
    try {
      ps = con.prepareStatement("INSERT INTO online_repository_access_group (online_repository_id, access_group_id) VALUES (?,?)", 1);
      ps.setLong(1, repositoryId.longValue());
      ps.setLong(2, accessGroupId.longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException("Cannot add AccessGroup", e);
    } finally {
      JdbcUtils.closeStatement(ps);
    }
  }

  private void removeAllAccessGroupsFromRepository(Connection con, Long repositoryId) {
    PreparedStatement ps = null;
    try {
      ps = con.prepareStatement("DELETE FROM online_repository_access_group WHERE online_repository_id = ?");
      ps.setLong(1, repositoryId.longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException("Cannot add AccessGroup", e);
    } finally {
      JdbcUtils.closeStatement(ps);
    }
  }

  protected OnlineRepository mapSingleResult(ResultSet rs)
  {
    if (rs.next()) {
      return initRepository(rs);
    }
    return null;
  }

  protected List!(OnlineRepository) mapResultSet(ResultSet rs)
  {
    List!(OnlineRepository) result = new ArrayList!(OnlineRepository)();
    while (rs.next()) {
      result.add(initRepository(rs));
    }
    return result;
  }

  private OnlineRepository initRepository(ResultSet rs) {
    Long id = Long.valueOf(rs.getLong("id"));
    String contentUrl = rs.getString("url");
    MediaFileType fileType = MediaFileType.valueOf(rs.getString("file_type"));
    OnlineRepository.OnlineRepositoryType repoType = OnlineRepository.OnlineRepositoryType.valueOf(rs.getString("repo_type"));
    URL thumbnailUrl = JdbcUtils.getURLFromResultSet(rs, "thumbnail_url");
    String name = rs.getString("name");
    bool enabled = rs.getBoolean("enabled");
    Integer order = Integer.valueOf(rs.getInt("order_number"));

    OnlineRepository repository = new OnlineRepository(repoType, contentUrl, fileType, name, order);
    repository.setId(id);
    repository.setThumbnailUrl(thumbnailUrl);
    repository.setEnabled(enabled);
    return repository;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.OnlineRepositoryDAOImpl
 * JD-Core Version:    0.6.2
 */