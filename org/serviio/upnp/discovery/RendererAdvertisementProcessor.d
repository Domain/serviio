module org.serviio.upnp.discovery.RendererAdvertisementProcessor;

import java.net.InetSocketAddress;
import java.net.SocketAddress;
import org.serviio.renderer.RendererManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RendererAdvertisementProcessor
  : Runnable
{
  private static final Logger log = LoggerFactory.getLogger!(RendererAdvertisementProcessor);
  private String deviceIPAddress;
  private String nts;
  private int timeToKeep;
  private String deviceDescriptionURL;
  private String uuid;
  private String server;

  public this(SocketAddress deviceIPAddress, String uuid, String nts, int timeToKeep, String deviceDescriptionURL, String server)
  {
    this.deviceIPAddress = (cast(InetSocketAddress)deviceIPAddress).getAddress().getHostAddress();
    this.uuid = uuid;
    this.nts = nts;
    this.timeToKeep = timeToKeep;
    this.deviceDescriptionURL = deviceDescriptionURL;
    this.server = server;
  }

  public void run()
  {
    if (nts.equals("ssdp:alive"))
    {
      RendererManager.getInstance().rendererAvailable(uuid, deviceIPAddress, timeToKeep, deviceDescriptionURL, server);
    } else if (nts.equals("ssdp:byebye"))
      RendererManager.getInstance().rendererUnavailable(uuid);
    else
      log.debug_(String.format("Invalid NTS in NOTIFY message: %s", cast(Object[])[ nts ]));
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.discovery.RendererAdvertisementProcessor
 * JD-Core Version:    0.6.2
 */