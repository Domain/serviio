module org.serviio.upnp.discovery.DiscoveryAdvertisementNotifier;

import java.io.IOException;
import java.net.InetAddress;
import java.net.MulticastSocket;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.SocketTimeoutException;
import java.util.List;
import java.util.Set;
import org.serviio.upnp.Device;
import org.serviio.upnp.protocol.ssdp.SSDPMessageBuilderFactory;
import org.serviio.util.DateUtils;
import org.serviio.util.MultiCastUtils;
import org.serviio.util.NumberUtils;
import org.serviio.util.ThreadUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DiscoveryAdvertisementNotifier : Multicaster
  , Runnable
{
  private static final Logger log = LoggerFactory.getLogger!(DiscoveryAdvertisementNotifier)();
  private static final int INITIAL_ADV_DELAY = 10000;
  private int advertisementDuration;
  private int advertisementSendCount;
  private bool workerRunning = false;

  private int aliveSentCounter = 0;

  public this(int advertisementDuration, int advertisementSendCount)
  {
    this.advertisementDuration = advertisementDuration;
    this.advertisementSendCount = advertisementSendCount;
  }

  public void run()
  {
    log.info("Starting DiscoveryAdvertisementNotifier");

    ThreadUtils.currentThreadSleep(NumberUtils.getRandomInInterval(0, 100));

    workerRunning = true;

    while (workerRunning) {
      try {
        long sendStart = System.currentTimeMillis();
        bool sent = sendAlive();

        if (sent) {
          long sendDuration = System.currentTimeMillis() - sendStart;

          long delay = aliveSentCounter < 3 ? INITIAL_ADV_DELAY : NumberUtils.getRandomInInterval(advertisementDuration * 1000 / 10, advertisementDuration * 1000 / 7);
          delay -= sendDuration;
          log.debug_(String.format("Will advertise again in %s (advertisement duration is %s sec.)", cast(Object[])[ DateUtils.timeToHHMMSS(delay), Integer.valueOf(advertisementDuration) ]));

          ThreadUtils.currentThreadSleep(Math.max(0L, delay));
        }
        else {
          log.warn("Could not advertise the device on any available NIC, will try again");
          ThreadUtils.currentThreadSleep(5000L);
        }
      } catch (SocketException e) {
        log.warn("Problem during retrieving list on NetworkInterfaces, will try again", e);
        ThreadUtils.currentThreadSleep(5000L);
      } catch (Exception e) {
        log.error("Fatal error during DiscoveryAdvertisementNotifier, thread will exit", e);
        workerRunning = false;
      }
    }
    log.info("Leaving DiscoveryAdvertisementNotifier");
  }

  public bool sendAlive()
  {
    Set!(NetworkInterface) ifaces = getAvailableNICs();
    bool sent = false;
    log.debug_(String.format("Found %s network interfaces to advertise on", cast(Object[])[ Integer.valueOf(ifaces.size()) ]));
    foreach (NetworkInterface iface ; ifaces) {
      try {
        sendAliveToSingleInterface(iface);
        sent = true;
      } catch (SocketTimeoutException ex) {
        log.debug_("Socket timed out when sending to " + iface.toString() + ": " + ex.getMessage() + ", will try again");
      } catch (IOException e) {
        log.debug_("Problem during DiscoveryAdvertisementNotifier for " + iface.toString() + ", will try again", e);
      }
    }
    if (sent) {
      aliveSentCounter += 1;
    }
    return sent;
  }

  public void sendByeBye()
  {
    foreach (NetworkInterface iface ; getAvailableNICs())
      try {
        sendByeByeToSingleInterface(iface);
      } catch (IOException e) {
        log.warn("Problem sending bye-bye for " + iface.toString(), e);
      }
  }

  public void stopWorker()
  {
    workerRunning = false;
  }

  private void sendAliveToSingleInterface(NetworkInterface multicastInterface) {
    MulticastSocket socket = null;
    Device device = Device.getInstance();
    InetAddress address = MultiCastUtils.findIPAddress(multicastInterface);
    if (address !is null)
      try
      {
        socket = MultiCastUtils.startMultiCastSocketForSending(multicastInterface, address, 32);

        if ((socket !is null) && (socket.isBound())) {
          log.debug_(String.format("Multicasting SSDP alive using interface %s and address %s, timeout = %s", cast(Object[])[ MultiCastUtils.getInterfaceName(multicastInterface), address.getHostAddress(), Integer.valueOf(socket.getSoTimeout()) ]));

          List!(String) messages = SSDPMessageBuilderFactory.getInstance().getBuilder(SSDPMessageBuilderFactory.SSDPMessageType.ALIVE).generateSSDPMessages(Integer.valueOf(advertisementDuration), null);

          log.debug_(String.format("Sending %s 'alive' messages describing device %s", cast(Object[])[ Integer.valueOf(messages.size()), device.getUuid() ]));

          foreach (String message ; messages)
            for (int i = 0; i < advertisementSendCount; i++)
            {
              MultiCastUtils.send(message, socket, device.getMulticastGroupAddress());
              ThreadUtils.currentThreadSleep(100L);
            }
        }
        else {
          log.warn("Cannot multicast SSDP alive message. Not connected to a socket.");
        }
      }
      finally {
        MultiCastUtils.stopMultiCastSocket(socket, device.getMulticastGroupAddress(), false);
      }
  }

  private void sendByeByeToSingleInterface(NetworkInterface multicastInterface)
  {
    MulticastSocket socket = null;
    Device device = Device.getInstance();
    InetAddress address = MultiCastUtils.findIPAddress(multicastInterface);
    if (address !is null)
      try
      {
        socket = MultiCastUtils.startMultiCastSocketForSending(multicastInterface, address, 32);
        if ((socket !is null) && (socket.isBound())) {
          log.debug_(String.format("Multicasting SSDP byebye using interface %s and address %s, timeout = %s", cast(Object[])[ MultiCastUtils.getInterfaceName(multicastInterface), address.getHostName(), Integer.valueOf(socket.getSoTimeout()) ]));

          List!(String) messages = SSDPMessageBuilderFactory.getInstance().getBuilder(SSDPMessageBuilderFactory.SSDPMessageType.BYEBYE).generateSSDPMessages(null, null);

          foreach (String message ; messages)
            for (int i = 0; i < advertisementSendCount; i++)
            {
              MultiCastUtils.send(message, socket, device.getMulticastGroupAddress());
            }
        }
        else {
          log.warn("Cannot multicast SSDP byebye message. Not connected to a socket.");
        }
      }
      finally {
        MultiCastUtils.stopMultiCastSocket(socket, device.getMulticastGroupAddress(), false);
      }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.discovery.DiscoveryAdvertisementNotifier
 * JD-Core Version:    0.6.2
 */