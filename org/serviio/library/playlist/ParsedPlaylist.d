module org.serviio.library.playlist.ParsedPlaylist;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class ParsedPlaylist
{
  private String title;
  private List!(PlaylistItem) items = new ArrayList!(PlaylistItem)();

  public this(String title)
  {
    this.title = title;
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