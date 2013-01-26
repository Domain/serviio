module org.serviio.ui.representation.LicenseRepresentation;

import java.lang.String;
import java.lang.Integer;
import org.serviio.licensing.LicensingManager;

public class LicenseRepresentation
{
    private String id;
    private LicensingManager.ServiioLicenseType type;
    private String name;
    private String email;
    private Integer expiresInMinutes;

    public String getId()
    {
        return id;
    }
    public void setId(String id) {
        this.id = id;
    }
    public LicensingManager.ServiioLicenseType getType() {
        return type;
    }
    public void setType(LicensingManager.ServiioLicenseType type) {
        this.type = type;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }
    public Integer getExpiresInMinutes() {
        return expiresInMinutes;
    }
    public void setExpiresInMinutes(Integer expiresInMinutes) {
        this.expiresInMinutes = expiresInMinutes;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.ui.representation.LicenseRepresentation
* JD-Core Version:    0.6.2
*/