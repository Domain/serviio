module org.serviio.ui.representation.ConsoleSettingsRepresentation;

import java.lang.String;

public class ConsoleSettingsRepresentation
{
    private String language;
    private String securityPin;
    private bool checkForUpdates;

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

    public bool getCheckForUpdates() {
        return checkForUpdates;
    }

    public void setCheckForUpdates(bool checkForUpdates) {
        this.checkForUpdates = checkForUpdates;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.ui.representation.ConsoleSettingsRepresentation
* JD-Core Version:    0.6.2
*/