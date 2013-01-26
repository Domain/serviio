module org.serviio.upnp.service.contentdirectory.classes.MusicAlbum;

import java.lang.String;
import java.net.URI;
import org.serviio.upnp.service.contentdirectory.classes.Album;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;

public class MusicAlbum : Album
{
    protected String artist;
    protected String genre;
    protected String producer;
    protected String toc;
    protected URI albumArtURI;

    public this(String id, String title)
    {
        super(id, title);
    }

    override public ObjectClassType getObjectClass()
    {
        return ObjectClassType.MUSIC_ALBUM;
    }

    public String getArtist()
    {
        return artist;
    }

    public void setArtist(String artist) {
        this.artist = artist;
    }

    public String getGenre() {
        return genre;
    }

    public void setGenre(String genre) {
        this.genre = genre;
    }

    public String getProducer() {
        return producer;
    }

    public void setProducer(String producer) {
        this.producer = producer;
    }

    public String getToc() {
        return toc;
    }

    public void setToc(String toc) {
        this.toc = toc;
    }

    public URI getAlbumArtURI() {
        return albumArtURI;
    }

    public void setAlbumArtURI(URI albumArtURI) {
        this.albumArtURI = albumArtURI;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.MusicAlbum
* JD-Core Version:    0.6.2
*/