module org.serviio.upnp.protocol.ssdp.RendererSearchMessageBuilder;

import java.util.ArrayList;
import java.util.List;
import org.apache.http.HttpRequest;
import org.serviio.upnp.protocol.http.HttpMessageBuilder;

public class RendererSearchMessageBuilder : SSDPRequestMessageBuilder
{
  public List!(String) generateSSDPMessages(Integer duration, String searchTarget)
  {
    if ((duration is null) || (duration.intValue() < 0)) {
      throw new InsufficientInformationException(String.format("Message wait time includes invalid value: %s", cast(Object[])[ duration ]));
    }

    List!(String) messages = new ArrayList!(String)();
    messages.add(HttpMessageBuilder.transformToString(generateMessage("M-SEARCH", duration, searchTarget)));

    return messages;
  }

  protected HttpRequest generateMessage(String method, Integer duration, String searchTarget)
  {
    HttpRequest request = super.generateBase(method);
    request.addHeader("MAN", "\"ssdp:discover\"");
    request.addHeader("MX", Integer.toString(duration.intValue()));
    request.addHeader("ST", searchTarget);
    return request;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.ssdp.RendererSearchMessageBuilder
 * JD-Core Version:    0.6.2
 */