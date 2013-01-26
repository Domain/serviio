module org.serviio.upnp.service.contentdirectory.classes.Container;

import java.lang.Integer;
import java.lang.String;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObject;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;

public class Container : DirectoryObject
{
    protected Integer childCount;
    protected String[] createClass = null;

    protected String[] searchClass = null;

    protected bool searchable = false;
    private String mediaClass;

    public this(String id, String title)
    {
        super(id, title);
    }

    override public ObjectClassType getObjectClass()
    {
        return ObjectClassType.CONTAINER;
    }

    public Integer getChildCount()
    {
        return childCount;
    }

    public void setChildCount(Integer childCount) {
        this.childCount = childCount;
    }

    public String[] getCreateClass() {
        return createClass;
    }

    public void setCreateClass(String[] createClass) {
        this.createClass = createClass;
    }

    public String[] getSearchClass() {
        return searchClass;
    }

    public void setSearchClass(String[] searchClass) {
        this.searchClass = searchClass;
    }

    public bool isSearchable() {
        return searchable;
    }

    public void setSearchable(bool searchable) {
        this.searchable = searchable;
    }

    public String getMediaClass() {
        return mediaClass;
    }

    public void setMediaClass(String mediaClass) {
        this.mediaClass = mediaClass;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.Container
* JD-Core Version:    0.6.2
*/