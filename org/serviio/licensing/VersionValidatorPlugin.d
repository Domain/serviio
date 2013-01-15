module org.serviio.licensing.VersionValidatorPlugin;

import net.padlocksoftware.padlock.license.License;
import net.padlocksoftware.padlock.license.LicenseTest;
import net.padlocksoftware.padlock.license.TestResult;
import net.padlocksoftware.padlock.validator.ValidationParameters;
import net.padlocksoftware.padlock.validator.ValidatorPlugin;
import org.serviio.MediaServer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class VersionValidatorPlugin
  : ValidatorPlugin
{
  private static final Logger log = LoggerFactory.getLogger!(VersionValidatorPlugin)();
  private static final String NAME = "Serviio Version Validator Plugin";
  private static final String DESCRIPTION = "Checks that the license has been released for the samemajor version as the current version.";

  public TestResult validate(License license, ValidationParameters validationParameters)
  {
    String licenseVersion = license.getProperty(LicenseProperties.VERSION.getName());
    String currentVersion = MediaServer.VERSION;
    bool passed = false;
    try {
      passed = isSupportedVersion(currentVersion, licenseVersion);
      passed = (passed) || (license.getProperty(LicenseProperties.TYPE.getName()).equals(LicensingManager.ServiioLicenseType.UNLIMITED.toString()));
    } catch (Exception e) {
      log.debug_("Could not compute license version validity. Marking license as invalid.", e);
    }
    return new TestResult(new LicenseTest("org.serviio.major_version_test", "Major version check", "Major version check passed", "Major version check failed"), passed);
  }

  public String getDescription()
  {
    return DESCRIPTION;
  }

  public String getName()
  {
    return NAME;
  }

  private bool isSupportedVersion(String currentVersion, String licenseVersion)
  {
    byte currentMajorVersion = getMajorVersion(currentVersion);
    byte licenseMajorVersion = getMajorVersion(licenseVersion);
    return currentMajorVersion <= licenseMajorVersion;
  }

  private byte getMajorVersion(String versionString) {
    return Byte.valueOf(versionString.substring(0, versionString.indexOf("."))).byteValue();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.licensing.VersionValidatorPlugin
 * JD-Core Version:    0.6.2
 */