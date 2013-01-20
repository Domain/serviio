module org.serviio.library.playlist.ParsedPlaylist;

import java.lang.String;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import org.serviio.library.playlist.PlaylistItem;

public class ParsedPlaylist
{
    private String title;
    private List!(PlaylistItem) items;

    public this(String title)
    {
        this.title = title;
        items = new ArrayList!(PlaylistItem)();
    }

    public void addItem(String path)
    {
        items.add(new PlaylistItem(path, Integer.valueOf(items.size() + 1)));
    }

    public List!(PlaylistItem) getItems()
    {
        return Collections.unmodifiableList(items);
    }

    public String getTitle() {
        return title;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.playlist.ParsedPlaylist
* JD-Core Version:    0.6.2
*/