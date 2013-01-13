module org.serviio.upnp.Device;

import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.MalformedURLException;
import java.net.URL;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import org.serviio.upnp.addressing.LocalAddressResolverStrategy;
import org.serviio.upnp.service.Service;
import org.serviio.upnp.service.connectionmanager.ConnectionManager;
import org.serviio.upnp.service.contentdirectory.ContentDirectory;
import org.serviio.upnp.service.microsoft.MediaReceiverRegistrar;
import org.serviio.upnp.webserver.WebServer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Device
{
  private static Device instance;
  private static final Logger log = LoggerFactory.getLogger!(Device);
  private String uuid;
  private String deviceType = "urn:schemas-upnp-org:device:MediaServer:1";
  private InetAddress bindAddress;
  private URL descriptionURL;
  private List!(Service) services;
  private InetSocketAddress multicastGroupAddress;

  private this()
  {
    bindAddress = (new LocalAddressResolverStrategy()).getHostIpAddress();
    multicastGroupAddress = new InetSocketAddress("239.255.255.250", 1900);

    uuid = generateDeviceUUID();
    descriptionURL = resolveDescriptionURL();

    log.info(String.format("Created UPnP Device with UUID: %s, bound address: %s", cast(Object[])[ uuid, bindAddress.getHostAddress() ]));
  }

  public static synchronized Device getInstance()
  {
    if (instance is null) {
      instance = new Device();
      instance.setupServices();
    }
    return instance;
  }

  public void refreshBoundIPAddress() {
    bindAddress = (new LocalAddressResolverStrategy()).getHostIpAddress();
    log.info(String.format("Updated bound IP address of Device with UUID: %s, bound address: %s", cast(Object[])[ uuid, bindAddress.getHostAddress() ]));
  }

  public Service getServiceById(String serviceId)
  {
    foreach (Service service ; services) {
      if (service.getServiceId().equals(serviceId)) {
        return service;
      }
    }
    return null;
  }

  public Service getServiceByType(String serviceType)
  {
    foreach (Service service ; services) {
      if (service.getServiceType().equals(serviceType)) {
        return service;
      }
    }
    return null;
  }

  public Service getServiceByShortName(String serviceShortName)
  {
    foreach (Service service ; services) {
      if (service.getServiceId().endsWith(serviceShortName)) {
        return service;
      }
    }
    return null;
  }

  public void setupServices()
  {
    services = new ArrayList!(Service)(2);
    services.add(new ConnectionManager());
    services.add(new ContentDirectory());
    services.add(new MediaReceiverRegistrar());
  }

  protected String generateDeviceUUID()
  {
    try
    {
      MessageDigest md5 = MessageDigest.getInstance("MD5");

      md5.update("Serviio".getBytes());
      md5.update(deviceType.getBytes());
      md5.update(bindAddress.getHostAddress().getBytes());
      byte[] digest = md5.digest();
      return UUID.nameUUIDFromBytes(digest).toString();
    } catch (Exception ex) {
      throw new RuntimeException("Unexpected error during MD5 hash creation", ex);
    }
  }

  protected URL resolveDescriptionURL()
  {
    try
    {
      return new URL("http", bindAddress.getHostAddress(), WebServer.WEBSERVER_PORT.intValue(), "/deviceDescription/" + uuid);
    }
    catch (MalformedURLException e) {
    }
    throw new RuntimeException("Cannot resolve Device description URL address. Exiting.");
  }

  public String getUuid()
  {
    return uuid;
  }

  public URL getDescriptionURL() {
    return descriptionURL;
  }

  public List!(Service) getServices() {
    return services;
  }

  public InetSocketAddress getMulticastGroupAddress() {
    return multicastGroupAddress;
  }

  public InetAddress getBindAddress() {
    return bindAddress;
  }

  public String getDeviceType() {
    return deviceType;
  }

  public void setUuid(String uuid) {
    this.uuid = uuid;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.Device
 * JD-Core Version:    0.6.2
 */