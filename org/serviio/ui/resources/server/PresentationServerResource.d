module org.serviio.ui.resources.server.PresentationServerResource;

import java.lang.String;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.serviio.config.Configuration;
import org.serviio.i18n.Language;
import org.serviio.restlet.AbstractServerResource;
import org.serviio.restlet.ResultRepresentation;
import org.serviio.ui.representation.BrowsingCategory;
import org.serviio.ui.representation.PresentationRepresentation;
import org.serviio.ui.resources.PresentationResource;
import org.serviio.upnp.service.contentdirectory.definition.ContainerNode;
import org.serviio.upnp.service.contentdirectory.definition.ContainerVisibilityType;
import org.serviio.upnp.service.contentdirectory.definition.Definition;
import org.serviio.upnp.service.contentdirectory.definition.DefinitionNode;
import org.serviio.upnp.service.contentdirectory.definition.StaticContainerNode;
import org.serviio.upnp.service.contentdirectory.definition.i18n.BrowsingCategoriesMessages;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PresentationServerResource : AbstractServerResource , PresentationResource
{
    private static immutable Logger log;

    static this()
    {
        log = LoggerFactory.getLogger!(PresentationServerResource)();
    }

    public PresentationRepresentation load()
    {
        PresentationRepresentation rep = new PresentationRepresentation();
        initCategories(rep);
        rep.setLanguage(Configuration.getBrowseMenuPreferredLanguage());
        rep.setShowParentCategoryTitle(Configuration.isBrowseMenuShowNameOfParentCategory());
        rep.setNumberOfFilesForDynamicCategories(Configuration.getNumberOfFilesForDynamicCategories());
        return rep;
    }

    public ResultRepresentation save(PresentationRepresentation rep)
    {
        bool cdsUpdateNeeded = updateCategories(rep);

        if (!Configuration.getBrowseMenuPreferredLanguage().equals(rep.getLanguage())) {
            Configuration.setBrowseMenuPreferredLanguage(rep.getLanguage());
            BrowsingCategoriesMessages.loadLocale(Language.getLocale(Configuration.getBrowseMenuPreferredLanguage()));
            cdsUpdateNeeded = true;
        }

        if (Configuration.isBrowseMenuShowNameOfParentCategory() != rep.isShowParentCategoryTitle()) {
            Configuration.setBrowseMenuShowNameOfParentCategory(rep.isShowParentCategoryTitle());
            cdsUpdateNeeded = true;
        }

        if (Configuration.getNumberOfFilesForDynamicCategories() != rep.getNumberOfFilesForDynamicCategories()) {
            Configuration.setNumberOfFilesForDynamicCategories(rep.getNumberOfFilesForDynamicCategories());
            cdsUpdateNeeded = true;
        }

        if (cdsUpdateNeeded)
        {
            getCDS().incrementUpdateID();
        }

        return responseOk();
    }

    private void initCategories(PresentationRepresentation rep)
    {
        List!(BrowsingCategory) categories = findEditableContainers(Definition.instance().getContainer("0"));

        rep.getCategories().addAll(categories);
    }

    private List!(BrowsingCategory) findEditableContainers(ContainerNode parent)
    {
        Definition def = Definition.instance();
        List!(BrowsingCategory) categories = new ArrayList!(BrowsingCategory)();
        foreach (DefinitionNode node ; parent.getChildNodes()) {
            if (( cast(StaticContainerNode)node !is null )) {
                StaticContainerNode container = cast(StaticContainerNode)node;
                if (container.isEditable()) {
                    BrowsingCategory category = new BrowsingCategory(container.getId(), container.getTitle(), def.getContainerVisibility(container.getId()));
                    categories.add(category);
                    category.getSubCategories().addAll(findEditableContainers(container));
                }
            }
        }
        return categories;
    }

    private bool updateCategories(PresentationRepresentation rep)
    {
        if (rep.getCategories() !is null) {
            log.debug_("Updating browsing categories' configuration");
            Map!(String, String) config = new LinkedHashMap!(String, String)();
            foreach (BrowsingCategory category ; rep.getCategories()) {
                addCategoryToConfig(category, config);
            }
            Configuration.setBrowseMenuItemOptions(config);
            return true;
        }
        return false;
    }

    private void addCategoryToConfig(BrowsingCategory category, Map!(String, String) config) {
        if (category.getVisibility() != ContainerVisibilityType.DISPLAYED) {
            config.put(category.getId(), category.getVisibility().toString());
        }
        if (category.getSubCategories() !is null)
            foreach (BrowsingCategory subCategory ; category.getSubCategories())
                addCategoryToConfig(subCategory, config);
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.ui.resources.server.PresentationServerResource
* JD-Core Version:    0.6.2
*/