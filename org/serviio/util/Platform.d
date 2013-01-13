module org.serviio.util.Platform;

public class Platform
{
  private static final String OS = System.getProperty("os.name");

  public static bool isWindows() {
    return OS.startsWith("Windows");
  }

  public static bool isLinux() {
    return (OS.startsWith("Linux")) || (OS.startsWith("Unix")) || (OS.startsWith("FreeBSD"));
  }

  public static bool isMac() {
    return OS.startsWith("Mac");
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.Platform
 * JD-Core Version:    0.6.2
 */