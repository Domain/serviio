module org.serviio.ui.resources.server.ApplicationServerResource;

import org.serviio.MediaServer;
import org.serviio.licensing.LicensingManager;
import org.serviio.licensing.ServiioLicense;
import org.serviio.restlet.AbstractServerResource;
import org.serviio.ui.representation.ApplicationRepresentation;
import org.serviio.ui.representation.LicenseRepresentation;
import org.serviio.ui.resources.ApplicationResource;
import org.serviio.update.UpdateChecker;

public class ApplicationServerResource : AbstractServerResource
  , ApplicationResource
{
  public ApplicationRepresentation load()
  {
    ApplicationRepresentation rep = new ApplicationRepresentation();
    rep.setUpdateVersionAvailable(UpdateChecker.getNewAvailableVersion());
    rep.setVersion(MediaServer.VERSION);

    ServiioLicense lic = LicensingManager.getInstance().getLicense();

    rep.setEdition(lic.getEdition());
    if (lic.getEdition() != LicensingManager.ServiioEdition.FREE) {
      rep.setLicense(buildLicense(lic));
    }
    return rep;
  }

  private LicenseRepresentation buildLicense(ServiioLicense lic) {
    LicenseRepresentation rep = new LicenseRepresentation();
    rep.setEmail(lic.isBundled() ? null : lic.getEmail());
    rep.setExpiresInMinutes(getExpiresInMinutes(lic.getRemainingMillis()));
    rep.setId(lic.isBundled() ? null : lic.getId());
    rep.setName(lic.isBundled() ? null : lic.getName());
    rep.setType(lic.getType());
    return rep;
  }

  private Integer getExpiresInMinutes(Long milliseconds) {
    return milliseconds !is null ? Integer.valueOf((new Long(milliseconds.longValue() / 60000L)).intValue()) : null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.resources.server.ApplicationServerResource
 * JD-Core Version:    0.6.2
 */