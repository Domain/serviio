module org.serviio.upnp.service.contentdirectory.classes.AudioItem;

import java.net.URI;

public class AudioItem : Item
{
  protected String genre;
  protected String description;
  protected String longDescription;
  protected String publisher;
  protected String language;
  protected URI relation;
  protected String rights;
  protected Boolean live;

  public this(String id, String title)
  {
    super(id, title);
  }

  public ObjectClassType getObjectClass()
  {
    return ObjectClassType.AUDIO_ITEM;
  }

  public String getGenre()
  {
    return genre;
  }
  public void setGenre(String genre) {
    this.genre = genre;
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
  public String getLanguage() {
    return language;
  }
  public void setLanguage(String language) {
    this.language = language;
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

  public Boolean getLive() {
    return live;
  }
  public void setLive(Boolean live) {
    this.live = live;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.AudioItem
 * JD-Core Version:    0.6.2
 */