module org.serviio.library.entities.MediaItem;

import java.lang.String;
import java.lang.Long;
import java.lang.Integer;
import java.util.Date;
import org.serviio.db.entities.PersistedEntity;
import org.serviio.delivery.DeliveryContext;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.library.online.AbstractUrlExtractor;
import org.serviio.library.online.OnlineItemId;
import org.serviio.library.online.metadata.OnlineItem;

public class MediaItem : PersistedEntity
{
  public static const int TITLE_MAX_LENGTH = 128;
  public static const int FOURCC_MAX_LENGTH = 6;
  protected String title;
  protected String sortTitle;
  protected Long fileSize;
  protected String fileName;
  protected String filePath;
  protected Date date;
  protected Date lastViewedDate;
  protected Integer numberViewed;
  private Long thumbnailId;
  protected String description;
  protected Integer bookmark;
  protected Long folderId;
  protected Long repositoryId;
  protected MediaFileType fileType;
  protected bool dirty = false;
  private AbstractUrlExtractor onlineResourcePlugin;
  private OnlineItem onlineItem;
  private DeliveryContext deliveryContext = DeliveryContext.LOCAL;
  private bool live;

  public this(String title, String fileName, String filePath, Long fileSize, Long folderId, Long repositoryId, Date date, MediaFileType fileType)
  {
    this.title = title;
    this.fileName = fileName;
    this.fileSize = fileSize;
    this.folderId = folderId;
    this.repositoryId = repositoryId;
    this.date = date;
    this.fileType = fileType;
    this.filePath = filePath;
  }

  public bool isLocalMedia()
  {
    return isLocalMedia(getId());
  }

  public static bool isLocalMedia(Long mediaItemId)
  {
    return !OnlineItemId.isOnlineItemId(mediaItemId);
  }

  public String getTitle()
  {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public Long getFileSize() {
    return fileSize;
  }

  public void setFileSize(Long fileSize) {
    this.fileSize = fileSize;
  }

  public String getFileName() {
    return fileName;
  }

  public void setFileName(String fileName) {
    this.fileName = fileName;
  }

  public Long getFolderId() {
    return folderId;
  }

  public void setFolderId(Long folderId) {
    this.folderId = folderId;
  }

  public Date getDate() {
    return date;
  }

  public void setDate(Date date) {
    this.date = date;
  }

  public String getDescription() {
    return description;
  }

  public void setDescription(String description) {
    this.description = description;
  }

  public MediaFileType getFileType() {
    return fileType;
  }

  public bool isDirty() {
    return dirty;
  }

  public void setDirty(bool dirty) {
    this.dirty = dirty;
  }

  public String getSortTitle() {
    return sortTitle;
  }

  public void setSortTitle(String sortTitle) {
    this.sortTitle = sortTitle;
  }

  public Date getLastViewedDate() {
    return lastViewedDate;
  }

  public void setLastViewedDate(Date lastViewedDate) {
    this.lastViewedDate = lastViewedDate;
  }

  public Integer getNumberViewed() {
    return numberViewed;
  }

  public void setNumberViewed(Integer numberViewed) {
    this.numberViewed = numberViewed;
  }

  public Long getThumbnailId() {
    return thumbnailId;
  }

  public void setThumbnailId(Long thumbnailId) {
    this.thumbnailId = thumbnailId;
  }

  public Integer getBookmark() {
    return bookmark;
  }

  public void setBookmark(Integer bookmark) {
    this.bookmark = bookmark;
  }

  public AbstractUrlExtractor getOnlineResourcePlugin() {
    return onlineResourcePlugin;
  }

  public void setOnlineResourcePlugin(AbstractUrlExtractor onlineResourcePlugin) {
    this.onlineResourcePlugin = onlineResourcePlugin;
  }

  public OnlineItem getOnlineItem() {
    return onlineItem;
  }

  public void setOnlineItem(OnlineItem onlineItem) {
    this.onlineItem = onlineItem;
  }

  public bool isLive() {
    return live;
  }

  public void setLive(bool live) {
    this.live = live;
  }

  public String getFilePath() {
    return filePath;
  }

  public void setFilePath(String filePath) {
    this.filePath = filePath;
  }

  public Long getRepositoryId() {
    return repositoryId;
  }

  public void setRepositoryId(Long repositoryId) {
    this.repositoryId = repositoryId;
  }

  public DeliveryContext getDeliveryContext() {
    return deliveryContext;
  }

  public void setDeliveryContext(DeliveryContext deliveryContext) {
    this.deliveryContext = deliveryContext;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.entities.MediaItem
 * JD-Core Version:    0.6.2
 */