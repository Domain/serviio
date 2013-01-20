module org.serviio.library.online.metadata.FeedItem;

import java.lang.String;
import java.io.Serializable;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import org.serviio.library.online.metadata.OnlineContainerItem;
import org.serviio.library.online.metadata.Feed;

public class FeedItem : OnlineContainerItem!(Feed) , Serializable
{
    private static const long serialVersionUID = -1114391919989682022L;
    private Map!(String, URL) links;

    public this(Feed parentFeed, int feedOrder)
    {
        links = new HashMap!(String, URL)();
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