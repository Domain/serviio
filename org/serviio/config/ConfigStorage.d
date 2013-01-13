module org.serviio.config.ConfigStorage;

import java.lang.String;
import java.util.Map;

public abstract interface ConfigStorage
{
  public abstract Map!(String, String) readAllConfigurationValues();

  public abstract void storeValue(String paramString1, String paramString2);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.config.ConfigStorage
 * JD-Core Version:    0.6.2
 */