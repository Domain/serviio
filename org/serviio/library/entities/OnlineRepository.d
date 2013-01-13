module org.serviio.library.entities.OnlineRepository;

import java.net.URL;
import java.util.List;
import org.serviio.db.entities.PersistedEntity;
import org.serviio.library.metadata.MediaFileType;

public class OnlineRepository : PersistedEntity
{
  private String repositoryUrl;
  private MediaFileType fileType;
  private OnlineRepositoryType repoType;
  private URL thumbnailUrl;
  private String repositoryName;
  private bool enabled = true;
  private List!(Long) accessGroupIds;
  private Integer order;

  public this(OnlineRepositoryType repoType, String repositoryUrl, MediaFileType fileType, String repositoryName, Integer order)
  {
    this.repoType = repoType;
    this.repositoryUrl = repositoryUrl;
    this.fileType = fileType;
    this.repositoryName = repositoryName;
    this.order = order;
  }

  public String getRepositoryUrl()
  {
    return repositoryUrl;
  }

  public void setRepositoryUrl(String repositoryUrl) {
    this.repositoryUrl = repositoryUrl;
  }

  public MediaFileType getFileType() {
    return fileType;
  }

  public void setFileType(MediaFileType fileType) {
    this.fileType = fileType;
  }

  public OnlineRepositoryType getRepoType() {
    return repoType;
  }

  public void setRepoType(OnlineRepositoryType repoType) {
    this.repoType = repoType;
  }

  public URL getThumbnailUrl() {
    return thumbnailUrl;
  }

  public void setThumbnailUrl(URL thumbnailUrl) {
    this.thumbnailUrl = thumbnailUrl;
  }

  public String getRepositoryName() {
    return repositoryName;
  }

  public void setRepositoryName(String repositoryName) {
    this.repositoryName = repositoryName;
  }

  public bool isEnabled() {
    return enabled;
  }

  public void setEnabled(bool enabled) {
    this.enabled = enabled;
  }

  public List!(Long) getAccessGroupIds()
  {
    return accessGroupIds;
  }

  public void setAccessGroupIds(List!(Long) accessGroupIds) {
    this.accessGroupIds = accessGroupIds;
  }

  public Integer getOrder()
  {
    return order;
  }

  public void setOrder(Integer order) {
    this.order = order;
  }

  public String toString()
  {
    StringBuilder builder = new StringBuilder();
    builder.append("OnlineRepository [repositoryUrl=").append(repositoryUrl).append(", fileType=").append(fileType).append(", repoType=").append(repoType).append(", thumbnailUrl=").append(thumbnailUrl).append(", repositoryName=").append(repositoryName).append(", enabled=").append(enabled).append(", accessGroupIds=").append(accessGroupIds).append(", order=").append(order).append(", id=").append(id).append("]");

    return builder.toString();
  }

  public bool thumbnailChanged(URL urlToCompare) {
    if ((thumbnailUrl is null) && (urlToCompare is null))
      return false;
    if (thumbnailUrl is null) {
      return true;
    }
    return !thumbnailUrl.equals(urlToCompare);
  }

  public static enum OnlineRepositoryType
  {
    FEED, LIVE_STREAM, WEB_RESOURCE
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.entities.OnlineRepository
 * JD-Core Version:    0.6.2
 */