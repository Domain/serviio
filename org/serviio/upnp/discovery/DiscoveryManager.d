module org.serviio.upnp.discovery.DiscoveryManager;

import java.io.IOException;
import java.net.SocketException;
import org.serviio.MediaServer;
import org.serviio.UPnPServerStatus;
import org.serviio.renderer.RendererManager;
import org.serviio.upnp.Device;
import org.serviio.upnp.eventing.EventDispatcher;
import org.serviio.upnp.eventing.EventSubscriptionExpirationChecker;
import org.serviio.util.ObjectValidator;
import org.serviio.util.ServiioThreadFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DiscoveryManager
{
  private static final Logger log = LoggerFactory.getLogger!(DiscoveryManager);
  private static DiscoveryManager instance;
  private DiscoveryAdvertisementNotifier discoveryNotifier;
  private DiscoverySSDPMessageListener discoverySSDPMessageListener;
  private EventSubscriptionExpirationChecker subscriptionExpiryChecker;
  private EventDispatcher eventDispatcher;
  private Thread discoveryNotifierThread;
  private Thread discoverySearchListenerThread;
  private Thread subscriptionExpiryCheckerThread;
  private Thread eventDispatcherThread;
  private int advertisementSendCount = 3;

  public static DiscoveryManager instance()
  {
    if (instance is null) {
      instance = new DiscoveryManager();
    }
    return instance;
  }

  public void deviceAvailable()
  {
    log.debug_(String.format("UPNP device %s (%s) is available", cast(Object[])[ Device.getInstance().getUuid(), Device.getInstance().getBindAddress().getHostAddress() ]));

    discoverySearchListenerThread = ServiioThreadFactory.getInstance().newThread(discoverySSDPMessageListener, "DiscoverySSDPMessageListener", true);
    discoverySearchListenerThread.setPriority(10);
    discoverySearchListenerThread.start();

    subscriptionExpiryCheckerThread = ServiioThreadFactory.getInstance().newThread(subscriptionExpiryChecker, "SubscriptionExpiryChecker", true);
    subscriptionExpiryCheckerThread.start();

    eventDispatcherThread = ServiioThreadFactory.getInstance().newThread(eventDispatcher, "EventDispatcher", true);
    eventDispatcherThread.start();

    discoveryNotifierThread = ServiioThreadFactory.getInstance().newThread(discoveryNotifier, "DiscoveryNotifier", true);
    discoveryNotifierThread.setPriority(10);
    discoveryNotifierThread.start();

    RendererManager.getInstance().startExpirationChecker();
  }

  public void deviceUnavailable() {
    log.debug_(String.format("UPNP device %s (%s) is unavailable", cast(Object[])[ Device.getInstance().getUuid(), Device.getInstance().getBindAddress().getHostAddress() ]));
    try
    {
      RendererManager.getInstance().stopExpirationChecker();

      discoveryNotifier.stopWorker();
      if (discoveryNotifierThread !is null) {
        discoveryNotifierThread.interrupt();
      }

      discoverySSDPMessageListener.stopWorker();
      if (discoverySearchListenerThread !is null) {
        discoverySearchListenerThread.interrupt();
      }

      subscriptionExpiryChecker.stopWorker();
      if (subscriptionExpiryCheckerThread !is null) {
        subscriptionExpiryCheckerThread.interrupt();
      }

      eventDispatcher.stopWorker();
      if (eventDispatcherThread !is null) {
        eventDispatcherThread.interrupt();
      }

      discoveryNotifier.sendByeBye();
    }
    catch (SocketException ex) {
      log.warn("Problem during sending 'byebye' message. Advertisement will expire automatically.", ex);
    } catch (Exception e) {
      log.warn("Problem during sending 'byebye' message. Advertisement will expire automatically.", e);
    }
  }

  public void sendSSDPAlive()
  {
    if (MediaServer.getStatus() == UPnPServerStatus.STARTED)
      discoveryNotifier.sendAlive();
    else
      log.warn("UPnPserver is not started, cannot send ALIVE message");
  }

  public void initialize()
  {
    discoveryNotifier = new DiscoveryAdvertisementNotifier(getAdvertisementDuration(), advertisementSendCount);
    discoverySSDPMessageListener = new DiscoverySSDPMessageListener(getAdvertisementDuration());
    subscriptionExpiryChecker = new EventSubscriptionExpirationChecker();
    eventDispatcher = new EventDispatcher();
  }

  private int getAdvertisementDuration() {
    if (ObjectValidator.isEmpty(System.getProperty("serviio.advertisementDuration"))) {
      return 1800;
    }
    return Integer.parseInt(System.getProperty("serviio.advertisementDuration"));
  }

  public int getAdvertisementSendCount()
  {
    return advertisementSendCount;
  }

  public void setAdvertisementSendCount(int advertisementSendCount) {
    this.advertisementSendCount = advertisementSendCount;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.discovery.DiscoveryManager
 * JD-Core Version:    0.6.2
 */