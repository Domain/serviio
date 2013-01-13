module org.serviio.library.online.WebResourceContainer;

import java.util.ArrayList;
import java.util.List;

public class WebResourceContainer
{
  private String title;
  private String thumbnailUrl;
  private List!(WebResourceItem) items = new ArrayList!(WebResourceItem)();

  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public List!(WebResourceItem) getItems() {
    return items;
  }

  public void setItems(List!(WebResourceItem) items) {
    this.items = items;
  }

  public String getThumbnailUrl() {
    return thumbnailUrl;
  }

  public void setThumbnailUrl(String thumbnailUrl) {
    this.thumbnailUrl = thumbnailUrl;
  }

  public String toString()
  {
    StringBuilder builder = new StringBuilder();
    builder.append("WebResourceContainer [title=").append(title).append(", thumbnailUrl=").append(thumbnailUrl).append(", items=").append(items).append("]");

    return builder.toString();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.WebResourceContainer
 * JD-Core Version:    0.6.2
 */