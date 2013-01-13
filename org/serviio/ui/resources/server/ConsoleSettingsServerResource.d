module org.serviio.ui.resources.server.ConsoleSettingsServerResource;

import org.serviio.config.Configuration;
import org.serviio.restlet.AbstractServerResource;
import org.serviio.restlet.ResultRepresentation;
import org.serviio.ui.representation.ConsoleSettingsRepresentation;
import org.serviio.ui.resources.ConsoleSettingsResource;

public class ConsoleSettingsServerResource : AbstractServerResource
  , ConsoleSettingsResource
{
  public ConsoleSettingsRepresentation load()
  {
    ConsoleSettingsRepresentation rep = new ConsoleSettingsRepresentation();
    rep.setLanguage(Configuration.getConsolePreferredLanguage());
    rep.setSecurityPin(Configuration.getConsoleSecurityPin());
    rep.setCheckForUpdates(Boolean.valueOf(Configuration.isConsoleCheckForUpdatesEnabled()));
    return rep;
  }

  public ResultRepresentation save(ConsoleSettingsRepresentation rep)
  {
    if (rep.getLanguage() !is null) {
      Configuration.setConsolePreferredLanguage(rep.getLanguage());
    }

    Configuration.setConsoleSecurityPin(rep.getSecurityPin());

    if (rep.getCheckForUpdates() !is null) {
      Configuration.setConsoleCheckForUpdatesEnabled(rep.getCheckForUpdates().boolValue());
    }

    return responseOk();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.resources.server.ConsoleSettingsServerResource
 * JD-Core Version:    0.6.2
 */