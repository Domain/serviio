module org.serviio.library.AbstractLibraryManager;

import org.serviio.library.metadata.AbstractLibraryCheckerThread;
import org.serviio.library.metadata.LibraryIndexingListener;
import org.serviio.util.ThreadUtils;

public abstract class AbstractLibraryManager
{
  protected LibraryIndexingListener cdsListener;

  protected void stopThread(AbstractLibraryCheckerThread thread)
  {
    if (thread !is null)
    {
      thread.stopWorker();

      while (thread.isAlive())
        ThreadUtils.currentThreadSleep(100L);
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.AbstractLibraryManager
 * JD-Core Version:    0.6.2
 */