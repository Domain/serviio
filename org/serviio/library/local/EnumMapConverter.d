module org.serviio.library.local.EnumMapConverter;

import java.lang.String;
import java.util.HashMap;
import java.util.Map;
import org.serviio.util.CollectionUtils;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;

public abstract class EnumMapConverter(E)
{
  public Map!(E, String) convert(String identifiersCSV)
  {
    Map!(E, String) result = new HashMap!(E, String)();
    if (ObjectValidator.isNotEmpty(identifiersCSV)) {
      String[] identifiers = identifiersCSV.split(",");
      foreach (String identifier ; identifiers) {
        String[] entries = identifier.split("=");
        result.put(enumValue(StringUtils.localeSafeToUppercase(entries[0].trim())), entries[1].trim());
      }
    }
    return result;
  }

  public String parseToString(Map!(E, String) map) {
    return CollectionUtils.mapToCSV(map, ",", true);
  }

  protected abstract E enumValue(String paramString);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.EnumMapConverter
 * JD-Core Version:    0.6.2
 */