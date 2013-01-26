module org.serviio.upnp.service.contentdirectory.classes.PlaylistItem;

import java.util.Date;
import java.lang.String;
import org.serviio.upnp.service.contentdirectory.classes.Item;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;

public class PlaylistItem : Item
{
    protected String[] artist;
    protected String genre;
    protected String longDescription;
    protected String storageMedium;
    protected String description;
    protected Date date;
    protected String[] language;

    public this(String id, String title)
    {
        super(id, title);
    }

    override public ObjectClassType getObjectClass()
    {
        return ObjectClassType.PLAYLIST_ITEM;
    }

    public String[] getArtist()
    {
        return artist;
    }

    public void setArtist(String[] artist) {
        this.artist = artist;
    }

    public String getGenre() {
        return genre;
    }

    public void setGenre(String genre) {
        this.genre = genre;
    }

    public String getLongDescription() {
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

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public String[] getLanguage() {
        return language;
    }

    public void setLanguage(String[] language) {
        this.language = language;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.PlaylistItem
* JD-Core Version:    0.6.2
*/