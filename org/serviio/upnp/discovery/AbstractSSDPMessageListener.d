module org.serviio.upnp.discovery.AbstractSSDPMessageListener;

import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.serviio.util.StringUtils;

public abstract class AbstractSSDPMessageListener
{
  private static final Pattern usnPattern = Pattern.compile("uuid:(.+)::urn:.+", 2);

  protected String getDeviceUuidFromUSN(String usn) {
    if (usn !is null) {
      Matcher m = usnPattern.matcher(usn);
      if (m.find()) {
        return StringUtils.localeSafeToLowercase(m.group(1));
      }
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.discovery.AbstractSSDPMessageListener
 * JD-Core Version:    0.6.2
 */