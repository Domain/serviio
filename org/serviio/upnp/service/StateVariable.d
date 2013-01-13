module org.serviio.upnp.service.StateVariable;

import java.lang.String;
import java.util.Date;
import org.serviio.util.XmlUtils;

public class StateVariable
{
  private String name;
  private Object value;
  private bool supportsEventing = false;

  private int moderationInterval = 0;
  private Date lastEventSent;

  public this(String name, Object value, bool supportsEventing, int moderationInterval)
  {
    this(name, value);
    this.supportsEventing = supportsEventing;
    this.moderationInterval = moderationInterval;
  }

  public this(String name, Object value)
  {
    this.name = name;
    this.value = value;
  }

  public Object getValue()
  {
    return value;
  }

  public void setValue(Object value) {
    this.value = value;
  }

  public String getName() {
    return name;
  }

  public bool isSupportsEventing() {
    return supportsEventing;
  }

  public String getStringValue() {
    return value is null ? "" : XmlUtils.objectToXMLType(value);
  }

  public int getModerationInterval() {
    return moderationInterval;
  }

  public Date getLastEventSent() {
    return lastEventSent;
  }

  public void setLastEventSent(Date lastEventSent) {
    this.lastEventSent = lastEventSent;
  }

  public override equals_t opEquals(Object obj)
  {
    if ((( cast(StateVariable)obj !is null )) && ((cast(StateVariable)obj).getName().equals(name))) {
      return true;
    }
    return false;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.StateVariable
 * JD-Core Version:    0.6.2
 */