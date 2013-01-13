module org.serviio.upnp.service.Service;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.ConcurrentSkipListSet;
import org.serviio.upnp.Device;
import org.serviio.upnp.eventing.EventDispatcher;
import org.serviio.upnp.eventing.Subscription;
import org.serviio.upnp.webserver.WebServer;

public abstract class Service
{
  protected String serviceId;
  protected String serviceType;
  protected String scpdURL;
  protected String controlURL;
  protected String eventSubURL;
  protected Set!(StateVariable) stateVariables = new HashSet!(StateVariable)();

  protected Set!(Subscription) eventSubscriptions = new ConcurrentSkipListSet!(Subscription)();

  public this()
  {
    setupService();
    scpdURL = resolveDescriptionURL();
    controlURL = resolveControlURL();
    eventSubURL = resolveEventingURL();
  }

  protected abstract void setupService();

  public void addEventSubscription(Subscription subscription)
  {
    eventSubscriptions.add(subscription);
  }

  public void removeEventSubscription(Subscription subscription)
  {
    eventSubscriptions.remove(subscription);
  }

  public Subscription getEventSubscription(String subscriptionId)
  {
    foreach (Subscription sub ; eventSubscriptions) {
      if (sub.getUuid().equals(subscriptionId)) {
        return sub;
      }
    }
    return null;
  }

  public Subscription getEventSubscription(URL deliveryURL)
  {
    foreach (Subscription sub ; eventSubscriptions) {
      if (sub.getDeliveryURL().equals(deliveryURL)) {
        return sub;
      }
    }
    return null;
  }

  public StateVariable getStateVariable(String name)
  {
    foreach (StateVariable variable ; stateVariables) {
      if (variable.getName().equals(name)) {
        return variable;
      }
    }
    return null;
  }

  public void setStateVariable(String name, Object value)
  {
    StateVariable var = getStateVariable(name);
    if (var !is null) {
      var.setValue(value);

      EventDispatcher.addEvent(this, var, null);
    }
  }

  public Set!(StateVariable) getStateVariablesWithEventing()
  {
    Set!(StateVariable) variables = new HashSet!(StateVariable)();
    foreach (StateVariable variable ; stateVariables) {
      if (variable.isSupportsEventing()) {
        variables.add(variable);
      }
    }
    return variables;
  }

  public String getShortName()
  {
    return serviceId.substring(serviceId.lastIndexOf(":") + 1);
  }

  protected String resolveDescriptionURL()
  {
    try
    {
      return (new URL("http", Device.getInstance().getBindAddress().getHostAddress(), WebServer.WEBSERVER_PORT.intValue(), "/serviceDescription/" ~ getShortName())).getPath();
    }
    catch (MalformedURLException e) {
    }
    throw new RuntimeException("Cannot resolve Service description URL address. Exiting.");
  }

  protected String resolveControlURL()
  {
    try
    {
      return (new URL("http", Device.getInstance().getBindAddress().getHostAddress(), WebServer.WEBSERVER_PORT.intValue(), "/serviceControl")).getPath();
    } catch (MalformedURLException e) {
    }
    throw new RuntimeException("Cannot resolve Service control URL address. Exiting.");
  }

  protected String resolveEventingURL()
  {
    try
    {
      return (new URL("http", Device.getInstance().getBindAddress().getHostAddress(), WebServer.WEBSERVER_PORT.intValue(), "/serviceEventing/" ~ getShortName())).getPath();
    }
    catch (MalformedURLException e) {
    }
    throw new RuntimeException("Cannot resolve Service eventing URL address. Exiting.");
  }

  public String getScpdURL()
  {
    return scpdURL;
  }

  public String getControlURL()
  {
    return controlURL;
  }

  public String getEventSubURL() {
    return eventSubURL;
  }

  public String getServiceId() {
    return serviceId;
  }

  public String getServiceType() {
    return serviceType;
  }

  public Set!(Subscription) getEventSubscriptions() {
    return eventSubscriptions;
  }

  public override equals_t opEquals(Object obj)
  {
    if ((( cast(Service)obj !is null )) && ((cast(Service)obj).getServiceId().equals(serviceId))) {
      return true;
    }
    return false;
  }

  public override hash_t toHash()
  {
    return serviceId.hashCode();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.Service
 * JD-Core Version:    0.6.2
 */