module org.serviio.upnp.service.contentdirectory.definition.DefinitionNode;

import org.serviio.library.entities.AccessGroup;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObject;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;

public abstract class DefinitionNode
{
  protected ObjectClassType containerClass;
  protected ObjectClassType itemClass;
  protected DefinitionNode parent;
  protected String cacheRegion;

  public this(ObjectClassType containerClass, DefinitionNode parent, String cacheRegion)
  {
    this.containerClass = containerClass;
    this.parent = parent;
    this.cacheRegion = cacheRegion;
  }

  public abstract DirectoryObject retrieveDirectoryObject(String paramString, ObjectType paramObjectType, Profile paramProfile, AccessGroup paramAccessGroup);

  public void validate()
  {
  }

  public ObjectClassType getContainerClass()
  {
    return containerClass;
  }

  public ObjectClassType getItemClass() {
    return itemClass;
  }

  public DefinitionNode getParent() {
    return parent;
  }

  public String getCacheRegion() {
    return cacheRegion;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.definition.DefinitionNode
 * JD-Core Version:    0.6.2
 */