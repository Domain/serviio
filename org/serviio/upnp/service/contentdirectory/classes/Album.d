module org.serviio.upnp.service.contentdirectory.classes.Album;

import java.net.URI;

public class Album : Container
{
  protected String storageMedium;
  protected String description;
  protected String longDescription;
  protected String publisher;
  protected String contributor;
  protected URI relation;
  protected String rights;
  protected String date;

  public this(String id, String title)
  {
    super(id, title);
  }

  public ObjectClassType getObjectClass()
  {
    return ObjectClassType.ALBUM;
  }

  public String getStorageMedium()
  {
    return storageMedium;
  }

  public void setStorageMedium(String storageMedium) {
    this.storageMedium = storageMedium;
  }

  public String getDescription() {
    return description;
  }

  public void setDescription(String description) {
    this.description = description;
  }

  public String getLongDescription() {
    return longDescription;
  }

  public void setLongDescription(String longDescription) {
    this.longDescription = longDescription;
  }

  public String getPublisher() {
    return publisher;
  }

  public void setPublisher(String publisher) {
    this.publisher = publisher;
  }

  public String getContributor() {
    return contributor;
  }

  public void setContributor(String contributor) {
    this.contributor = contributor;
  }

  public URI getRelation() {
    return relation;
  }

  public void setRelation(URI relation) {
    this.relation = relation;
  }

  public String getRights() {
    return rights;
  }

  public void setRights(String rights) {
    this.rights = rights;
  }

  public String getDate() {
    return date;
  }

  public void setDate(String date) {
    this.date = date;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.Album
 * JD-Core Version:    0.6.2
 */