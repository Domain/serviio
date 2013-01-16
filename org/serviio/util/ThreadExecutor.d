module org.serviio.util.ThreadExecutor;

import java.lang.Runnable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class ThreadExecutor
{
  private static ExecutorService executor = Executors.newFixedThreadPool(10);

  public static void execute(Runnable r) {
    executor.execute(r);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.ThreadExecutor
 * JD-Core Version:    0.6.2
 */