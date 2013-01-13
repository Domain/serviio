module org.serviio.library.dao.RepositoryDAOImpl;

import java.io.File;
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
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Repository;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.util.JdbcUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RepositoryDAOImpl : AbstractAccessibleDao
  , RepositoryDAO
{
  private static final Logger log = LoggerFactory.getLogger!(RepositoryDAOImpl);

  public long create(Repository newInstance)
  {
    if ((newInstance is null) || (newInstance.getFolder() is null) || (newInstance.getAccessGroupIds() is null) || (newInstance.getAccessGroupIds().size() == 0)) {
      throw new InvalidArgumentException("Cannot create Repository. Required data is missing.");
    }
    log.debug_(String.format("Creating a new Repository (folder = %s)", cast(Object[])[ newInstance.getFolder() ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("INSERT INTO repository (folder,file_types,online_metadata_supported,scan_for_updates) VALUES (?,?,?,?)", 1);
      ps.setString(1, newInstance.getFolder().getAbsolutePath());
      ps.setString(2, MediaFileType.parseMediaFileTypesToString(newInstance.getSupportedFileTypes()));
      ps.setBoolean(3, newInstance.isSupportsOnlineMetadata());
      ps.setBoolean(4, newInstance.isKeepScanningForUpdates());
      ps.executeUpdate();
      Long repoId = Long.valueOf(JdbcUtils.retrieveGeneratedID(ps));

      log.debug_("Adding Access Groups to the new Repository");
      foreach (Long accessGroupId ; newInstance.getAccessGroupIds()) {
        addAccessGroup(con, repoId, accessGroupId);
      }
      return repoId.longValue();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot create Repository for folder %s", cast(Object[])[ newInstance.getFolder() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void delete_(Long id)
  {
    log.debug_(String.format("Deleting a Repository (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();

      removeAllAccessGroupsFromRepository(con, id);

      ps = con.prepareStatement("DELETE FROM repository WHERE id = ?");
      ps.setLong(1, id.longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot delete Repository with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public Repository read(Long id)
  {
    log.debug_(String.format("Reading a Repository (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, folder, file_types, online_metadata_supported, scan_for_updates, last_scanned FROM repository WHERE id = ?");
      ps.setLong(1, id.longValue());
      ResultSet rs = ps.executeQuery();
      return mapSingleResult(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read Repository with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void update(Repository transientObject)
  {
    if ((transientObject is null) || (transientObject.getId() is null) || (transientObject.getFolder() is null) || (transientObject.getAccessGroupIds() is null) || (transientObject.getAccessGroupIds().size() == 0))
    {
      throw new InvalidArgumentException("Cannot update Repository. Required data is missing.");
    }
    log.debug_(String.format("Updating Repository (id = %s)", cast(Object[])[ transientObject.getId() ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("UPDATE repository SET folder = ?, file_types = ?, online_metadata_supported = ?, scan_for_updates = ? WHERE id = ?");
      ps.setString(1, transientObject.getFolder().getAbsolutePath());
      ps.setString(2, MediaFileType.parseMediaFileTypesToString(transientObject.getSupportedFileTypes()));
      ps.setBoolean(3, transientObject.isSupportsOnlineMetadata());
      ps.setBoolean(4, transientObject.isKeepScanningForUpdates());

      ps.setLong(5, transientObject.getId().longValue());
      ps.executeUpdate();

      removeAllAccessGroupsFromRepository(con, transientObject.getId());
      foreach (Long accessGroupId ; transientObject.getAccessGroupIds())
        addAccessGroup(con, transientObject.getId(), accessGroupId);
    }
    catch (SQLException e)
    {
      throw new PersistenceException(String.format("Cannot update Repository with id %s", cast(Object[])[ transientObject.getId() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void markRepositoryAsScanned(Long repoId)
  {
    if (repoId is null) {
      throw new InvalidArgumentException("Cannot mark Repository as scanned. Required id is missing.");
    }
    log.debug_(String.format("Marking Repository %s as scanned with current timestamp", cast(Object[])[ repoId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("UPDATE repository SET last_scanned = ? WHERE id = ?");
      JdbcUtils.setTimestampValueOnStatement(ps, 1, new Date());

      ps.setLong(2, repoId.longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot mark Repository with id %s as scanned", cast(Object[])[ repoId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Repository) findAll()
  {
    log.debug_("Reading all Repositories");
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, folder, file_types, online_metadata_supported, scan_for_updates, last_scanned FROM repository ORDER BY id");
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException("Cannot retrieve list of Repositories", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Repository) getRepositories(MediaFileType fileType, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of Repositories for %s (from=%s, count=%s) [%s]", cast(Object[])[ fileType, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT repository.id as id, folder, file_types, online_metadata_supported, scan_for_updates, last_scanned FROM repository " + accessGroupTable(accessGroup) + "WHERE LOCATE(?,file_types) > 0 " + accessGroupConditionForRepository(accessGroup) + "ORDER BY id " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, fileType.toString());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of Repositories for %s", cast(Object[])[ fileType ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int getRepositoriesCount(MediaFileType fileType, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of repositories for %s [%s]", cast(Object[])[ fileType, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT COUNT(repository.id) as c FROM repository " + accessGroupTable(accessGroup) + "WHERE LOCATE(?,file_types) > 0" + accessGroupConditionForRepository(accessGroup));

      ps.setString(1, fileType.toString());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of repositories for %s", cast(Object[])[ fileType ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  private void addAccessGroup(Connection con, Long repositoryId, Long accessGroupId)
  {
    PreparedStatement ps = null;
    try {
      ps = con.prepareStatement("INSERT INTO repository_access_group (repository_id, access_group_id) VALUES (?,?)", 1);
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
      ps = con.prepareStatement("DELETE FROM repository_access_group WHERE repository_id = ?");
      ps.setLong(1, repositoryId.longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException("Cannot add AccessGroup", e);
    } finally {
      JdbcUtils.closeStatement(ps);
    }
  }

  protected Repository mapSingleResult(ResultSet rs)
  {
    if (rs.next()) {
      return initRepository(rs);
    }
    return null;
  }

  protected List!(Repository) mapResultSet(ResultSet rs)
  {
    List!(Repository) result = new ArrayList!(Repository)();
    while (rs.next()) {
      result.add(initRepository(rs));
    }
    return result;
  }

  private Repository initRepository(ResultSet rs) {
    Long id = Long.valueOf(rs.getLong("id"));
    String folder = rs.getString("folder");
    String fileTypesCSV = rs.getString("file_types");
    bool onlineMetadataSupported = rs.getBoolean("online_metadata_supported");
    bool scanForUpdates = rs.getBoolean("scan_for_updates");
    Date lastScanned = rs.getTimestamp("last_scanned");
    Repository repository = new Repository(new File(folder), MediaFileType.parseMediaFileTypesFromString(fileTypesCSV), onlineMetadataSupported, scanForUpdates);
    repository.setId(id);
    repository.setLastScanned(lastScanned);
    return repository;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.RepositoryDAOImpl
 * JD-Core Version:    0.6.2
 */