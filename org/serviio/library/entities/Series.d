module org.serviio.library.entities.Series;

import java.lang.String;
import org.serviio.db.entities.PersistedEntity;

public class Series : PersistedEntity
{
    private String title;
    private String sortTitle;

    public this(String title, String sortTitle)
    {
        this.title = title;
        this.sortTitle = sortTitle;
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
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.entities.Series
* JD-Core Version:    0.6.2
*/