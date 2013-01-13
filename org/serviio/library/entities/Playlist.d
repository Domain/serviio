module org.serviio.library.entities.Playlist;

import java.util.Date;
import java.util.Set;
import org.serviio.db.entities.PersistedEntity;
import org.serviio.library.metadata.MediaFileType;

public class Playlist : PersistedEntity
{
  public static final int TITLE_MAX_LENGTH = 128;
  private String title;
  private Set!(MediaFileType) fileTypes;
  private String filePath;
  private Date dateUpdated;
  private Long repositoryId;
  private bool allItemsFound;

  public this(String title, Set!(MediaFileType) fileTypes, String filePath, Date dateUpdated, Long repositoryId)
  {
    this.title = title;
    this.fileTypes = fileTypes;
    this.filePath = filePath;
    this.dateUpdated = dateUpdated;
    this.repositoryId = repositoryId;
  }

  public String getTitle()
  {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public Set!(MediaFileType) getFileTypes() {
    return fileTypes;
  }

  public void setFileTypes(Set!(MediaFileType) fileTypes) {
    this.fileTypes = fileTypes;
  }

  public String getFilePath() {
    return filePath;
  }

  public void setFilePath(String filePath) {
    this.filePath = filePath;
  }

  public Date getDateUpdated() {
    return dateUpdated;
  }

  public void setDateUpdated(Date dateUpdated) {
    this.dateUpdated = dateUpdated;
  }

  public Long getRepositoryId() {
    return repositoryId;
  }

  public void setRepositoryId(Long repositoryId) {
    this.repositoryId = repositoryId;
  }

  public bool isAllItemsFound() {
    return allItemsFound;
  }

  public void setAllItemsFound(bool allItemsFound) {
    this.allItemsFound = allItemsFound;
  }

  public String toString()
  {
    return String.format("Playlist [id=%s, title=%s]", cast(Object[])[ id, title ]);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.entities.Playlist
 * JD-Core Version:    0.6.2
 */