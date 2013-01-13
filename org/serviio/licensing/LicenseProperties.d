module org.serviio.licensing.LicenseProperties;

public class LicenseProperties
{
	enum LicensePropertiesEnum : String
	{
		TYPE = "type", 

		EDITION = "edition", 

		VERSION = "version", 

		ID = "id", 

		NAME = "name", 

		EMAIL = "email",
	}
	LicensePropertiesEnum licenseProperties;
	alias licenseProperties this;

  public String getName()
  {
	  return cast(String)licenseProperties;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.licensing.LicenseProperties
 * JD-Core Version:    0.6.2
 */