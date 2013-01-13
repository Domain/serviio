module org.serviio.upnp.protocol.ssdp.SSDPConstants;

import org.serviio.MediaServer;

public class SSDPConstants
{
  public static final String SERVER = System.getProperty("os.name") + ", UPnP/1.0 DLNADOC/1.50, Serviio/" + MediaServer.VERSION;
  public static final String DEFAULT_MULTICAST_HOST = "239.255.255.250";
  public static final int DEFAULT_MULTICAST_PORT = 1900;
  public static final int DEFAULT_TTL = 4;
  public static final int DEFAULT_TIMEOUT = 250;
  public static final int ADVERTISEMENT_DURATION = 1800;
  public static final int ADVERTISEMENT_SEND_COUNT = 3;
  public static final int EVENT_SUBSCRIPTION_DURATION = 300;
  public static final String EVENT_SUBSCRIPTION_DURATION_INFINITE = "infinite";
  public static final String NTS_ALIVE = "ssdp:alive";
  public static final String NTS_BYEBYE = "ssdp:byebye";
  public static final String HTTP_METHOD_NOTIFY = "NOTIFY";
  public static final String HTTP_METHOD_SEARCH = "M-SEARCH";
  public static final String HTTP_METHOD_SUBSCRIBE = "SUBSCRIBE";
  public static final String HTTP_METHOD_UNSUBSCRIBE = "UNSUBSCRIBE";
  public static final String SEARCH_TARGET_ALL = "ssdp:all";
  public static final String SEARCH_TARGET_ROOT_DEVICE = "upnp:rootdevice";
  public static final String NOTIFICATION_TYPE_EVENT = "upnp:event";
  public static final String NOTIFICATION_SUBTYPE_EVENT = "upnp:propchange";
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.ssdp.SSDPConstants
 * JD-Core Version:    0.6.2
 */