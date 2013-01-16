module org.serviio.library.metadata.AbstractLibraryCheckerThread;

import java.lang.Thread;
import java.lang.String;
import java.util.HashSet;
import java.util.Set;
import org.serviio.library.metadata.LibraryIndexingListener;

public abstract class AbstractLibraryCheckerThread : Thread
{
  protected bool workerRunning = false;

  protected bool searchingForFiles = false;

  protected bool isSleeping = false;

  protected bool dontSleep = false;

  private Set!(LibraryIndexingListener) listeners = new HashSet!(LibraryIndexingListener)();

  public void stopWorker()
  {
    workerRunning = false;

    interrupt();
  }

  public void invoke()
  {
    if (isSleeping)
      interrupt();
    else
      dontSleep = true;
  }

  public bool isWorkerRunning()
  {
    return workerRunning;
  }

  public bool isSearchingForFiles() {
    return searchingForFiles;
  }

  public void addListener(LibraryIndexingListener listener) {
    listeners.add(listener);
  }

  protected void notifyListenersAdd(String item)
  {
    foreach (LibraryIndexingListener l ; listeners)
      l.itemAdded(item);
  }

  protected void notifyListenersUpdate(String item)
  {
    foreach (LibraryIndexingListener l ; listeners)
      l.itemUpdated(item);
  }

  protected void notifyListenersRemove(String item)
  {
    foreach (LibraryIndexingListener l ; listeners)
      l.itemDeleted(item);
  }

  protected void notifyListenersResetForAdding()
  {
    foreach (LibraryIndexingListener l ; listeners)
      l.resetForAdding();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.metadata.AbstractLibraryCheckerThread
 * JD-Core Version:    0.6.2
 */