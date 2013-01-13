module org.serviio.licensing.ServiioLicense;

public class ServiioLicense
{
  private LicensingManager.ServiioEdition edition;
  private LicensingManager.ServiioLicenseType type;
  private String name;
  private String email;
  private String id;
  private String ver;
  private Long remainingMillis;
  public static final ServiioLicense FREE_LICENSE = new ServiioLicense(null, LicensingManager.ServiioEdition.FREE, null, null, null, null, null);

  public this(String id, LicensingManager.ServiioEdition edition, LicensingManager.ServiioLicenseType type, String name, String email, String ver, Long remainingMillis)
  {
    this.id = id;
    this.edition = edition;
    this.type = type;
    this.name = name;
    this.email = email;
    this.ver = ver;
    this.remainingMillis = remainingMillis;
  }

  public bool isBundled() {
    return (type is null) || (type == LicensingManager.ServiioLicenseType.BETA) || (type == LicensingManager.ServiioLicenseType.EVALUATION);
  }

  public LicensingManager.ServiioEdition getEdition()
  {
    return edition;
  }

  public LicensingManager.ServiioLicenseType getType() {
    return type;
  }

  public String getName() {
    return name;
  }

  public String getEmail() {
    return email;
  }

  public String getId() {
    return id;
  }

  public String getVersion() {
    return ver;
  }

  public Long getRemainingMillis() {
    return remainingMillis;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.licensing.ServiioLicense
 * JD-Core Version:    0.6.2
 */