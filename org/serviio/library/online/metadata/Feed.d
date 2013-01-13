module org.serviio.library.online.metadata.Feed;

import java.io.Serializable;
import org.serviio.library.entities.OnlineRepository;
import org.serviio.library.entities.OnlineRepository : OnlineRepositoryType;
import org.serviio.library.online.FeedItemUrlExtractor;

public class Feed : OnlineResourceContainer!(FeedItem, FeedItemUrlExtractor)
  , Serializable
{
  private static final long serialVersionUID = 9081353584351407845L;

  public this(Long onlineRepositoryId)
  {
    super(onlineRepositoryId);
  }

  public OnlineRepository toOnlineRepository()
  {
    OnlineRepository repo = new OnlineRepository(OnlineRepositoryType.FEED, null, null, null, null);
    repo.setId(getOnlineRepositoryId());
    return repo;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.metadata.Feed
 * JD-Core Version:    0.6.2
 */