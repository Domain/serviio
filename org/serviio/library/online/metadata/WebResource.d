module org.serviio.library.online.metadata.WebResource;

import java.io.Serializable;
import org.serviio.library.entities.OnlineRepository;
import org.serviio.library.entities.OnlineRepository : OnlineRepositoryType;
import org.serviio.library.online.WebResourceUrlExtractor;

public class WebResource : OnlineResourceContainer!(WebResourceItem, WebResourceUrlExtractor)
  , Serializable
{
  private static final long serialVersionUID = 6479132581531378435L;

  public this(Long onlineRepositoryId)
  {
    super(onlineRepositoryId);
  }

  public OnlineRepository toOnlineRepository()
  {
    OnlineRepository repo = new OnlineRepository(OnlineRepositoryType.WEB_RESOURCE, null, null, null, null);
    repo.setId(getOnlineRepositoryId());
    return repo;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.metadata.WebResource
 * JD-Core Version:    0.6.2
 */