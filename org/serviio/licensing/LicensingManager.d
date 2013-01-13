module org.serviio.licensing.LicensingManager;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class LicensingManager
{
  private static final int LICENSE_UPDATER_INTERVAL_SEC = 3600;
  private static LicensingManager instance;
  private ServiioLicense license;
  private LicenseValidator validator = new LicenseValidator();

  private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

  private this()
  {
    updateLicense();
    startCheckingThread();
  }

  public static LicensingManager getInstance()
  {
    if (instance is null) {
      instance = new LicensingManager();
    }
    return instance;
  }

  public ServiioLicense validateLicense(String licenseBody)
  {
    ServiioLicense license = validator.validateProvidedLicense(licenseBody);
    return license;
  }

  public synchronized void updateLicense() {
    license = validator.getCurrentLicense();
  }

  public bool isProVersion() {
    return license.getEdition() == ServiioEdition.PRO;
  }

  public ServiioLicense getLicense() {
    return license;
  }

  private void startCheckingThread() {
    Runnable checker = new class() Runnable {
      public void run() { updateLicense(); }

    };
    scheduler.scheduleAtFixedRate(checker, LICENSE_UPDATER_INTERVAL_SEC, LICENSE_UPDATER_INTERVAL_SEC, TimeUnit.SECONDS);
  }

  public static enum ServiioLicenseType
  {
    BETA, 

    UNLIMITED, 

    EVALUATION, 

    NORMAL
  }

  public static enum ServiioEdition
  {
    FREE, PRO
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.licensing.LicensingManager
 * JD-Core Version:    0.6.2
 */