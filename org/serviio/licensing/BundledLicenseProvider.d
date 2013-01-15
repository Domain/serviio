module org.serviio.licensing.BundledLicenseProvider;

import java.io.IOException;
import org.serviio.util.FileUtils;
import org.serviio.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class BundledLicenseProvider
  : LicenseProvider
{
  private static final Logger log = LoggerFactory.getLogger!(BundledLicenseProvider)();

  private static final String BUNDLED_LICENSE_CONTENT = readBundledLicense();

  public String readLicense()
  {
    return BUNDLED_LICENSE_CONTENT;
  }

  private static String readBundledLicense()
  {
    try {
      return StringUtils.readStreamAsString(FileUtils.getStreamFromClasspath("/default.lic", LicenseValidator.class_), "UTF-8");
    } catch (IOException e) {
      log.warn("Cannot find bundled license");
    }return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.licensing.BundledLicenseProvider
 * JD-Core Version:    0.6.2
 */