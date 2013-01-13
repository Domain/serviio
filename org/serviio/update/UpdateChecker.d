module org.serviio.update.UpdateChecker;

import java.io.ByteArrayInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.Comparator;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import javax.xml.xpath.XPathExpressionException;
import org.serviio.ApplicationSettings;
import org.serviio.MediaServer;
import org.serviio.util.HttpClient;
import org.serviio.util.Platform;
import org.serviio.util.XPathUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Node;

public class UpdateChecker
{
  private static final Logger log = LoggerFactory.getLogger!(UpdateChecker);

  private static final String XML_URL = ApplicationSettings.getStringProperty("update_url");
  private static final int VERSION_CHECKER_INTERVAL_HOURS = 24;
  private static String availableNewVersion = null;

  private static final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

  public static void startCheckerThread()
  {
    Runnable checker = new class() Runnable {
      public void run() {}
    };
    scheduler.scheduleAtFixedRate(checker, 0L, VERSION_CHECKER_INTERVAL_HOURS, TimeUnit.HOURS);
  }

  public static String getNewAvailableVersion() {
    return availableNewVersion;
  }

  
private static void checkForUpdate()
  {
    log.info("Checking if a new version is available");
    try {
      String xml = HttpClient.retrieveTextFileFromURL(XML_URL, "UTF-8");
      if (xml !is null) {
        availableNewVersion = runCheck(new ByteArrayInputStream(xml.getBytes()), MediaServer.VERSION);
        return;
      }
    } catch (FileNotFoundException e) {
      log.debug_("Cannot find the update XML file. Message: " + e.getMessage());
    } catch (IOException e) {
      log.debug_("Cannot retrieve the update XML file. Message: " + e.getMessage());
    }
    availableNewVersion = null;
  }

  protected static bool versionGreaterThanCurrent(String releasedVersion, String currentVersion)
  {
    if ((releasedVersion !is null) && (currentVersion !is null)) {
      Comparator!(String) comparator = new VersionStringComparator();
      return comparator.compare(releasedVersion, currentVersion) > 0;
    }
    return false;
  }

  protected static String runCheck(InputStream xml, String currentVersion)
  {
    try
    {
      Node root = XPathUtil.getRootNode(xml);
      String osName = "";
      if (root !is null) {
        if (Platform.isWindows())
          osName = "windows";
        else if (Platform.isLinux())
          osName = "linux";
        else if (Platform.isMac())
          osName = "osx";
        else {
          return null;
        }
        String releasedVersion = XPathUtil.getNodeValue(root, "/serviio_releases/release[@os='" + osName + "']/@version");
        if (versionGreaterThanCurrent(releasedVersion, currentVersion))
          return releasedVersion;
      }
    }
    catch (XPathExpressionException e) {
      log.error("Cannot check for latest released version because the XML is corrupted.");
    }
    return null;
  }

  private static class VersionStringComparator
    : Comparator!(String)
  {
    public int compare(String s1, String s2)
    {
      if ((s1 is null) && (s2 is null))
        return 0;
      if (s1 is null)
        return -1;
      if (s2 is null) {
        return 1;
      }

      String[] arr1 = s1.split("[^a-zA-Z0-9]+"); String[] arr2 = s2.split("[^a-zA-Z0-9]+");

      int ii = 0; for (int max = Math.min(arr1.length, arr2.length); ii <= max; ii++) {
        if (ii == arr1.length)
          return ii == arr2.length ? 0 : -1;
        if (ii == arr2.length)
          return 1;
        int i1;
        try
        {
          i1 = Integer.parseInt(arr1[ii]);
        } catch (Exception x) {
          i1 = 2147483647;
        }
        int i2;
        try {
          i2 = Integer.parseInt(arr2[ii]);
        } catch (Exception x) {
          i2 = 2147483647;
        }

        if (i1 != i2) {
          return i1 - i2;
        }

        int i3 = arr1[ii].compareTo(arr2[ii]);

        if (i3 != 0)
          return i3;
      }
      return 0;
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.update.UpdateChecker
 * JD-Core Version:    0.6.2
 */