module org.serviio.upnp.service.contentdirectory.classes.MusicArtist;

import java.lang.String;
import java.net.URI;
import org.serviio.upnp.service.contentdirectory.classes.Person;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;

public class MusicArtist : Person
{
    protected String genre;
    protected URI artistDiscographyURI;

    public this(String id, String title)
    {
        super(id, title);
    }

    override public ObjectClassType getObjectClass()
    {
        return ObjectClassType.MUSIC_ARTIST;
    }

    public String getGenre()
    {
        return genre;
    }

    public void setGenre(String genre) {
        this.genre = genre;
    }

    public URI getArtistDiscographyURI() {
        return artistDiscographyURI;
    }

    public void setArtistDiscographyURI(URI artistDiscographyURI) {
        this.artistDiscographyURI = artistDiscographyURI;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.MusicArtist
* JD-Core Version:    0.6.2
*/