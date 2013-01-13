module org.serviio.upnp.service.contentdirectory.classes.StorageFolder;

public class StorageFolder : Container
{
  protected Long storageUsed;

  public this(String id, String title)
  {
    super(id, title);
  }

  public ObjectClassType getObjectClass()
  {
    return ObjectClassType.STORAGE_FOLDER;
  }

  public Long getStorageUsed()
  {
    return storageUsed;
  }

  public void setStorageUsed(Long storageUsed) {
    this.storageUsed = storageUsed;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.StorageFolder
 * JD-Core Version:    0.6.2
 */