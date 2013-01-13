module org.serviio.upnp.service.contentdirectory.definition.WMPContentDirectoryDefinitionFilter;

import java.util.Map;
import org.serviio.upnp.service.contentdirectory.classes.ClassProperties;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;

public class WMPContentDirectoryDefinitionFilter
  : ContentDirectoryDefinitionFilter
{
  public String filterObjectId(String requestedNodeId, bool isSearch)
  {
    if (requestedNodeId.equals("2"))
    {
      return "V";
    }if (requestedNodeId.equals("3"))
      return "I";
    if (requestedNodeId.equals("1")) {
      return "A";
    }

    return requestedNodeId;
  }

  public ObjectClassType filterContainerClassType(ObjectClassType requestedObjectClass, String objectId)
  {
    return requestedObjectClass;
  }

  public void filterClassProperties(String objectId, Map!(ClassProperties, Object) values)
  {
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.definition.WMPContentDirectoryDefinitionFilter
 * JD-Core Version:    0.6.2
 */