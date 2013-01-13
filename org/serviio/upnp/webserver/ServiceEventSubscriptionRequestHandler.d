module org.serviio.upnp.webserver.ServiceEventSubscriptionRequestHandler;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Date;
import org.apache.http.Header;
import org.apache.http.HttpException;
import org.apache.http.HttpRequest;
import org.apache.http.HttpResponse;
import org.apache.http.MethodNotSupportedException;
import org.apache.http.protocol.HttpContext;
import org.serviio.upnp.Device;
import org.serviio.upnp.eventing.EventDispatcher;
import org.serviio.upnp.eventing.Subscription;
import org.serviio.upnp.service.Service;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;

public class ServiceEventSubscriptionRequestHandler : AbstractRequestHandler
{
  protected void checkMethod(HttpRequest request)
  {
    String method = StringUtils.localeSafeToUppercase(request.getRequestLine().getMethod());
    if ((!method.equals("SUBSCRIBE")) && (!method.equals("UNSUBSCRIBE")))
    {
      throw new MethodNotSupportedException(method + " method not supported");
    }
  }

  protected void handleRequest(HttpRequest request, HttpResponse response, HttpContext context)
  {
    String[] requestFields = getRequestPathFields(getRequestUri(request), "/serviceEventing", null);
    String serviceShortName = requestFields[0];

    if (serviceShortName !is null) {
      Service service = Device.getInstance().getServiceByShortName(serviceShortName);
      if (service !is null) {
        String method = StringUtils.localeSafeToUppercase(request.getRequestLine().getMethod());
        Header subscriptionId = request.getFirstHeader("SID");
        Header notificationType = request.getFirstHeader("NT");
        Header callback = request.getFirstHeader("CALLBACK");
        Header timeout = request.getFirstHeader("TIMEOUT");
        if ((subscriptionId !is null) && ((notificationType !is null) || (callback !is null)))
        {
          response.setStatusCode(400);
        } else {
          String sid = subscriptionId !is null ? subscriptionId.getValue() : null;
          if (method.equals("SUBSCRIBE")) {
            if (notificationType !is null)
            {
              log.debug_(String.format("ServiceEvent subscription request received for service %s", cast(Object[])[ serviceShortName ]));
              subscriptionSetup(response, service, notificationType, callback, timeout is null ? null : resolveTimeout(timeout.getValue()));
            }
            else
            {
              log.debug_(String.format("ServiceEvent renewal request received for service %s and subscription %s", cast(Object[])[ serviceShortName, sid ]));
              subscriptionRenewal(response, service, subscriptionId, timeout is null ? null : resolveTimeout(timeout.getValue()));
            }
          }
          else
          {
            log.debug_(String.format("ServiceEvent unsubscription request received for service %s and subscription %s", cast(Object[])[ serviceShortName, sid ]));
            subscriptionCancellation(response, service, subscriptionId);
          }
        }
      }
      else {
        log.warn(String.format("Requested service %s doesn't exist", cast(Object[])[ serviceShortName ]));
        response.setStatusCode(503);
      }
    } else {
      log.warn("No service specified for subscription");
      response.setStatusCode(503);
    }
  }

  private void subscriptionRenewal(HttpResponse response, Service service, Header subscriptionId, String timeout)
  {
    if ((subscriptionId is null) || (ObjectValidator.isEmpty(subscriptionId.getValue())))
    {
      response.setStatusCode(412);
      return;
    }
    String subscriptionUUID = subscriptionId.getValue().trim().substring(5);
    Subscription subscription = service.getEventSubscription(subscriptionUUID);
    if (subscription is null)
    {
      response.setStatusCode(412);
      return;
    }
    subscription.setCreated(new Date());
    if (timeout !is null) {
      subscription.setDuration(timeout);
    }

    log.debug_(String.format("Event subscription renewed for service %s and subscription %s", cast(Object[])[ service.getServiceId(), subscriptionUUID ]));

    generateSuccessfulSubscriptionResponse(response, subscription);
  }

  private void subscriptionSetup(HttpResponse response, Service service, Header notificationType, Header callback, String timeout)
  {
    if ((notificationType.getValue() is null) || (ObjectValidator.isEmpty(notificationType.getValue())) || (!notificationType.getValue().trim().equals("upnp:event")))
    {
      response.setStatusCode(412);
      return;
    }
    if ((callback is null) || (ObjectValidator.isEmpty(callback.getValue())))
    {
      response.setStatusCode(412);
      return;
    }
    URL deliveryURL = null;
    try {
      deliveryURL = new URL(getDeliveryURL(callback.getValue()));
    }
    catch (MalformedURLException e) {
      response.setStatusCode(412);
      return;
    }

    Subscription subscription = service.getEventSubscription(deliveryURL);
    if (subscription !is null) {
      log.debug_(String.format("Event subscription reused (uuid=%s) for service %s reporting to %s", cast(Object[])[ subscription.getUuid(), service.getServiceId(), deliveryURL.toString() ]));
    }
    else
    {
      subscription = new Subscription();
      subscription.setDeliveryURL(deliveryURL);
      subscription.setCreated(new Date());
      if (timeout is null) {
        timeout = Integer.toString(300);
      }
      subscription.setDuration(timeout);
      service.addEventSubscription(subscription);
      log.debug_(String.format("Event subscription registered (uuid=%s) for service %s reporting to %s", cast(Object[])[ subscription.getUuid(), service.getServiceId(), deliveryURL.toString() ]));
    }

    generateSuccessfulSubscriptionResponse(response, subscription);

    EventDispatcher.addInitialEvents(service, service.getStateVariablesWithEventing(), subscription);
  }

  private void subscriptionCancellation(HttpResponse response, Service service, Header subscriptionId)
  {
    if ((subscriptionId is null) || (ObjectValidator.isEmpty(subscriptionId.getValue())))
    {
      response.setStatusCode(412);
      return;
    }
    String subscriptionUUID = subscriptionId.getValue().trim().substring(5);
    Subscription subscription = service.getEventSubscription(subscriptionUUID);
    if (subscription is null)
    {
      response.setStatusCode(412);
      return;
    }
    service.removeEventSubscription(subscription);
    log.debug_(String.format("Event subscription (uuid=%s) removed for service %s", cast(Object[])[ subscriptionUUID, service.getServiceId() ]));

    response.setStatusCode(200);
  }

  private void generateSuccessfulSubscriptionResponse(HttpResponse response, Subscription subscription)
  {
    response.setStatusCode(200);
    response.setHeader("SID", "uuid:" + subscription.getUuid());
    response.setHeader("TIMEOUT", "Second-" + subscription.getDuration());
  }

  private String resolveTimeout(String timeoutHeader)
  {
    if (timeoutHeader !is null) {
      int offset = StringUtils.localeSafeToUppercase(timeoutHeader).indexOf("SECOND-");
      if (offset > -1) {
        String seconds = timeoutHeader.substring(7, timeoutHeader.length());
        return seconds;
      }
    }
    return null;
  }

  private String getDeliveryURL(String callback)
  {
    String[] urls = callback.split("<|>");
    foreach (String item ; urls) {
      if ((item !is null) && (!item.equals(""))) {
        return item;
      }
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.webserver.ServiceEventSubscriptionRequestHandler
 * JD-Core Version:    0.6.2
 */