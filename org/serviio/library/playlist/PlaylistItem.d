module org.serviio.library.playlist.PlaylistItem;

import java.lang.String;
import java.lang.Integer;

public class PlaylistItem
{
    private String path;
    private Integer sequenceNumber;

    public this(String path, Integer sequenceNumber)
    {
        this.path = path;
        this.sequenceNumber = sequenceNumber;
    }

    public String getPath()
    {
        return path;
    }

    public Integer getSequenceNumber() {
        return sequenceNumber;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.playlist.PlaylistItem
* JD-Core Version:    0.6.2
*/