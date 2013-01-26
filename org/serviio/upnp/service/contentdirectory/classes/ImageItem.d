module org.serviio.upnp.service.contentdirectory.classes.ImageItem;

import java.lang.String;
import org.serviio.upnp.service.contentdirectory.classes.Item;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;

public class ImageItem : Item
{
    protected String longDescription;
    protected String storageMedium;
    protected String rating;
    protected String description;
    protected String[] publisher;
    protected String date;
    protected String rights;

    public this(String id, String title)
    {
        super(id, title);
    }

    override public ObjectClassType getObjectClass()
    {
        return ObjectClassType.IMAGE_ITEM;
    }

    public String getLongDescription()
    {
        return longDescription;
    }
    public void setLongDescription(String longDescription) {
        this.longDescription = longDescription;
    }
    public String getStorageMedium() {
        return storageMedium;
    }
    public void setStorageMedium(String storageMedium) {
        this.storageMedium = storageMedium;
    }
    public String getRating() {
        return rating;
    }
    public void setRating(String rating) {
        this.rating = rating;
    }
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }
    public String[] getPublisher() {
        return publisher;
    }
    public void setPublisher(String[] publisher) {
        this.publisher = publisher;
    }
    public String getDate() {
        return date;
    }
    public void setDate(String date) {
        this.date = date;
    }
    public String getRights() {
        return rights;
    }
    public void setRights(String rights) {
        this.rights = rights;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.ImageItem
* JD-Core Version:    0.6.2
*/