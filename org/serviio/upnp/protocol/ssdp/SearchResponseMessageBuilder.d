module org.serviio.upnp.protocol.ssdp.SearchResponseMessageBuilder;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import org.apache.http.HttpResponse;
import org.serviio.upnp.Device;
import org.serviio.upnp.protocol.http.HttpMessageBuilder;
import org.serviio.upnp.service.Service;
import org.serviio.util.DateUtils;
import org.serviio.util.ObjectValidator;

public class SearchResponseMessageBuilder : SSDPResponseMessageBuilder
{
  public List!(String) generateSSDPMessages(Integer duration, String searchTarget)
  {
    if ((duration is null) || (duration.intValue() < 0)) {
      throw new InsufficientInformationException(String.format("Message duration includes invalid value: %s", cast(Object[])[ duration ]));
    }

    if (ObjectValidator.isEmpty(searchTarget)) {
      throw new InsufficientInformationException(String.format("Message searchTarget includes invalid value: %s", cast(Object[])[ searchTarget ]));
    }

    List!(String) messages = new ArrayList!(String)();
    Device device = Device.getInstance();
    if (searchTarget.equals("ssdp:all"))
      messages.addAll(generateAllMessages(duration, device));
    else if (searchTarget.equals("upnp:rootdevice"))
      messages.add(generateRootDeviceMessage(duration, device));
    else if (searchTarget.equals("uuid:" + device.getUuid()))
      messages.add(generateDeviceByUUIDMessage(duration, device));
    else if (searchTarget.equals(device.getDeviceType()))
      messages.add(generateDeviceByTypeMessage(duration, device));
    else if (isServiceSupported(searchTarget, device)) {
      messages.add(generateServiceMessage(duration, device, searchTarget));
    }
    return messages;
  }

  protected HttpResponse generateBase(Integer duration, Device device)
  {
    HttpResponse response = super.generateBase(device);
    response.addHeader("CACHE-CONTROL", "max-age = " + duration.toString());
    response.addHeader("LOCATION", device.getDescriptionURL().toString());
    response.addHeader("EXT", "");
    response.addHeader("DATE", DateUtils.formatRFC1123(new Date()));
    response.addHeader("SERVER", SSDPConstants.SERVER);
    return response;
  }

  protected List!(String) generateAllServicesMessages(Integer duration, Device device)
  {
    List!(String) result = new ArrayList!(String)(3);
    foreach (Service service ; device.getServices()) {
      result.add(generateServiceMessage(duration, device, service.getServiceType()));
    }
    return result;
  }

  protected List!(String) generateAllMessages(Integer duration, Device device)
  {
    List!(String) messages = new ArrayList!(String)();
    messages.add(generateRootDeviceMessage(duration, device));
    messages.add(generateDeviceByUUIDMessage(duration, device));
    messages.add(generateDeviceByTypeMessage(duration, device));
    messages.addAll(generateAllServicesMessages(duration, device));
    return messages;
  }

  protected String generateRootDeviceMessage(Integer duration, Device device)
  {
    HttpResponse message = generateBase(duration, device);
    message.addHeader("ST", "upnp:rootdevice");
    message.addHeader("USN", "uuid:" + device.getUuid() + "::" + "upnp:rootdevice");
    return HttpMessageBuilder.transformToString(message);
  }

  protected String generateDeviceByUUIDMessage(Integer duration, Device device)
  {
    HttpResponse message = generateBase(duration, device);
    message.addHeader("ST", "uuid:" + device.getUuid());
    message.addHeader("USN", "uuid:" + device.getUuid());
    return HttpMessageBuilder.transformToString(message);
  }

  protected String generateDeviceByTypeMessage(Integer duration, Device device)
  {
    HttpResponse message = generateBase(duration, device);
    message.addHeader("ST", device.getDeviceType());
    message.addHeader("USN", "uuid:" + device.getUuid() + "::" + device.getDeviceType());
    return HttpMessageBuilder.transformToString(message);
  }

  protected String generateServiceMessage(Integer duration, Device device, String serviceType)
  {
    HttpResponse message = generateBase(duration, device);
    message.addHeader("ST", serviceType);
    message.addHeader("USN", "uuid:" + device.getUuid() + "::" + serviceType);
    return HttpMessageBuilder.transformToString(message);
  }

  private bool isServiceSupported(String serviceType, Device device) {
    foreach (Service service ; device.getServices()) {
      if (service.getServiceType().equals(serviceType)) {
        return true;
      }
    }
    return false;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.ssdp.SearchResponseMessageBuilder
 * JD-Core Version:    0.6.2
 */