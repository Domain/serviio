module org.serviio.upnp.discovery.Multicaster;

import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Set;
import org.serviio.upnp.Device;
import org.serviio.util.CollectionUtils;
import org.serviio.util.MultiCastUtils;

public abstract class Multicaster
{
  protected Set!(NetworkInterface) getAvailableNICs()
  {
    Set!(NetworkInterface) ifaces = MultiCastUtils.findAllAvailableInterfaces();
    ifaces.add(NetworkInterface.getByInetAddress(Device.getInstance().getBindAddress()));
    CollectionUtils.removeNulls(ifaces);
    return ifaces;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.discovery.Multicaster
 * JD-Core Version:    0.6.2
 */