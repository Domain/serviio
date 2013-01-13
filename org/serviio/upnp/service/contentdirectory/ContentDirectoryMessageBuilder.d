module org.serviio.upnp.service.contentdirectory.ContentDirectoryMessageBuilder;

import java.util.List;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObject;
import org.w3c.dom.Document;

public abstract interface ContentDirectoryMessageBuilder
{
  public abstract Document buildXML(List!(DirectoryObject) paramList);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.ContentDirectoryMessageBuilder
 * JD-Core Version:    0.6.2
 */