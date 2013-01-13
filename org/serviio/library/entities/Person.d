module org.serviio.library.entities.Person;

import org.serviio.db.entities.PersistedEntity;

public class Person : PersistedEntity
{
  public static final int NAME_MAX_LENGTH = 128;
  private String name;
  private String sortName;
  private String initial;

  public this(String name, String sortName, String initial)
  {
    this.name = name;
    this.sortName = sortName;
    this.initial = initial;
  }

  public String getName()
  {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getSortName() {
    return sortName;
  }

  public void setSortName(String sortName) {
    this.sortName = sortName;
  }

  public String getInitial() {
    return initial;
  }

  public void setInitial(String initial) {
    this.initial = initial;
  }

  public String toString()
  {
    return String.format("Person [name=%s, sortName=%s]", cast(Object[])[ name, sortName ]);
  }

  public static enum RoleType
  {
    ARTIST, ACTOR, DIRECTOR, WRITER, PRODUCER, ALBUM_ARTIST, COMPOSER
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.entities.Person
 * JD-Core Version:    0.6.2
 */