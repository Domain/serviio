module org.serviio.ApplicationSettings;

import java.lang.String;
import java.lang.Integer;
import java.util.Properties;

public class ApplicationSettings
{
  private static Properties properties = new Properties();

  public static Properties getProperties()
  {
    return properties;
  }

  public static String getStringProperty(String name) {
    return cast(String)getProperties().get(name);
  }

  public static Integer getIntegerProperty(String name) {
    String strValue = getStringProperty(name);
    if (strValue !is null) {
      return Integer.valueOf(strValue);
    }
    return null;
  }

  static this()
  {
    try
    {
      properties.load(ApplicationSettings.class_.getResourceAsStream("/serviio.properties"));
    }
    catch (Exception e)
    {
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ApplicationSettings
 * JD-Core Version:    0.6.2
 */