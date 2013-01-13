module org.serviio.library.online.PluginExecutionProcessor;

import java.util.concurrent.Callable;
import java.util.concurrent.CancellationException;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import org.serviio.util.ServiioThreadFactory;

public abstract class PluginExecutionProcessor(T)
{
  private static ExecutorService executor = Executors.newCachedThreadPool(ServiioThreadFactory.getInstance());

  public static void shutdown()
  {
    executor.shutdownNow();
  }

  public T execute(int millisecondsTimeout)
  {
    Future!(T) future = executor.submit(new class() Callable!(T) {
      public T call() {
        return executePluginMethod();
      }

    });
    try
    {
      return cast(T) future.get(millisecondsTimeout, TimeUnit.MILLISECONDS);
    } catch (ExecutionException e) {
      throw e.getCause();
    } catch (InterruptedException e) {
      throw new RuntimeException("The operation has been interrupted.");
    } catch (CancellationException e) {
      throw new RuntimeException("The operation has been cancelled.");
    } catch (TimeoutException e) {
      throw new RuntimeException(String.format("The operation took more than %s ms and has been cancelled.", cast(Object[])[ Integer.valueOf(millisecondsTimeout) ]));
    }
    finally {
      cancel(future);
    }
  }

  protected abstract T executePluginMethod();

  private void cancel(Future!(T) future) {
    future.cancel(true);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.PluginExecutionProcessor
 * JD-Core Version:    0.6.2
 */