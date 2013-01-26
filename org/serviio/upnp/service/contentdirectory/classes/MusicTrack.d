module org.serviio.upnp.service.contentdirectory.classes.MusicTrack;

import java.lang.String;
import java.lang.Integer;
import org.serviio.upnp.service.contentdirectory.classes.AudioItem;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;

public class MusicTrack : AudioItem
{
    protected String[] artist;
    protected String album;
    protected Integer originalTrackNumber;
    protected String playlist;
    protected String storageMedium;
    protected String[] contributor;
    protected String date;

    public this(String id, String title)
    {
        super(id, title);
    }

    override public ObjectClassType getObjectClass()
    {
        return ObjectClassType.MUSIC_TRACK;
    }

    public String[] getArtist()
    {
        return artist;
    }

    public void setArtist(String[] artist) {
        this.artist = artist;
    }

    public String getAlbum() {
        return album;
    }

    public void setAlbum(String album) {
        this.album = album;
    }

    public Integer getOriginalTrackNumber() {
        return originalTrackNumber;
    }

    public void setOriginalTrackNumber(Integer originalTrackNumber) {
        this.originalTrackNumber = originalTrackNumber;
    }

    public String getPlaylist() {
        return playlist;
    }

    public void setPlaylist(String playlist) {
        this.playlist = playlist;
    }

    public String getStorageMedium() {
        return storageMedium;
    }

    public void setStorageMedium(String storageMedium) {
        this.storageMedium = storageMedium;
    }

    public String[] getContributor() {
        return contributor;
    }

    public void setContributor(String[] contributor) {
        this.contributor = contributor;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.MusicTrack
* JD-Core Version:    0.6.2
*/