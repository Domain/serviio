module org.serviio.util.Platform;

public class Platform
{
  //private static final String OS = System.getProperty("os.name");

  public static bool isWindows() {
	  version(Windows)
		  return true;
	  else
		  return false;
  }

  public static bool isLinux() {
	  version(linux)
		  return true;
	  else
		  return false;
  }

  public static bool isMac() {
	  version(OSX)
		  return true;
	  else
		  return false;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.Platform
 * JD-Core Version:    0.6.2
 */