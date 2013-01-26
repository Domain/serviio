module org.serviio.library.online.metadata.WebResourceItem;

import java.lang.String;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;
import org.serviio.library.online.metadata.OnlineContainerItem;
import org.serviio.library.online.metadata.WebResource;
static import org.serviio.library.online.WebResourceItem;

public class WebResourceItem : OnlineContainerItem!(WebResource) , Serializable
{
    private static const long serialVersionUID = 6334150099157949087L;
    private Map!(String, String) additionalInfo = new HashMap!(String, String)();

    public this(WebResource parent, int order)
    {
        parentContainer = parent;
        this.order = order;
    }

    public org.serviio.library.online.WebResourceItem.WebResourceItem toContainerItem()
    {
        org.serviio.library.online.WebResourceItem.WebResourceItem item = new org.serviio.library.online.WebResourceItem.WebResourceItem();
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