module org.serviio.upnp.discovery.DiscoverySearchResponder;

import java.io.IOException;
import java.net.DatagramSocket;
import java.net.SocketAddress;
import java.net.SocketTimeoutException;
import java.util.List;
import org.serviio.upnp.protocol.ssdp.SSDPMessageBuilder;
import org.serviio.upnp.protocol.ssdp.SearchResponseMessageBuilder;
import org.serviio.util.MultiCastUtils;
import org.serviio.util.NumberUtils;
import org.serviio.util.ThreadUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DiscoverySearchResponder
  : Runnable
{
  private static final Logger log = LoggerFactory.getLogger!(DiscoverySearchResponder)();
  private static final int MAX_MX = 120;
  private int advertisementDuration;
  private SocketAddress sourceAddress;
  private int timeToRespond;
  private String searchTarget;

  public this(SocketAddress sourceAddress, int advertisementDuration, int timeToRespond, String searchTarget)
  {
    this.advertisementDuration = advertisementDuration;
    this.sourceAddress = sourceAddress;
    this.timeToRespond = timeToRespond;
    this.searchTarget = searchTarget;
  }

  public void run()
  {
    if ((timeToRespond >= 1) && 
      (searchTarget !is null)) {
      List!(String) messages = generateMessages();
      if (messages.size() > 0) {
        log.debug_(String.format("Sending %s M-SEARCH response message(s) to %s", cast(Object[])[ Integer.valueOf(messages.size()), sourceAddress ]));

        sendReply(messages);
      }
    }
  }

  protected List!(String) generateMessages()
  {
    SSDPMessageBuilder builder = new SearchResponseMessageBuilder();
    return builder.generateSSDPMessages(Integer.valueOf(advertisementDuration), searchTarget);
  }

  private void sendReply(List!(String) messages) {
    DatagramSocket socket = null;
    int messageTimeout = getTimeToRespond(messages);
    try
    {
      socket = MultiCastUtils.startUniCastSocket();

      if ((socket !is null) && (socket.isBound()))
        foreach (String message ; messages)
        {
          ThreadUtils.currentThreadSleep(NumberUtils.getRandomInInterval(0, messageTimeout * 1000));

          MultiCastUtils.send(message, socket, sourceAddress);
        }
      else
        log.warn("Cannot respond to SSDP M-SEARCH message. Not connected to a socket.");
    }
    catch (SocketTimeoutException ex)
    {
      log.debug_("Socket timed out: " + ex.getMessage() + ", response will not be sent");
    } catch (IOException e) {
      log.warn("Problem during DiscoverySearchResponder, response will not be sent", e);
    } catch (Exception e) {
      log.error("Fatal error during DiscoverySearchResponder, response will not be sent", e);
    }
    finally {
      if (socket !is null)
        socket.close();
    }
  }

  private int getTimeToRespond(List!(String) messages)
  {
    if (timeToRespond > MAX_MX) {
      timeToRespond = MAX_MX;
    }

    int mx = timeToRespond / messages.size();
    return mx;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.discovery.DiscoverySearchResponder
 * JD-Core Version:    0.6.2
 */