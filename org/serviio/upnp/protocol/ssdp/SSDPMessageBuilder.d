module org.serviio.upnp.protocol.ssdp.SSDPMessageBuilder;

import java.lang.String;
import java.lang.Integer;
import java.util.List;

public abstract interface SSDPMessageBuilder
{
  public abstract List!(String) generateSSDPMessages(Integer paramInteger, String paramString);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.ssdp.SSDPMessageBuilder
 * JD-Core Version:    0.6.2
 */