module org.serviio.library.online.metadata.WebResource;

import java.lang.Long;
import java.io.Serializable;
import org.serviio.library.entities.OnlineRepository;
import org.serviio.library.online.WebResourceUrlExtractor;
import org.serviio.library.online.metadata.OnlineResourceContainer;
import org.serviio.library.online.WebResourceItem;

public class WebResource : OnlineResourceContainer!(WebResourceItem, WebResourceUrlExtractor) , Serializable
{
    private static const long serialVersionUID = 6479132581531378435L;

    public this(Long onlineRepositoryId)
    {
        super(onlineRepositoryId);
    }

    override public OnlineRepository toOnlineRepository()
    {
        OnlineRepository repo = new OnlineRepository(OnlineRepository.OnlineRepositoryType.WEB_RESOURCE, null, null, null, null);
        repo.setId(getOnlineRepositoryId());
        return repo;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.online.metadata.WebResource
* JD-Core Version:    0.6.2
*/