module org.serviio.upnp.service.contentdirectory.definition.XBox360ContentDirectoryDefinitionFilter;

import java.util.Map;
import org.serviio.upnp.service.contentdirectory.classes.ClassProperties;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;

public class XBox360ContentDirectoryDefinitionFilter
  : ContentDirectoryDefinitionFilter
{
  public String filterObjectId(String requestedNodeId, bool isSearch)
  {
    if (isSearch)
    {
      if (requestedNodeId.equals("6"))
        return "A_AS";
      if (requestedNodeId.equals("4"))
        return "A_S";
      if (requestedNodeId.equals("5"))
        return "A_G";
      if (requestedNodeId.equals("7"))
        return "A_ALB";
      if (requestedNodeId.equals("16"))
        return "I_AI";
      if (requestedNodeId.equals("F"))
        return "A_PL";
    }
    else
    {
      if (requestedNodeId.equals("15"))
      {
        return "V";
      }if (requestedNodeId.equals("16")) {
        return "I";
      }
    }

    return requestedNodeId;
  }

  public ObjectClassType filterContainerClassType(ObjectClassType requestedObjectClass, String objectId)
  {
    if ((requestedObjectClass !is null) && (requestedObjectClass.getClassName().startsWith("object.container")) && (!objectId.startsWith("A"))) {
      return ObjectClassType.STORAGE_FOLDER;
    }
    return requestedObjectClass;
  }

  public void filterClassProperties(String objectId, Map!(ClassProperties, Object) values)
  {
    if ((objectId.startsWith("A_")) || (objectId.equals("I")))
    {
      values.put(ClassProperties.SEARCHABLE, Boolean.TRUE);
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.definition.XBox360ContentDirectoryDefinitionFilter
 * JD-Core Version:    0.6.2
 */