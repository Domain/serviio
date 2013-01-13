module org.serviio.library.online.WebResourceItem;

import java.util.Date;
import java.util.Map;

public class WebResourceItem
{
  private String title;
  private Map!(String, String) additionalInfo;
  private Date releaseDate = new Date();

  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public Map!(String, String) getAdditionalInfo() {
    return additionalInfo;
  }

  public void setAdditionalInfo(Map!(String, String) additionalInfo) {
    this.additionalInfo = additionalInfo;
  }

  public Date getReleaseDate() {
    return releaseDate;
  }

  public void setReleaseDate(Date releaseDate) {
    this.releaseDate = releaseDate;
  }

  public String toString()
  {
    StringBuilder builder = new StringBuilder();
    builder.append("WebResourceItem [title=").append(title).append(", releaseDate=").append(releaseDate).append(", additionalInfo=").append(additionalInfo).append("]");

    return builder.toString();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.WebResourceItem
 * JD-Core Version:    0.6.2
 */