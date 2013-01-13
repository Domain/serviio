module org.serviio.util.ThreadUtils;

public class ThreadUtils
{
  public static void currentThreadSleep(long milliseconds)
  {
    try
    {
      Thread.sleep(milliseconds);
    }
    catch (InterruptedException e)
    {
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.ThreadUtils
 * JD-Core Version:    0.6.2
 */