module org.serviio.library.entities.Genre;

import java.lang.String;
import org.serviio.db.entities.PersistedEntity;

public class Genre : PersistedEntity
{
  public static const int NAME_MAX_LENGTH = 128;
  private String name;

  public this(String name)
  {
    this.name = name;
  }

  public String getName()
  {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.entities.Genre
 * JD-Core Version:    0.6.2
 */