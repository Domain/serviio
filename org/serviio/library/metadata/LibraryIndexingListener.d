module org.serviio.library.metadata.LibraryIndexingListener;

public abstract interface LibraryIndexingListener
{
  public abstract void itemAdded(String paramString);

  public abstract void itemUpdated(String paramString);

  public abstract void itemDeleted(String paramString);

  public abstract void resetForAdding();
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.metadata.LibraryIndexingListener
 * JD-Core Version:    0.6.2
 */