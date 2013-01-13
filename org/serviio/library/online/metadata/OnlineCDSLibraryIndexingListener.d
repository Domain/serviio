module org.serviio.library.online.metadata.OnlineCDSLibraryIndexingListener;

import org.serviio.library.metadata.AbstractCDSLibraryIndexingListener;

public class OnlineCDSLibraryIndexingListener : AbstractCDSLibraryIndexingListener
{
  protected void performCDSUpdate()
  {
    cds.incrementUpdateID(false);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.metadata.OnlineCDSLibraryIndexingListener
 * JD-Core Version:    0.6.2
 */