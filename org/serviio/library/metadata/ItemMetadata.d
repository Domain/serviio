module org.serviio.library.metadata.ItemMetadata;

import java.util.Date;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;

public abstract class ItemMetadata
{
  public static final String UNKNOWN_ENTITY = "Unknown";
  protected String title;
  protected String author;
  protected Date date;
  protected String description;

  public void fillInUnknownEntries()
  {
    if (ObjectValidator.isEmpty(author))
      setAuthor("Unknown");
  }

  public void validateMetadata()
  {
    if (ObjectValidator.isEmpty(title))
      throw new InvalidMetadataException("Title is empty.");
  }

  public String getTitle()
  {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public String getAuthor() {
    return author;
  }

  public void setAuthor(String author) {
    this.author = author;
  }

  public Date getDate() {
    return date;
  }

  public void setDate(Date date) {
    this.date = date;
  }

  public String getDescription() {
    return description;
  }

  public void setDescription(String description)
  {
    if (description !is null) {
      description = StringUtils.removeNewLineCharacters(description);
      if (description.length() > 1024)
      {
        this.description = (description.substring(0, 1020) + " ...");
        return;
      }
    }
    this.description = description;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.metadata.ItemMetadata
 * JD-Core Version:    0.6.2
 */