module org.serviio.upnp.protocol.ssdp.DeviceAliveMessageBuilder;

import java.util.ArrayList;
import java.util.List;
import org.apache.http.HttpRequest;
import org.serviio.upnp.Device;
import org.serviio.upnp.protocol.http.HttpMessageBuilder;
import org.serviio.upnp.service.Service;

public class DeviceAliveMessageBuilder : SSDPRequestMessageBuilder
{
  public List!(String) generateSSDPMessages(Integer duration, String searchTarget)
  {
    if ((duration is null) || (duration.intValue() < 0)) {
      throw new InsufficientInformationException(String.format("Message duration includes invalid value: %s", cast(Object[])[ duration ]));
    }

    List!(String) messages = new ArrayList!(String)();
    messages.addAll(generateRootDeviceMessages(duration));
    messages.addAll(generateServicesMessages(duration));
    return messages;
  }

  protected HttpRequest generateBase(String method, Integer duration)
  {
    HttpRequest request = super.generateBase(method);
    request.addHeader("CACHE-CONTROL", "max-age = " + duration.toString());
    request.addHeader("LOCATION", Device.getInstance().getDescriptionURL().toString());
    request.addHeader("SERVER", SSDPConstants.SERVER);
    request.addHeader("NTS", "ssdp:alive");
    return request;
  }

  protected List!(String) generateRootDeviceMessages(Integer duration)
  {
    List!(String) result = new ArrayList!(String)(3);
    Device device = Device.getInstance();
    HttpRequest message1 = generateBase("NOTIFY", duration);
    message1.addHeader("NT", "upnp:rootdevice");
    message1.addHeader("USN", "uuid:" + device.getUuid() + "::" + "upnp:rootdevice");
    result.add(HttpMessageBuilder.transformToString(message1));

    HttpRequest message2 = generateBase("NOTIFY", duration);
    message2.addHeader("NT", "uuid:" + device.getUuid());
    message2.addHeader("USN", "uuid:" + device.getUuid());
    result.add(HttpMessageBuilder.transformToString(message2));

    HttpRequest message3 = generateBase("NOTIFY", duration);
    message3.addHeader("NT", device.getDeviceType());
    message3.addHeader("USN", "uuid:" + device.getUuid() + "::" + device.getDeviceType());
    result.add(HttpMessageBuilder.transformToString(message3));

    return result;
  }

  protected List!(String) generateServicesMessages(Integer duration)
  {
    List!(String) result = new ArrayList!(String)(3);
    Device device = Device.getInstance();
    foreach (Service service ; device.getServices())
    {
      HttpRequest message = generateBase("NOTIFY", duration);
      message.addHeader("NT", service.getServiceType());
      message.addHeader("USN", "uuid:" + device.getUuid() + "::" + service.getServiceType());
      result.add(HttpMessageBuilder.transformToString(message));
    }

    return result;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.ssdp.DeviceAliveMessageBuilder
 * JD-Core Version:    0.6.2
 */