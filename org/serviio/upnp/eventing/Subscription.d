module org.serviio.upnp.eventing.Subscription;

import java.lang.String;
import java.lang.Comparable;
import java.net.URL;
import java.util.Date;
import java.util.UUID;

public class Subscription
  : Comparable!(Subscription)
{
  private String uuid;
  private URL deliveryURL;
  private long key = 0L;
  private String duration;
  private Date created;

  public this()
  {
    uuid = UUID.randomUUID().toString();
  }

  public void increaseKey()
  {
    if (key == 4294967295L)
      key = 1L;
    else
      key += 1L;
  }

  public URL getDeliveryURL()
  {
    return deliveryURL;
  }

  public void setDeliveryURL(URL deliveryURL) {
    this.deliveryURL = deliveryURL;
  }

  public long getKey() {
    return key;
  }

  public void setKey(int key) {
    this.key = key;
  }

  public String getDuration() {
    return duration;
  }

  public void setDuration(String duration) {
    this.duration = duration;
  }

  public String getUuid() {
    return uuid;
  }

  public Date getCreated() {
    return created;
  }

  public void setCreated(Date created) {
    this.created = created;
  }

  public override equals_t opEquals(Object obj)
  {
    if (this == obj)
      return true;
    if (obj is null)
      return false;
    if (getClass() != obj.getClass())
      return false;
    Subscription other = cast(Subscription)obj;
    if (uuid is null) {
      if (other.uuid !is null)
        return false;
    } else if (!uuid.equals(other.uuid))
      return false;
    return true;
  }

  public override hash_t toHash()
  {
    int prime = 31;
    int result = 1;
    result = prime * result + (uuid is null ? 0 : uuid.hashCode());
    return result;
  }

  public int compareTo(Subscription o)
  {
    return getUuid().compareTo(o.getUuid());
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.eventing.Subscription
 * JD-Core Version:    0.6.2
 */