module org.serviio.library.online.metadata.FeedItem;

import java.io.Serializable;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

public class FeedItem : OnlineContainerItem!(Feed)
  , Serializable
{
  private static final long serialVersionUID = -1114391919989682022L;
  private Map!(String, URL) links = new HashMap!(String, URL)();

  public this(Feed parentFeed, int feedOrder)
  {
    parentContainer = parentFeed;
    order = feedOrder;
  }

  public Map!(String, URL) getLinks()
  {
    return links;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.metadata.FeedItem
 * JD-Core Version:    0.6.2
 */