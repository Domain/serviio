module org.serviio.util.NetworkInterfaceComparator;

import java.lang.String;
import java.net.NetworkInterface;
import java.util.Comparator;

public class NetworkInterfaceComparator
  : Comparator!(NetworkInterface)
{
  public int compare(NetworkInterface o1, NetworkInterface o2)
  {
    String name1 = StringUtils.trim(StringUtils.localeSafeToLowercase(o1.getName()));
    String name2 = StringUtils.trim(StringUtils.localeSafeToLowercase(o2.getName()));
    return compareByName(name1, name2);
  }

  protected int compareByName(String name1, String name2) {
    if (name1 is null) {
      return -1;
    }
    if (name2 is null) {
      return 1;
    }
    if ((name1.startsWith("eth")) && (name2.startsWith("eth")))
      return StringComparators.compareNaturalAscii(name1, name2);
    if (name1.startsWith("eth"))
      return -1;
    if (name2.startsWith("eth")) {
      return 1;
    }
    return StringComparators.compareNaturalAscii(name1, name2);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.NetworkInterfaceComparator
 * JD-Core Version:    0.6.2
 */