module org.serviio.library.entities.Repository;

import java.lang.String;
import java.lang.Long;
import java.io.File;
import java.util.Date;
import java.util.List;
import java.util.Set;
import org.serviio.db.entities.PersistedEntity;
import org.serviio.library.metadata.MediaFileType;

public class Repository : PersistedEntity
{
  private File folder;
  private Set!(MediaFileType) supportedFileTypes;
  private bool supportsOnlineMetadata;
  private bool keepScanningForUpdates;
  private Date lastScanned;
  private List!(Long) accessGroupIds;

  public this(File folder, Set!(MediaFileType) supportedFileTypes, bool supportsOnlineMetadata, bool keepScanningForUpdates)
  {
    this.folder = folder;
    this.supportedFileTypes = supportedFileTypes;
    this.supportsOnlineMetadata = supportsOnlineMetadata;
    this.keepScanningForUpdates = keepScanningForUpdates;
  }

  public File getFolder()
  {
    return folder;
  }

  public Set!(MediaFileType) getSupportedFileTypes() {
    return supportedFileTypes;
  }

  public bool isSupportsOnlineMetadata() {
    return supportsOnlineMetadata;
  }

  public bool isKeepScanningForUpdates() {
    return keepScanningForUpdates;
  }

  public Date getLastScanned() {
    return lastScanned;
  }

  public void setLastScanned(Date lastScanned) {
    this.lastScanned = lastScanned;
  }

  public List!(Long) getAccessGroupIds() {
    return accessGroupIds;
  }

  public void setAccessGroupIds(List!(Long) accessGroupIds) {
    this.accessGroupIds = accessGroupIds;
  }

  override public String toString()
  {
    StringBuilder builder = new StringBuilder();
    builder.append("Repository [id=").append(id).append(", folder=").append(folder).append(", keepScanningForUpdates=").append(keepScanningForUpdates).append(", lastScanned=").append(lastScanned).append(", supportedFileTypes=").append(supportedFileTypes).append(", supportsOnlineMetadata=").append(supportsOnlineMetadata).append("]");

    return builder.toString();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.entities.Repository
 * JD-Core Version:    0.6.2
 */