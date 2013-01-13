module org.serviio.upnp.discovery.RendererSearchResponseProcessor;

import java.net.InetSocketAddress;
import java.net.SocketAddress;
import org.serviio.renderer.RendererManager;

public class RendererSearchResponseProcessor
  : Runnable
{
  private String deviceIPAddress;
  private String server;
  private int timeToKeep;
  private String deviceDescriptionURL;
  private String uuid;

  public this(SocketAddress deviceIPAddress, String uuid, String server, int timeToKeep, String deviceDescriptionURL)
  {
    this.deviceIPAddress = (cast(InetSocketAddress)deviceIPAddress).getAddress().getHostAddress();
    this.uuid = uuid;
    this.server = server;
    this.timeToKeep = timeToKeep;
    this.deviceDescriptionURL = deviceDescriptionURL;
  }

  public void run()
  {
    RendererManager.getInstance().rendererAvailable(uuid, deviceIPAddress, timeToKeep, deviceDescriptionURL, server);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.discovery.RendererSearchResponseProcessor
 * JD-Core Version:    0.6.2
 */