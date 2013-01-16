module org.serviio.util.ServiioThreadFactory;

import java.lang.String;
import java.lang.Thread;
import java.lang.Runnable;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.atomic.AtomicInteger;

public class ServiioThreadFactory
  : ThreadFactory
{
  private static const String GROUP_NAME = "ServioThreads";
  private static const String THREAD_PREFIX = "ServioThread-";
  private static ServiioThreadFactory instance;
  private ThreadGroup group;
  private const AtomicInteger threadNumber = new AtomicInteger(1);

  private this()
  {
    group = new ThreadGroup(GROUP_NAME);
  }

  public static ServiioThreadFactory getInstance()
  {
    if (instance is null) {
      instance = new ServiioThreadFactory();
    }
    return instance;
  }

  public Thread newThread(Runnable r)
  {
    return newThread(r, null, true);
  }

  public Thread newThread(Runnable r, String name, bool daemon)
  {
    Thread t = new Thread(group, r, THREAD_PREFIX + threadNumber.getAndIncrement() + "-" + name);
    t.setDaemon(daemon);
    t.setPriority(5);
    return t;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.ServiioThreadFactory
 * JD-Core Version:    0.6.2
 */