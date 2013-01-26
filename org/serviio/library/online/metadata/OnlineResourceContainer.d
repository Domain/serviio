module org.serviio.library.online.metadata.OnlineResourceContainer;

import java.lang.String;
import java.lang.Long;
import java.util.ArrayList;
import java.util.List;
import org.serviio.library.entities.OnlineRepository;
import org.serviio.library.local.metadata.ImageDescriptor;
import org.serviio.library.online.AbstractUrlExtractor;
import org.serviio.library.online.metadata.OnlineContainerItem;
import org.serviio.library.online.metadata.OnlineCachable;

public abstract class OnlineResourceContainer(T/* : OnlineContainerItem!(Object)*/, E/* : AbstractUrlExtractor*/) : OnlineCachable
{
    private Long onlineRepositoryId;
    private String title;
    private String domain;
    private ImageDescriptor thumbnail;
    private List!(T) items;
    private E usedExtractor;

    public this(Long onlineRepositoryId)
    {
        this.onlineRepositoryId = onlineRepositoryId;
        items = new ArrayList!(T)();
    }

    public abstract OnlineRepository toOnlineRepository();

    public String getTitle()
    {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public List!(T) getItems() {
        return items;
    }

    public void setItems(List!(T) items) {
        this.items = items;
    }

    public Long getOnlineRepositoryId() {
        return onlineRepositoryId;
    }

    public String getDomain() {
        return domain;
    }

    public void setDomain(String domain) {
        this.domain = domain;
    }

    public ImageDescriptor getThumbnail() {
        return thumbnail;
    }

    public void setThumbnail(ImageDescriptor thumbnail) {
        this.thumbnail = thumbnail;
    }

    public E getUsedExtractor() {
        return usedExtractor;
    }

    public void setUsedExtractor(E usedExtractor) {
        this.usedExtractor = usedExtractor;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.online.metadata.OnlineResourceContainer
* JD-Core Version:    0.6.2
*/