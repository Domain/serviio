module org.serviio.profile.DetectionDefinition;

import java.util.HashMap;
import java.util.Map;

public class DetectionDefinition
{
  private Map!(String, String) fieldValues = new HashMap!(String, String)();
  private DetectionType type;

  public this(DetectionType type)
  {
    this.type = type;
  }

  public Map!(String, String) getFieldValues()
  {
    return fieldValues;
  }

  public DetectionType getType() {
    return type;
  }

  public void setType(DetectionType type) {
    this.type = type;
  }

  public static enum DetectionType
  {
    UPNP_SEARCH, HTTP_HEADERS
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.profile.DetectionDefinition
 * JD-Core Version:    0.6.2
 */