module org.serviio.db.entities.PersistedEntity;

import java.lang.Long;

public abstract class PersistedEntity
{
  protected Long id;

  public Long getId()
  {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public override hash_t toHash()
  {
    int prime = 31;
    int result = 1;
    result = prime * result + (id is null ? 0 : id.hashCode());
    return result;
  }

  public override equals_t opEquals(Object obj)
  {
    if (this == obj)
      return true;
    if (obj is null)
      return false;
    if (getClass() != obj.getClass())
      return false;
    PersistedEntity other = cast(PersistedEntity)obj;
    if (id is null) {
      if (other.id !is null)
        return false;
    } else if (!id.equals(other.id))
      return false;
    return true;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.db.entities.PersistedEntity
 * JD-Core Version:    0.6.2
 */