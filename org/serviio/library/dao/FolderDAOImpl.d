module org.serviio.library.dao.FolderDAOImpl;

import java.lang.String;
import java.lang.Long;
import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;
import org.serviio.db.DatabaseManager;
import org.serviio.db.JdbcExecutor;
import org.serviio.db.dao.InvalidArgumentException;
import org.serviio.db.dao.PersistenceException;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Folder;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.util.JdbcUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.serviio.library.dao.AbstractAccessibleDao;
import org.serviio.library.dao.FolderDAO;

public class FolderDAOImpl : AbstractAccessibleDao
  , FolderDAO
{
  private static immutable Logger log = LoggerFactory.getLogger!(FolderDAOImpl)();

  public long create(Folder newInstance)
  {
    if ((newInstance is null) || (newInstance.getRepositoryId() is null)) {
      throw new InvalidArgumentException("Cannot create Folder. Required data is missing.");
    }
    log.debug_(String.format("Creating a new Folder (name = %s)", cast(Object[])[ newInstance.getName() ]));
    Connection con = null;
    try
    {
      con = DatabaseManager.getConnection();
      return create(con, newInstance);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot create Folder with name %s", cast(Object[])[ newInstance.getName() ]), e);
    } finally {
      DatabaseManager.releaseConnection(con);
    }
  }

  public void delete_(final Long id)
  {
    log.debug_(String.format("Deleting a Folder (id = %s)", cast(Object[])[ id ]));
    try
    {
      (new class() JdbcExecutor!(Object)
      {
        protected PreparedStatement processStatement(Connection con)
        {
          PreparedStatement ps = con.prepareStatement("DELETE FROM folder WHERE id = ?");
          ps.setLong(1, id.longValue());
          ps.executeUpdate();
          return ps;
        }
      })
      .executeUpdate();
    }
    catch (SQLException e)
    {
      throw new PersistenceException(String.format("Cannot delete Folder with id = %s", cast(Object[])[ id ]), e);
    }
  }

  public Folder read(Long id)
  {
    log.debug_(String.format("Reading a Folder (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, name, parent_folder_id, repository_id FROM folder where id = ?");
      ps.setLong(1, id.longValue());
      ResultSet rs = ps.executeQuery();
      return mapSingleResult(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read Folder with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void update(Folder transientObject)
  {
    throw new UnsupportedOperationException("Folder update is not supported");
  }

  public Long getOrCreateFolder(File folderPath, Long repositoryId)
  {
    String[] filePathElements = null;
    if (folderPath is null)
    {
      filePathElements = cast(String[])[ "!(virtual)" ];
    } else {
      log.debug_(String.format("Looking for folder hierarchy %s", cast(Object[])[ folderPath.getPath() ]));
      if (folderPath.getPath().endsWith(":" + File.separator))
      {
        filePathElements = cast(String[])[ folderPath.getPath() ];
      }
      else filePathElements = folderPath.getPath().split(Pattern.quote(File.separator));

    }

    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();

      bool createNecessary = false;
      Long parentFolderId = null;
      Long lastFolderId = null;
      for (int i = 0; i < filePathElements.length; i++)
      {
        if (createNecessary)
        {
          lastFolderId = Long.valueOf(create(con, new Folder(filePathElements[i], repositoryId, parentFolderId)));
        }
        else {
          lastFolderId = findFolderById(con, filePathElements[i], repositoryId, parentFolderId);
          if (lastFolderId is null) {
            lastFolderId = Long.valueOf(create(con, new Folder(filePathElements[i], repositoryId, parentFolderId)));
            createNecessary = true;
          }
        }
        parentFolderId = new Long(lastFolderId.longValue());
      }
      return lastFolderId;
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot create file path for Folder %s", cast(Object[])[ folderPath.getPath() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int getNumberOfMediaItems(Long folderId)
  {
    log.debug_(String.format("Getting number of media items in folder %s", cast(Object[])[ folderId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT count(media_item.id) as items from media_item WHERE media_item.folder_id = ?");

      ps.setLong(1, folderId.longValue());

      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("items"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot get number of media items in folder: %s ", cast(Object[])[ folderId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int getNumberOfSubFolders(Long folderId, Long repositoryId, AccessGroup accessGroup)
  {
    log.debug_(String.format("Getting number of sub-Folders in folder %s [%s]", cast(Object[])[ folderId, accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      String sql = "SELECT count(folder.id) as subfolders from folder " + accessGroupTable(accessGroup) + "WHERE folder.name <> ?";

      if (folderId is null)
        sql = sql + " and folder.parent_folder_id is null and folder.repository_id = " + repositoryId.toString();
      else {
        sql = sql + " and folder.parent_folder_id = " + folderId.toString();
      }
      sql = sql + accessGroupConditionForFolder(accessGroup);
      ps = con.prepareStatement(sql);
      ps.setString(1, "!(virtual)");

      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("subfolders"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot get number of sub-Folders in folder: %s ", cast(Object[])[ folderId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int getNumberOfFoldersAndMediaItems(MediaFileType fileType, ObjectType objectType, AccessGroup accessGroup, Long folderId, Long repositoryId)
  {
    log.debug_(String.format("Getting number of %s sub-folders and media items in folder %s (filter: %s) [%s]", cast(Object[])[ fileType, folderId is null ? "'root'" : folderId, objectType, accessGroup ]));

    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();

      String sql = "SELECT count(folder.id) FROM folder" + accessGroupTable(accessGroup) + "WHERE folder.name <> ?";
      if (folderId is null)
        sql = sql + " and folder.parent_folder_id is null and folder.repository_id = " + repositoryId.toString();
      else {
        sql = sql + " and folder.parent_folder_id = " + folderId.toString();
      }
      sql = sql + accessGroupConditionForFolder(accessGroup);
      sql = sql + " UNION ALL ";
      sql = sql + "SELECT count(media_item.id) FROM media_item" + accessGroupTable(accessGroup) + " WHERE media_item.file_type = ? ";
      if (folderId is null)
      {
        sql = sql + "AND media_item.folder_id = (SELECT id FROM folder where name = '" + "!(virtual)" + "' " + "AND repository_id = " + repositoryId.toString() + " AND parent_folder_id IS NULL)";
      }
      else
      {
        sql = sql + "AND media_item.folder_id = " + folderId.toString();
      }
      sql = sql + accessGroupConditionForMediaItem(accessGroup);
      ps = con.prepareStatement(sql);
      ps.setString(1, "!(virtual)");
      ps.setString(2, fileType.toString());

      ResultSet rs = ps.executeQuery();
      int count = 0;
      if ((rs.next()) && (objectType.supportsContainers())) {
        count += rs.getInt(1);
      }
      if ((rs.next()) && (objectType.supportsItems())) {
        count += rs.getInt(1);
      }
      return count;
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot get number of %s media items in folder: %s ", cast(Object[])[ fileType, folderId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public Long retrieveVirtualFolderId(Long repositoryId)
  {
    Connection con = null;
    try {
      con = DatabaseManager.getConnection();
      return findFolderById(con, "!(virtual)", repositoryId, null);
    } catch (SQLException e) {
      throw new PersistenceException("Cannot read virtual folder id", e);
    } finally {
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Folder) retrieveFoldersWithMedia(MediaFileType fileType, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of leaf folders (from=%s, count=%s) [%s]", cast(Object[])[ Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT DISTINCT(folder.id) as id, folder.name as name, parent_folder_id, folder.repository_id as repository_id FROM folder, media_item m" + accessGroupTable(accessGroup) + "WHERE folder.id = m.folder_id AND m.file_type = ?" + accessGroupConditionForFolder(accessGroup) + "ORDER BY lower(folder.name), id " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, fileType.toString());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException("Cannot read list of leaf folders", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int getFoldersWithMediaCount(MediaFileType fileType, AccessGroup accessGroup)
  {
    log.debug_(String.format("Retrieving number of leaf folders [%s]", cast(Object[])[ accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT COUNT(DISTINCT(folder.id)) as c FROM folder, media_item m" + accessGroupTable(accessGroup) + "WHERE folder.id = m.folder_id AND m.file_type = ?" + accessGroupConditionForFolder(accessGroup));

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
      throw new PersistenceException("Cannot read number of leaf folders", e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Folder) retrieveSubFolders(Long folderId, Long repositoryId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Getting list of sub-Folders in folder %s (from=%s, count=%s) [%s]", cast(Object[])[ folderId, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), accessGroup ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      String sql = "SELECT folder.id as id, name, parent_folder_id, folder.repository_id as repository_id FROM folder " + accessGroupTable(accessGroup) + "WHERE folder.repository_id = ? AND folder.name <> ?";

      if (folderId is null)
        sql = sql + " and folder.parent_folder_id is null";
      else {
        sql = sql + " and folder.parent_folder_id = " + folderId.toString();
      }
      sql = sql + accessGroupConditionForFolder(accessGroup);
      sql = sql + " ORDER BY name " + "OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY";

      ps = con.prepareStatement(sql);
      ps.setLong(1, repositoryId.longValue());
      ps.setString(2, "!(virtual)");

      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot get list of sub-Folders in folder: %s ", cast(Object[])[ folderId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  protected Folder mapSingleResult(ResultSet rs)
  {
    if (rs.next()) {
      return initFolder(rs);
    }
    return null;
  }

  protected List!(Folder) mapResultSet(ResultSet rs)
  {
    List!(Folder) result = new ArrayList!(Folder)();
    while (rs.next()) {
      result.add(initFolder(rs));
    }
    return result;
  }

  private Folder initFolder(ResultSet rs) {
    Long id = Long.valueOf(rs.getLong("id"));
    String name = rs.getString("name");
    Long parentId = JdbcUtils.getLongFromResultSet(rs, "parent_folder_id");
    Long repositoryId = JdbcUtils.getLongFromResultSet(rs, "repository_id");

    Folder folder = new Folder(name, repositoryId, parentId);
    folder.setId(id);

    return folder;
  }

  protected Long findFolderById(Connection con, String name, Long repositoryId, Long parentFolderId)
  {
    PreparedStatement ps = null;
    try {
      if (parentFolderId is null) {
        ps = con.prepareStatement("SELECT id FROM folder where name = ? AND repository_id = ? AND parent_folder_id IS NULL");

        ps.setString(1, name);
        ps.setLong(2, repositoryId.longValue());
      } else {
        ps = con.prepareStatement("SELECT id FROM folder where name = ? AND repository_id = ? AND parent_folder_id = ?");

        ps.setString(1, name);
        ps.setLong(2, repositoryId.longValue());
        ps.setLong(3, parentFolderId.longValue());
      }
      ResultSet rs = ps.executeQuery();
      if (rs.next()) {
        return JdbcUtils.getLongFromResultSet(rs, "id");
      }
      return null;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read Folder with name = %s", cast(Object[])[ name ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
    }
  }

  private long create(Connection con, Folder newInstance) {
    PreparedStatement ps = null;
    try {
      ps = con.prepareStatement("INSERT INTO folder (name, repository_id, parent_folder_id) VALUES (?,?,?)", 1);

      ps.setString(1, JdbcUtils.trimToMaxLength(newInstance.getName(), 128));
      ps.setLong(2, newInstance.getRepositoryId().longValue());
      JdbcUtils.setLongValueOnStatement(ps, 3, newInstance.getParentFolderId());
      ps.executeUpdate();
      return JdbcUtils.retrieveGeneratedID(ps);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot create Folder with name %s", cast(Object[])[ newInstance.getName() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.FolderDAOImpl
 * JD-Core Version:    0.6.2
 */