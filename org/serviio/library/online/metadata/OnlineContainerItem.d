module org.serviio.library.online.metadata.OnlineContainerItem;

import java.util.Date;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.local.metadata.ImageDescriptor;
import org.serviio.library.online.AbstractUrlExtractor;
import org.serviio.library.online.OnlineItemId;
import org.serviio.library.online.metadata.OnlineItem;

public abstract class OnlineContainerItem(C /*: OnlineResourceContainer!(Object, Object)*/) : OnlineItem
{
    protected int order;
    protected C parentContainer;
    protected Date expiresOn;
    protected bool expiresImmediately = false;
    protected AbstractUrlExtractor plugin;

    protected OnlineItemId generateId()
    {
        return new OnlineItemId(parentContainer.getOnlineRepositoryId().longValue(), order);
    }

    protected void setPluginOnMediaItem(MediaItem mediaItem) {
        if (expiresImmediately) {
            mediaItem.setOnlineResourcePlugin(plugin);
            mediaItem.setOnlineItem(this);
        }
    }

    public MediaItem toMediaItem()
    {
        MediaItem item = super.toMediaItem();
        if (item !is null) {
            setPluginOnMediaItem(item);
        }
        return item;
    }

    public ImageDescriptor getThumbnail()
    {
        ImageDescriptor thumbnail = super.getThumbnail();
        return thumbnail !is null ? thumbnail : parentContainer.getThumbnail();
    }

    public Date getExpiresOn() {
        return expiresOn;
    }

    public void setExpiresOn(Date expiresIn) {
        expiresOn = expiresIn;
    }

    public bool isExpiresImmediately() {
        return expiresImmediately;
    }

    public void setExpiresImmediately(bool expiresImmediately) {
        this.expiresImmediately = expiresImmediately;
    }

    public AbstractUrlExtractor getPlugin() {
        return plugin;
    }

    public void setPlugin(AbstractUrlExtractor plugin) {
        this.plugin = plugin;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.online.metadata.OnlineContainerItem
* JD-Core Version:    0.6.2
*/