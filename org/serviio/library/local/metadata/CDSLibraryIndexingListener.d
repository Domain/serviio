module org.serviio.library.local.metadata.CDSLibraryIndexingListener;

import org.serviio.library.metadata.AbstractCDSLibraryIndexingListener;

public class CDSLibraryIndexingListener : AbstractCDSLibraryIndexingListener
{
    override protected void performCDSUpdate()
    {
        cds.incrementUpdateID();
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.local.metadata.CDSLibraryIndexingListener
* JD-Core Version:    0.6.2
*/