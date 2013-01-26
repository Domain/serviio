module org.serviio.upnp.service.contentdirectory.definition.StaticContainerNode;

import java.lang.String;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import org.serviio.library.entities.AccessGroup;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ClassProperties;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObject;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObjectBuilder;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.definition.i18n.BrowsingCategoriesMessages;
import org.serviio.util.ObjectValidator;
import org.serviio.upnp.service.contentdirectory.definition.ContainerNode;
import org.serviio.upnp.service.contentdirectory.definition.StaticDefinitionNode;
import org.serviio.upnp.service.contentdirectory.definition.DefinitionNode;

public class StaticContainerNode : ContainerNode , StaticDefinitionNode
{
    private static immutable Set!(ObjectClassType) supportedClasses;
    private String id;
    private String titleKey;
    private bool browsable = true;

    private bool editable = false;

    static this()
    {
        supportedClasses = new HashSet!(ObjectClassType)(Arrays.asList(cast(ObjectClassType[])[ ObjectClassType.CONTAINER, ObjectClassType.STORAGE_FOLDER ]));
    }

    public this(String id, String titleKey, ObjectClassType objectClass, DefinitionNode parent, String cacheRegion)
    {
        super(objectClass, parent, cacheRegion);
        this.id = id;
        this.titleKey = titleKey;
    }

    override public DirectoryObject retrieveDirectoryObject(String objectId, ObjectType objectType, Profile rendererProfile, AccessGroup userProfile)
    {
        Map!(ClassProperties, Object) values = new HashMap!(ClassProperties, Object)();
        values.put(ClassProperties.ID, getId());
        values.put(ClassProperties.TITLE, getBrowsableTitle());
        values.put(ClassProperties.CHILD_COUNT, Integer.valueOf(retrieveContainerItemsCount(objectId, objectType, userProfile)));
        values.put(ClassProperties.PARENT_ID, Definition.instance().getParentNodeId(objectId));
        values.put(ClassProperties.SEARCHABLE, Boolean.FALSE);
        ObjectClassType containerClassType = containerClass;
        ContentDirectoryDefinitionFilter definitionFilter = rendererProfile.getContentDirectoryDefinitionFilter();
        if (definitionFilter !is null) {
            definitionFilter.filterClassProperties(objectId, values);
            containerClassType = definitionFilter.filterContainerClassType(containerClassType, objectId);
        }
        return DirectoryObjectBuilder.createInstance(containerClassType, values, null, null);
    }

    override public void validate()
    {
        super.validate();
        if (ObjectValidator.isEmpty(id)) {
            throw new ContentDirectoryDefinitionException("Node ID not provided.");
        }
        if (ObjectValidator.isEmpty(titleKey)) {
            throw new ContentDirectoryDefinitionException("Node Title not provided.");
        }
        if (!supportedClasses.contains(containerClass)) {
            throw new ContentDirectoryDefinitionException("Unsupported container class.");
        }
        if (ObjectValidator.isEmpty(cacheRegion))
            throw new ContentDirectoryDefinitionException("Node CacheRegion not provided.");
    }

    private String getBrowsableTitle()
    {
        String parentsTitle = Definition.instance().getContentOnlyParentTitles(id);
        if (parentsTitle !is null) {
            return String.format("%s %s", cast(Object[])[ getTitle(), parentsTitle ]);
        }
        return getTitle();
    }

    public String getId()
    {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTitle() {
        return BrowsingCategoriesMessages.getMessage(titleKey, new Object[0]);
    }

    public bool isBrowsable() {
        return browsable;
    }

    public void setBrowsable(bool visible) {
        browsable = visible;
    }

    public bool isEditable() {
        return editable;
    }

    public void setEditable(bool editable) {
        this.editable = editable;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.service.contentdirectory.definition.StaticContainerNode
* JD-Core Version:    0.6.2
*/