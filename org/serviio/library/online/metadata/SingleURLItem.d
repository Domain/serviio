module org.serviio.library.online.metadata.SingleURLItem;

import java.lang.Long;
import java.io.Serializable;
import org.serviio.library.online.OnlineItemId;
import org.serviio.library.online.metadata.OnlineItem;
import org.serviio.library.online.metadata.OnlineCachable;

public class SingleURLItem : OnlineItem , OnlineCachable, Serializable
{
    private static const long serialVersionUID = -5502211279053449413L;
    private Long repositoryId;

    public this(Long repositoryId)
    {
        this.repositoryId = repositoryId;
    }

    override protected OnlineItemId generateId()
    {
        return new OnlineItemId(repositoryId.longValue(), 1);
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.online.metadata.SingleURLItem
* JD-Core Version:    0.6.2
*/