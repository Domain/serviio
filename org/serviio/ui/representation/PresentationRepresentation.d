module org.serviio.ui.representation.PresentationRepresentation;

import java.lang.String;
import java.lang.Integer;
import java.util.ArrayList;
import java.util.List;
import org.serviio.ui.representation.BrowsingCategory;

public class PresentationRepresentation
{
    private List!(BrowsingCategory) categories;
    private String language;
    private bool showParentCategoryTitle;
    private Integer numberOfFilesForDynamicCategories;

    public this()
    {
        categories = new ArrayList!(BrowsingCategory)();
    }

    public List!(BrowsingCategory) getCategories()
    {
        return categories;
    }

    public void setCategories(List!(BrowsingCategory) categories) {
        this.categories = categories;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public bool isShowParentCategoryTitle() {
        return showParentCategoryTitle;
    }

    public void setShowParentCategoryTitle(bool showParentCategoryTitle) {
        this.showParentCategoryTitle = showParentCategoryTitle;
    }

    public Integer getNumberOfFilesForDynamicCategories() {
        return numberOfFilesForDynamicCategories;
    }

    public void setNumberOfFilesForDynamicCategories(Integer numberOfFilesForDynamicCategories) {
        this.numberOfFilesForDynamicCategories = numberOfFilesForDynamicCategories;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.ui.representation.PresentationRepresentation
* JD-Core Version:    0.6.2
*/