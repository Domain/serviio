module org.serviio.licensing.CustomerLicenseProvider;

import org.serviio.config.Configuration;

public class CustomerLicenseProvider
  : LicenseProvider
{
  public String readLicense()
  {
    return Configuration.getCustomerLicense();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.licensing.CustomerLicenseProvider
 * JD-Core Version:    0.6.2
 */