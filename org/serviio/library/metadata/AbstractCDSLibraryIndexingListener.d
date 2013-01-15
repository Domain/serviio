module org.serviio.library.metadata.AbstractCDSLibraryIndexingListener;

import java.util.concurrent.atomic.AtomicBoolean;
import org.serviio.upnp.Device;
import org.serviio.upnp.service.contentdirectory.ContentDirectory;
import org.serviio.util.ServiioThreadFactory;
import org.serviio.util.ThreadUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class AbstractCDSLibraryIndexingListener
  : LibraryIndexingListener
{
  private static final Logger log = LoggerFactory.getLogger!(AbstractCDSLibraryIndexingListener)();
  private static final int UPDATE_THREAD_INTERVAL_SECONDS = 5;
  private int threadUpdateInterval = UPDATE_THREAD_INTERVAL_SECONDS;

  protected ContentDirectory cds = cast(ContentDirectory)Device.getInstance().getServiceById("urn:upnp-org:serviceId:ContentDirectory");

  private AtomicBoolean libraryUpdated = new AtomicBoolean(false);
  private String lastAddedFile;
  private int numberOfAddedFiles = 0;

  public this()
  {
    ServiioThreadFactory.getInstance().newThread(new CDSNotifierThread(), "CDS library notifier", true).start();
  }

  public this(int intervalSeconds) {
    this();
    threadUpdateInterval = intervalSeconds;
  }

  public void resetForAdding()
  {
    lastAddedFile = null;
    numberOfAddedFiles = 0;
  }

  public void itemAdded(String file)
  {
    lastAddedFile = file;
    numberOfAddedFiles += 1;
    isLibraryUpdated().set(true);
  }

  public void itemDeleted(String file)
  {
    isLibraryUpdated().set(true);
  }

  public void itemUpdated(String file)
  {
    isLibraryUpdated().set(true);
  }

  protected abstract void performCDSUpdate();

  protected void notifyCDS()
  {
    log.debug_("Library updated, notifying CDS");
    performCDSUpdate();
    isLibraryUpdated().set(false);
  }

  public AtomicBoolean isLibraryUpdated()
  {
    return libraryUpdated;
  }

  public String getLastAddedFile() {
    return lastAddedFile;
  }

  public int getNumberOfAddedFiles() {
    return numberOfAddedFiles;
  }

  private class CDSNotifierThread : Runnable
  {
    private this()
    {
    }

    public void run()
    {
      while (true) {
        if (isLibraryUpdated().get()) {
          notifyCDS();
        }
        ThreadUtils.currentThreadSleep(threadUpdateInterval * 1000);
      }
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.metadata.AbstractCDSLibraryIndexingListener
 * JD-Core Version:    0.6.2
 */