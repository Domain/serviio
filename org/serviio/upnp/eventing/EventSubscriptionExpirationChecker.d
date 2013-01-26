module org.serviio.upnp.eventing.EventSubscriptionExpirationChecker;

import java.lang.Runnable;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Iterator;
import org.serviio.upnp.Device;
import org.serviio.upnp.service.Service;
import org.serviio.util.ThreadUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class EventSubscriptionExpirationChecker : Runnable
{
    private static immutable Logger log;
    private static const int CHECK_FREQUENCY = 2000;
    private bool workerRunning = false;

    static this()
    {
        log = LoggerFactory.getLogger!(EventSubscriptionExpirationChecker)();
    }

    override public void run()
    {
        log.info("Starting EventSubscriptionExpirationChecker");
        Device device = Device.getInstance();
        workerRunning = true;
        Calendar currentDate = new GregorianCalendar();
        while (workerRunning) {
            currentDate.setTime(new Date());

            foreach (Service service ; device.getServices()) {
                Iterator!(Subscription) subscrIt = service.getEventSubscriptions().iterator();
                while (subscrIt.hasNext()) {
                    Subscription subscription = cast(Subscription)subscrIt.next();
                    if (!subscription.getDuration().equals("infinite")) {
                        try {
                            Integer duration = Integer.valueOf(subscription.getDuration());
                            Calendar expirationDate = new GregorianCalendar();
                            expirationDate.setTime(subscription.getCreated());
                            expirationDate.add(13, duration.intValue());
                            if (expirationDate.compareTo(currentDate) < 0)
                            {
                                subscrIt.remove();
                                log.debug_(String.format("Removed expired subscription %s from service %s", cast(Object[])[ subscription.getUuid(), service.getServiceId() ]));
                            }
                        }
                        catch (NumberFormatException e) {
                            log.warn(String.format("Provided subscription duration is not a number (%s), cancelling the subscription", cast(Object[])[ subscription.getDuration() ]));

                            subscrIt.remove();
                        }
                    }
                }

            }

            ThreadUtils.currentThreadSleep(CHECK_FREQUENCY);
        }

        log.info("Leaving EventSubscriptionExpirationChecker, removing all event subscriptions");

        removeAllSubscriptions();
    }

    public void stopWorker()
    {
        workerRunning = false;
    }

    private void removeAllSubscriptions()
    {
        foreach (Service service ; Device.getInstance().getServices()) {
            Iterator!(Subscription) subscrIt = service.getEventSubscriptions().iterator();
            while (subscrIt.hasNext()) {
                Subscription subscription = cast(Subscription)subscrIt.next();
                subscrIt.remove();
                log.debug_(String.format("Removed subscription %s from service %s", cast(Object[])[ subscription.getUuid(), service.getServiceId() ]));
            }
        }
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.eventing.EventSubscriptionExpirationChecker
* JD-Core Version:    0.6.2
*/