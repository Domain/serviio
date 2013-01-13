module org.serviio.upnp.service.contentdirectory.definition.ContentDirectoryDefinitionFilter;

import java.util.Map;
import org.serviio.upnp.service.contentdirectory.classes.ClassProperties;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;

public abstract interface ContentDirectoryDefinitionFilter
{
  public abstract String filterObjectId(String paramString, bool paramBoolean);

  public abstract ObjectClassType filterContainerClassType(ObjectClassType paramObjectClassType, String paramString);

  public abstract void filterClassProperties(String paramString, Map!(ClassProperties, Object) paramMap);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.definition.ContentDirectoryDefinitionFilter
 * JD-Core Version:    0.6.2
 */