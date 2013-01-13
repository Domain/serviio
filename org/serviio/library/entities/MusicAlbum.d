module org.serviio.library.entities.MusicAlbum;

import org.serviio.db.entities.PersistedEntity;

public class MusicAlbum : PersistedEntity
{
  public static final int TITLE_MAX_LENGTH = 256;
  private String title;
  private String sortTitle;

  public this(String title)
  {
    this.title = title;
  }

  public String getTitle()
  {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public String getSortTitle() {
    return sortTitle;
  }

  public void setSortTitle(String sortTitle) {
    this.sortTitle = sortTitle;
  }

  public String toString()
  {
    return String.format("MusicAlbum [title=%s, sortTitle=%s]", cast(Object[])[ title, sortTitle ]);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.entities.MusicAlbum
 * JD-Core Version:    0.6.2
 */