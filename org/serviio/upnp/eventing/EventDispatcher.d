module org.serviio.upnp.eventing.EventDispatcher;

import java.lang.Runnable;
import java.io.IOException;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Queue;
import java.util.Set;
import java.util.concurrent.ConcurrentLinkedQueue;
import org.apache.http.HttpException;
import org.apache.http.HttpResponse;
import org.apache.http.HttpVersion;
import org.apache.http.entity.StringEntity;
import org.apache.http.message.BasicHttpEntityEnclosingRequest;
import org.serviio.upnp.Device;
import org.serviio.upnp.protocol.TemplateApplicator;
import org.serviio.upnp.protocol.http.RequestExecutor;
import org.serviio.upnp.service.Service;
import org.serviio.upnp.service.StateVariable;
import org.serviio.util.ThreadUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.serviio.upnp.eventing.Subscription;

public class EventDispatcher
  : Runnable
{
  private static immutable Logger log = LoggerFactory.getLogger!(EventDispatcher)();
  private static const int RESPONSE_TIMEOUT = 500;
  private static Map!(Service, Queue!(EventContainer)) eventQueues = new HashMap!(Service, Queue!(EventContainer))();
  private bool workerRunning;

  public this()
  {
    workerRunning = false;
  }

  public static void addEvent(Service service, StateVariable variable, Subscription subscription)
  {
    EventContainer event = new EventContainer(variable, subscription);
    if (isVariableAvailableForSending(variable)) {
      (cast(Queue!(EventContainer))eventQueues.get(service)).offer(event);
      variable.setLastEventSent(new Date());
    }
  }

  public static void addInitialEvents(Service service, Set!(StateVariable) variables, Subscription subscription)
  {
    Set!(EventContainer) events = new HashSet!(EventContainer)(variables.size());
    foreach (StateVariable variable ; variables) {
      events.add(new EventContainer(variable, subscription));
      variable.setLastEventSent(new Date());
    }

    (cast(Queue!(EventContainer))eventQueues.get(service)).addAll(events);
  }

  public void run()
  {
    log.info("Starting EventDispatcher");
    workerRunning = true;
    while (workerRunning) {
      foreach (Service service ; eventQueues.keySet())
      {
        Queue!(Object) eventsQueue = cast(Queue!(Object))eventQueues.get(service);
        Set!(EventContainer) events = new HashSet!(EventContainer)();
        while (!eventsQueue.isEmpty())
        {
          EventContainer event = cast(EventContainer)eventsQueue.poll();
          events.add(event);
        }
        if (!events.isEmpty())
          foreach (Subscription subscription ; service.getEventSubscriptions())
            try
            {
              sendEvents(subscription, filterEventsForSubscriber(events, subscription));
            } catch (Exception e) {
              log.warn(String.format("Couldn't send event message for subscription %s, will keep trying until subscription expires", cast(Object[])[ subscription.getUuid() ]));
            }
      }
      ThreadUtils.currentThreadSleep(RESPONSE_TIMEOUT);
    }

    log.info("Leaving EventDispatcher");
  }

  public void stopWorker() {
    workerRunning = false;
  }

  protected static void sendEvents(Subscription subscription, Set!(EventContainer) events)
  {
    log.debug_(String.format("Sending event notification #%s for subscription %s to endpoint %s", cast(Object[])[ Long.valueOf(subscription.getKey()), subscription.getUuid(), subscription.getDeliveryURL() ]));

    BasicHttpEntityEnclosingRequest request = new BasicHttpEntityEnclosingRequest("NOTIFY", subscription.getDeliveryURL().getPath(), HttpVersion.HTTP_1_1);

    request.addHeader("NT", "upnp:event");
    request.addHeader("NTS", "upnp:propchange");
    request.addHeader("SID", "uuid:" + subscription.getUuid());
    request.addHeader("SEQ", Long.toString(subscription.getKey()));

    Map!(String, Object) dataModel = new HashMap!(String, Object)();
    dataModel.put("stateVariables", extractVariablesFromEventContainer(events));
    String message = TemplateApplicator.applyTemplate("org/serviio/upnp/protocol/templates/eventNotification.ftl", dataModel);

    StringEntity body_ = new StringEntity(message, "UTF-8");
    body_.setContentType("text/xml");
    body_.setContentEncoding("UTF-8");

    request.setEntity(body_);

    HttpResponse response = RequestExecutor.send(request, subscription.getDeliveryURL());
    if (response.getStatusLine().getStatusCode() == 200)
    {
      log.debug_("Event notification sent and received successfully");
    }
    else log.warn(String.format("Error %s received from event subscriber", cast(Object[])[ Integer.valueOf(response.getStatusLine().getStatusCode()) ]));

    subscription.increaseKey();
  }

  private static Set!(EventContainer) filterEventsForSubscriber(Set!(EventContainer) events, Subscription subscription)
  {
    Set!(EventContainer) filteredEvents = new HashSet!(EventContainer)();
    foreach (EventContainer event ; events) {
      if ((event.getSubscription() is null) || (event.getSubscription().equals(subscription))) {
        filteredEvents.add(event);
      }
    }
    return filteredEvents;
  }

  private static Set!(StateVariable) extractVariablesFromEventContainer(Set!(EventContainer) events)
  {
    Set!(StateVariable) variables = new HashSet!(StateVariable)();
    foreach (EventContainer event ; events) {
      variables.add(event.getVariable());
    }
    return variables;
  }

  private static bool isVariableAvailableForSending(StateVariable variable)
  {
    if ((variable.getModerationInterval() == 0) || (variable.getLastEventSent() is null))
    {
      return true;
    }

    Calendar lastSent = new GregorianCalendar();
    lastSent.setTime(variable.getLastEventSent());
    lastSent.add(14, variable.getModerationInterval());
    Calendar currentDate = new GregorianCalendar();
    currentDate.setTime(new Date());
    if (currentDate.compareTo(lastSent) >= 0)
    {
      return true;
    }
    return false;
  }

  static this()
  {
    foreach (Service service ; Device.getInstance().getServices())
      eventQueues.put(service, new ConcurrentLinkedQueue!(EventContainer)());
  }

  private static class EventContainer
  {
    private StateVariable variable;
    private Subscription subscription;

    public this(StateVariable variable, Subscription subscription)
    {
      this.variable = variable;
      this.subscription = subscription;
    }

    public StateVariable getVariable() {
      return variable;
    }

    public Subscription getSubscription() {
      return subscription;
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.eventing.EventDispatcher
 * JD-Core Version:    0.6.2
 */