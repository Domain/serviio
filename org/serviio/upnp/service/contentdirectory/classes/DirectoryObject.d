module org.serviio.upnp.service.contentdirectory.classes.DirectoryObject;

import java.util.ArrayList;
import java.util.List;

public abstract class DirectoryObject
{
  protected String id;
  protected Long entityId;
  protected String parentID;
  protected String title;
  protected String creator;
  protected List!(Resource) resources = new ArrayList!(Resource)();

  protected bool restricted = true;

  protected String writeStatus = "NOT_WRITABLE";

  public this(String id, String title)
  {
    this.id = id;
    this.title = title;
  }

  public abstract ObjectClassType getObjectClass();

  public String getParentID()
  {
    return parentID;
  }

  public void setParentID(String parentID) {
    this.parentID = parentID;
  }

  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public String getCreator() {
    return creator;
  }

  public void setCreator(String creator) {
    this.creator = creator;
  }

  public List!(Resource) getResources() {
    return resources;
  }

  public void setResources(List!(Resource) res) {
    resources = res;
  }

  public String getId() {
    return id;
  }

  public bool isRestricted() {
    return restricted;
  }

  public String getWriteStatus() {
    return writeStatus;
  }

  public Long getEntityId() {
    return entityId;
  }

  public void setEntityId(Long entityId) {
    this.entityId = entityId;
  }

  public String toString()
  {
    StringBuilder builder = new StringBuilder();
    builder.append("DirectoryObject [creator=").append(creator).append(", id=").append(id).append(", parentID=").append(parentID).append(", resources=").append(resources).append(", restricted=").append(restricted).append(", title=").append(title).append(", writeStatus=").append(writeStatus).append("]");

    return builder.toString();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.DirectoryObject
 * JD-Core Version:    0.6.2
 */