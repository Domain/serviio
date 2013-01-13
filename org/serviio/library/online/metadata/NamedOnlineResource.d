module org.serviio.library.online.metadata.NamedOnlineResource;

public class NamedOnlineResource(T)
{
  private T onlineItem;
  private String repositoryName;

  public this(T onlineItem, String repositoryName)
  {
    this.onlineItem = onlineItem;
    this.repositoryName = repositoryName;
  }

  public T getOnlineItem() {
    return onlineItem;
  }

  public String getRepositoryName() {
    return repositoryName;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.metadata.NamedOnlineResource
 * JD-Core Version:    0.6.2
 */