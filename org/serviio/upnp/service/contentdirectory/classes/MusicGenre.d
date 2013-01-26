module org.serviio.upnp.service.contentdirectory.classes.MusicGenre;

import java.lang.String;
import org.serviio.upnp.service.contentdirectory.classes.Genre;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;

public class MusicGenre : Genre
{
    public this(String id, String title)
    {
        super(id, title);
    }

    override public ObjectClassType getObjectClass()
    {
        return ObjectClassType.MUSIC_GENRE;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.MusicGenre
* JD-Core Version:    0.6.2
*/