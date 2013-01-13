module org.serviio.library.dao.AbstractAccessibleDao;

import java.lang.String;
import org.serviio.library.entities.AccessGroup;

public abstract class AbstractAccessibleDao
{
  protected String accessGroupTable(AccessGroup accessGroup)
  {
    if (accessGroup == AccessGroup.ANY) {
      return " ";
    }
    return ", repository_access_group ";
  }

  protected String onlineAccessGroupTable(AccessGroup accessGroup)
  {
    if (accessGroup == AccessGroup.ANY) {
      return " ";
    }
    return ", online_repository_access_group ";
  }

  protected String accessGroupConditionForMediaItem(AccessGroup accessGroup)
  {
    return generateAccessGroupCondition(accessGroup, "media_item.repository_id");
  }

  protected String accessGroupConditionForOnlineRepository(AccessGroup accessGroup) {
    return generateOnlineAccessGroupCondition(accessGroup, "online_repository.id");
  }

  protected String accessGroupConditionForRepository(AccessGroup accessGroup) {
    return generateAccessGroupCondition(accessGroup, "repository.id");
  }

  protected String accessGroupConditionForFolder(AccessGroup accessGroup) {
    return generateAccessGroupCondition(accessGroup, "folder.repository_id");
  }

  protected String accessGroupConditionForPlaylist(AccessGroup accessGroup) {
    return generateAccessGroupCondition(accessGroup, "playlist.repository_id");
  }

  private String generateAccessGroupCondition(AccessGroup accessGroup, String tableAndRepoIdName) {
    if (accessGroup == AccessGroup.ANY) {
      return " ";
    }
    return " AND repository_access_group.repository_id = " + tableAndRepoIdName + " AND repository_access_group.access_group_id = " + accessGroup.getId() + " ";
  }

  private String generateOnlineAccessGroupCondition(AccessGroup accessGroup, String tableAndRepoIdName)
  {
    if (accessGroup == AccessGroup.ANY) {
      return " ";
    }
    return " AND online_repository_access_group.online_repository_id = " + tableAndRepoIdName + " AND online_repository_access_group.access_group_id = " + accessGroup.getId() + " ";
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.AbstractAccessibleDao
 * JD-Core Version:    0.6.2
 */