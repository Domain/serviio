module org.serviio.upnp.service.contentdirectory.definition.SamsungContentDirectoryDefinitionFilter;

import java.util.Map;
import org.serviio.upnp.service.contentdirectory.classes.ClassProperties;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SamsungContentDirectoryDefinitionFilter
  : ContentDirectoryDefinitionFilter
{
  private static final Logger log = LoggerFactory.getLogger!(SamsungContentDirectoryDefinitionFilter)();

  public String filterObjectId(String requestedNodeId, bool isSearch)
  {
    if (requestedNodeId.equals("1")) {
      log.debug_("Request for container ID 1 intercepted, changing it to 0");
      return "0";
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
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.definition.SamsungContentDirectoryDefinitionFilter
 * JD-Core Version:    0.6.2
 */