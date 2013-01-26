module org.serviio.ui.representation.BrowsingCategory;

import java.lang.String;
import java.util.ArrayList;
import java.util.List;
import org.serviio.upnp.service.contentdirectory.definition.ContainerVisibilityType;

public class BrowsingCategory
{
    private String id;
    private String title;
    private ContainerVisibilityType visibility;
    private List!(BrowsingCategory) subCategories;

    public this()
    {
        subCategories = new ArrayList!(BrowsingCategory)();
    }

    public this(String id, String title, ContainerVisibilityType visibility)
    {
        this.id = id;
        this.title = title;
        this.visibility = visibility;
    }

    public List!(BrowsingCategory) getSubCategories()
    {
        return subCategories;
    }

    public void setSubCategories(List!(BrowsingCategory) subCategories) 
    {
        this.subCategories = subCategories;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public ContainerVisibilityType getVisibility() {
        return visibility;
    }

    public void setVisibility(ContainerVisibilityType visibility) 
    {
        this.visibility = visibility;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.ui.representation.BrowsingCategory
* JD-Core Version:    0.6.2
*/