module org.serviio.ui.representation.ConsoleSettingsRepresentation;

public class ConsoleSettingsRepresentation
{
  private String language;
  private String securityPin;
  private Boolean checkForUpdates;

  public String getLanguage()
  {
    return language;
  }

  public void setLanguage(String language) {
    this.language = language;
  }

  public String getSecurityPin() {
    return securityPin;
  }

  public void setSecurityPin(String securityPin) {
    this.securityPin = securityPin;
  }

  public Boolean getCheckForUpdates() {
    return checkForUpdates;
  }

  public void setCheckForUpdates(Boolean checkForUpdates) {
    this.checkForUpdates = checkForUpdates;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.representation.ConsoleSettingsRepresentation
 * JD-Core Version:    0.6.2
 */