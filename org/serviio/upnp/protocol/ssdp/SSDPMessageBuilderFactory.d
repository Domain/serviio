module org.serviio.upnp.protocol.ssdp.SSDPMessageBuilderFactory;

import java.util.HashMap;
import java.util.Map;

public class SSDPMessageBuilderFactory
{
  private static SSDPMessageBuilderFactory instance;
  private Map!(SSDPMessageType, SSDPRequestMessageBuilder) builders;

  private this()
  {
    builders = new HashMap!(SSDPMessageType, SSDPRequestMessageBuilder)(3);
    builders.put(SSDPMessageType.ALIVE, new DeviceAliveMessageBuilder());
    builders.put(SSDPMessageType.BYEBYE, new DeviceUnavailableMessageBuilder());
    builders.put(SSDPMessageType.SEARCH, new RendererSearchMessageBuilder());
  }

  public static SSDPMessageBuilderFactory getInstance()
  {
    if (instance is null) {
      instance = new SSDPMessageBuilderFactory();
    }
    return instance;
  }

  public SSDPRequestMessageBuilder getBuilder(SSDPMessageType type) {
    return cast(SSDPRequestMessageBuilder)builders.get(type);
  }

  public static enum SSDPMessageType
  {
    ALIVE, BYEBYE, SEARCH
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.ssdp.SSDPMessageBuilderFactory
 * JD-Core Version:    0.6.2
 */