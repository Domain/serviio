module org.serviio.upnp.service.contentdirectory.HostInfo;

import org.serviio.upnp.Device;
import org.serviio.upnp.webserver.WebServer;

public class HostInfo
{
  private String host;
  private Integer port;
  private String context;

  public this(String host, Integer port, String context)
  {
    this.host = host;
    this.port = port;
    this.context = context;
  }

  public static HostInfo defaultHostInfo()
  {
    return new HostInfo(Device.getInstance().getBindAddress().getHostAddress(), WebServer.WEBSERVER_PORT, "/resource");
  }

  public String getHost()
  {
    return host;
  }

  public Integer getPort() {
    return port;
  }

  public String getContext() {
    return context;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.HostInfo
 * JD-Core Version:    0.6.2
 */