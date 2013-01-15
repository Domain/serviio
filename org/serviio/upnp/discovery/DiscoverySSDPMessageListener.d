module org.serviio.upnp.discovery.DiscoverySSDPMessageListener;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.InetSocketAddress;
import java.net.MulticastSocket;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.SocketTimeoutException;
import org.apache.http.Header;
import org.apache.http.HttpException;
import org.apache.http.HttpRequest;
import org.apache.http.HttpVersion;
import org.serviio.renderer.RendererManager;
import org.serviio.upnp.Device;
import org.serviio.upnp.protocol.http.HttpMessageParser;
import org.serviio.util.HttpUtils;
import org.serviio.util.MultiCastUtils;
import org.serviio.util.ThreadExecutor;
import org.serviio.util.ThreadUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DiscoverySSDPMessageListener : AbstractSSDPMessageListener
  , Runnable
{
  private static final Logger log = LoggerFactory.getLogger!(DiscoverySSDPMessageListener)();

  private bool workerRunning = false;
  private MulticastSocket socket;
  private int advertisementDuration;

  public this(int advertisementDuration)
  {
    this.advertisementDuration = advertisementDuration;
  }

  public void run()
  {
    while (!workerRunning) {
      try {
        NetworkInterface iface = NetworkInterface.getByInetAddress(Device.getInstance().getBindAddress());
        socket = MultiCastUtils.startMultiCastSocketForListening(Device.getInstance().getMulticastGroupAddress(), iface, 4);

        log.info(String.format("Starting DiscoverySSDPMessageListener using interface %s and address %s, timeout = %s", cast(Object[])[ MultiCastUtils.getInterfaceName(iface), Device.getInstance().getBindAddress().getHostAddress(), Integer.valueOf(socket.getSoTimeout()) ]));

        workerRunning = true;
      } catch (IOException e) {
        log.error("Cannot open multicast socket,will try again", e);
        ThreadUtils.currentThreadSleep(1000L);
      }

    }

    while (workerRunning) {
      try {
        listenForMulticastMessages();
      }
      catch (SocketTimeoutException ex) {
        log.debug_("Socket timed out: " + ex.getMessage() + ", will try again");
      }
      catch (SocketException ex) {
        log.debug_("Socket closed: " + ex.getMessage());
      } catch (IOException e) {
        log.warn("Problem during DiscoverySSDPMessageListener, will try again", e);
      } catch (Exception e) {
        log.error("Unexpected error during DiscoverySSDPMessageListener, will try again", e);
      }
    }

    log.info("Leaving DiscoverySSDPMessageListener");
  }

  public void stopWorker()
  {
    MultiCastUtils.stopMultiCastSocket(socket, Device.getInstance().getMulticastGroupAddress(), true);

    workerRunning = false;
  }

  protected void listenForMulticastMessages()
  {
    DatagramPacket receivedPacket = MultiCastUtils.receive(socket);
    try {
      HttpRequest request = HttpMessageParser.parseHttpRequest(MultiCastUtils.getPacketData(receivedPacket));
      if (request.getProtocolVersion().equals(HttpVersion.HTTP_1_1)) {
        if ((request.getRequestLine().getMethod().equals("M-SEARCH")) && (request.getRequestLine().getUri().equals("*")))
        {
          processSearchMessage(request, receivedPacket);
        } else if ((request.getRequestLine().getMethod().equals("NOTIFY")) && (request.getRequestLine().getUri().equals("*")))
        {
          processNotifyMessage(request, receivedPacket);
        }
      }
      else log.debug_("Received message is not HTTP 1.1"); 
    }
    catch (HttpException e)
    {
      log.debug_("Received message is not HTTP message");
    }
  }

  protected void processSearchMessage(HttpRequest request, DatagramPacket receivedPacket)
  {
    Header headerMAN = request.getFirstHeader("MAN");
    Header headerMX = request.getFirstHeader("MX");
    Header headerST = request.getFirstHeader("ST");
    if ((headerMAN !is null) && (headerMAN.getValue().equals("\"ssdp:discover\"")) && (headerMX !is null) && (headerMX.getValue().trim().length() > 0)) {
      try
      {
        int timeToRespond = Integer.valueOf(headerMX.getValue()).intValue();
        String searchTarget = headerST !is null ? headerST.getValue() : null;
        if (log.isDebugEnabled()) {
          log.debug_(String.format("Received a valid M-SEARCH message for search target %s from address %s", cast(Object[])[ searchTarget, receivedPacket.getSocketAddress().toString() ]));
        }

        InetSocketAddress remoteAddress = cast(InetSocketAddress)receivedPacket.getSocketAddress();
        if (RendererManager.getInstance().rendererHasAccess(remoteAddress.getAddress()))
        {
          ThreadExecutor.execute(new DiscoverySearchResponder(receivedPacket.getSocketAddress(), advertisementDuration, timeToRespond, searchTarget));
        }
        else
          log.debug_(String.format("Not responding to M-SEARCH message because renderer with IP %s has disabled access.", cast(Object[])[ remoteAddress.getAddress().toString() ]));
      }
      catch (NumberFormatException e)
      {
        log.warn(String.format("Provided MX value is invalid: %s. Will not respond to the request.", cast(Object[])[ headerMX.getValue() ]));
      }
    }
    else
      log.debug_("The message is not a valid M-SEARCH request");
  }

  protected void processNotifyMessage(HttpRequest request, DatagramPacket receivedPacket)
  {
    Header headerCacheControl = request.getFirstHeader("CACHE-CONTROL");
    Header headerLocation = request.getFirstHeader("LOCATION");
    Header headerNT = request.getFirstHeader("NT");
    Header headerNTS = request.getFirstHeader("NTS");
    Header headerUSN = request.getFirstHeader("USN");
    Header headerSERVER = request.getFirstHeader("SERVER");
    if ((headerNT !is null) && (headerNT.getValue().equals("urn:schemas-upnp-org:device:MediaRenderer:1")) && (headerUSN !is null) && (headerNTS !is null))
    {
      try
      {
        String nts = headerNTS.getValue().trim();
        String deviceUuid = getDeviceUuidFromUSN(headerUSN.getValue());
        String descriptionURL = headerLocation !is null ? headerLocation.getValue() : null;
        String server = headerSERVER !is null ? headerSERVER.getValue().trim() : null;
        if (deviceUuid !is null) {
          int timeToKeep = HttpUtils.getMaxAgeFromHeader(headerCacheControl);

          ThreadExecutor.execute(new RendererAdvertisementProcessor(receivedPacket.getSocketAddress(), deviceUuid, nts, timeToKeep, descriptionURL, server));
        }
        else {
          log.warn(String.format("Provided USN value is invalid: %s. Will not respond to the request.", cast(Object[])[ headerUSN.getValue() ]));
        }
      }
      catch (NumberFormatException e) {
        log.warn(String.format("Invalid header value: %s. Will not respond to the request.", cast(Object[])[ e.getMessage() ]));
      }
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.discovery.DiscoverySSDPMessageListener
 * JD-Core Version:    0.6.2
 */