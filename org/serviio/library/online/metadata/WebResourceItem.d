module org.serviio.library.online.metadata.WebResourceItem;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class WebResourceItem : OnlineContainerItem!(WebResource)
  , Serializable
{
  private static final long serialVersionUID = 6334150099157949087L;
  private Map!(String, String) additionalInfo = new HashMap!(String, String)();

  public this(WebResource parent, int order)
  {
    parentContainer = parent;
    this.order = order;
  }

  public org.serviio.library.online.WebResourceItem toContainerItem()
  {
    org.serviio.library.online.WebResourceItem item = new org.serviio.library.online.WebResourceItem();
    item.setTitle(title);
    item.setReleaseDate(date);
    item.setAdditionalInfo(additionalInfo);
    return item;
  }

  public Map!(String, String) getAdditionalInfo()
  {
    return additionalInfo;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.metadata.WebResourceItem
 * JD-Core Version:    0.6.2
 */