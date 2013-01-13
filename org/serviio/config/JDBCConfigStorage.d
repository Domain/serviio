module org.serviio.config.JDBCConfigStorage;

import java.lang.String;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.serviio.config.entities.ConfigEntry;
import org.serviio.db.dao.DAOFactory;
import org.serviio.config.ConfigStorage;

public class JDBCConfigStorage
  : ConfigStorage
{
  public Map!(String, String) readAllConfigurationValues()
  {
    Map!(String, String) values = new HashMap!(String, String)();
    List!(ConfigEntry) configEntries = DAOFactory.getConfigEntryDAO().findAllConfigEntries();
    foreach (ConfigEntry configEntry ; configEntries) {
      values.put(configEntry.getName(), configEntry.getValue());
    }
    return values;
  }

  public void storeValue(String name, String value)
  {
    ConfigEntry configEntry = DAOFactory.getConfigEntryDAO().findConfigEntryByName(name);
    if (configEntry !is null) {
      configEntry.setValue(value);
      DAOFactory.getConfigEntryDAO().update(configEntry);
    } else {
      configEntry = new ConfigEntry(name, value);
      DAOFactory.getConfigEntryDAO().create(configEntry);
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.config.JDBCConfigStorage
 * JD-Core Version:    0.6.2
 */