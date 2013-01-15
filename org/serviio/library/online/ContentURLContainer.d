module org.serviio.library.online.ContentURLContainer;

import java.lang.String;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Date;
import org.serviio.library.metadata.MediaFileType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ContentURLContainer
{
  private static immutable Logger log = LoggerFactory.getLogger!(ContentURLContainer)();
  private String contentUrl;
  private String thumbnailUrl;
  private MediaFileType fileType = MediaFileType.VIDEO;
  private Date expiresOn;
  private bool expiresImmediately = false;
  private String cacheKey;
  private bool live = false;
  private String userAgent;

  public String getContentUrl()
  {
    return contentUrl;
  }

  public URL getThumbnailUrl() {
    try {
      return thumbnailUrl !is null ? new URL(thumbnailUrl) : null;
    } catch (MalformedURLException e) {
      log.debug_((new StringBuilder()).append("Cannot parse thumbnail URL: ").append(e.getMessage()).toString());
    }return null;
  }

  public MediaFileType getFileType()
  {
    return fileType;
  }

  public void setContentUrl(String contentUrl) {
    this.contentUrl = contentUrl;
  }

  public void setThumbnailUrl(String thumbnailUrl) {
    this.thumbnailUrl = thumbnailUrl;
  }

  public void setFileType(MediaFileType fileType) {
    this.fileType = fileType;
  }

  public Date getExpiresOn() {
    return expiresOn;
  }

  public void setExpiresOn(Date expiresIn) {
    expiresOn = expiresIn;
  }

  public bool isExpiresImmediately() {
    return expiresImmediately;
  }

  public void setExpiresImmediately(bool expiresImmediately) {
    this.expiresImmediately = expiresImmediately;
  }

  public String getCacheKey() {
    return cacheKey;
  }

  public void setCacheKey(String cacheKey) {
    this.cacheKey = cacheKey;
  }

  public bool isLive() {
    return live;
  }

  public void setLive(bool live) {
    this.live = live;
  }

  public String getUserAgent() {
    return userAgent;
  }

  public void setUserAgent(String userAgent) {
    this.userAgent = userAgent;
  }

  override public String toString()
  {
    StringBuilder builder = new StringBuilder();
    builder.append("ContentURLContainer [");
    if (fileType !is null)
      builder.append("fileType=").append(fileType).append(", ");
    if (contentUrl !is null)
      builder.append("contentUrl=").append(contentUrl).append(", ");
    if (thumbnailUrl !is null)
      builder.append("thumbnailUrl=").append(thumbnailUrl).append(", ");
    if (expiresOn !is null)
      builder.append("expiresOn=").append(expiresOn).append(", ");
    builder.append("expiresImmediately=").append(expiresImmediately).append(", ");
    if (cacheKey !is null)
      builder.append("cacheKey=").append(cacheKey).append(", ");
    builder.append("live=").append(live).append(", ");
    if (userAgent !is null)
      builder.append("userAgent=").append(userAgent);
    builder.append("]");
    return builder.toString();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.ContentURLContainer
 * JD-Core Version:    0.6.2
 */