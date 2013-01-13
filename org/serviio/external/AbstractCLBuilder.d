module org.serviio.external.AbstractCLBuilder;

import java.lang.String;
import java.lang.System;
import java.io.File;
import org.serviio.ApplicationSettings;
import org.serviio.util.ObjectValidator;
import org.serviio.util.Platform;

public abstract class AbstractCLBuilder
{
  protected static String setupExecutablePath(String systemPropertyName, String builtInPropertyName)
  {
    if (ObjectValidator.isEmpty(System.getProperty(systemPropertyName))) {
      if (Platform.isLinux()) {
        return ApplicationSettings.getStringProperty(builtInPropertyName);
      }

      if (System.getProperty("serviio.home") is null)
      {
        return ApplicationSettings.getStringProperty(builtInPropertyName);
      }
      return System.getProperty("serviio.home") + File.separator + ApplicationSettings.getStringProperty(builtInPropertyName);
    }

    return System.getProperty(systemPropertyName);
  }

  public abstract String[] build();
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.external.AbstractCLBuilder
 * JD-Core Version:    0.6.2
 */