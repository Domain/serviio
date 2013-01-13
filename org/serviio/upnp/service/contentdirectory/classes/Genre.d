module org.serviio.upnp.service.contentdirectory.classes.Genre;

public class Genre : Container
{
  protected String description;
  protected String longDescription;

  public this(String id, String title)
  {
    super(id, title);
  }

  public ObjectClassType getObjectClass()
  {
    return ObjectClassType.GENRE;
  }

  public String getDescription()
  {
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
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.Genre
 * JD-Core Version:    0.6.2
 */