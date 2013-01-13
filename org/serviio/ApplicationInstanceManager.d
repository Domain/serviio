module org.serviio.ApplicationInstanceManager;

import java.lang.Runnable;
import java.lang.Thread;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.UnknownHostException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ApplicationInstanceManager
{
  private static immutable Logger log = LoggerFactory.getLogger!(ApplicationInstanceManager);
  private static ApplicationInstanceListener subListener;
  public static const int SINGLE_INSTANCE_NETWORK_SOCKET = 44331;
  public static const String SINGLE_INSTANCE_SHARED_KEY = "$$NewInstance$$\n";
  public static const String CLOSE_INSTANCE_SHARED_KEY = "$$CloseInstance$$\n";
  private static ServerSocket socket;

  public static bool registerInstance(bool stopInstance)
  {
    bool returnValueOnError = true;
    try
    {
      socket = new ServerSocket(54331, 10, InetAddress.getLocalHost());
      log.debug_("Listening for application instances on socket 44331");
      Thread instanceListenerThread = new class(new class() Runnable {
        public void run() {
          bool socketClosed = false;
          while (!socketClosed)
            if (ApplicationInstanceManager.socket.isClosed())
              socketClosed = true;
            else
              try {
                Socket client = ApplicationInstanceManager.socket.accept();
                BufferedReader in_ = new BufferedReader(new InputStreamReader(client.getInputStream()));
                String message = in_.readLine();
                if ("$$NewInstance$$\n".trim().equals(message.trim())) {
                  ApplicationInstanceManager.log.debug_("Shared key matched - new application instance found");
                  ApplicationInstanceManager.fireNewInstance(false);
                } else if ("$$CloseInstance$$\n".trim().equals(message.trim())) {
                  ApplicationInstanceManager.log.debug_("Close key matched - close request found");
                  ApplicationInstanceManager.fireNewInstance(true);
                }
                in_.close();
                client.close();
              } catch (IOException e) {
                socketClosed = true;
              }
        }
      }
      , "Instance checker") {};

      instanceListenerThread.setDaemon(true);
      instanceListenerThread.start();
    }
    catch (UnknownHostException e) {
      log.error(e.getMessage(), e);
      return returnValueOnError;
    } catch (IOException e) {
      try {
        Socket clientSocket = new Socket(InetAddress.getLocalHost(), 44331);
        OutputStream out_ = clientSocket.getOutputStream();
        if (stopInstance) {
          log.debug_("Notifying first instance to stop.");
          out_.write("$$CloseInstance$$\n".getBytes());
        } else {
          log.debug_("Port is already taken. Notifying first instance.");
          out_.write("$$NewInstance$$\n".getBytes());
        }
        out_.close();
        clientSocket.close();
        log.debug_("Successfully notified first instance.");
        return false;
      } catch (UnknownHostException e1) {
        log.error(e.getMessage(), e);
        return returnValueOnError;
      } catch (IOException e1) {
        log.error("Error connecting to local port for single instance notification");
        log.error(e1.getMessage(), e1);
        return returnValueOnError;
      }
    }

    return true;
  }

  public static void stopInstance() {
    try {
      if (socket !is null)
        socket.close();
    }
    catch (IOException e) {
    }
  }

  public static void setApplicationInstanceListener(ApplicationInstanceListener listener) {
    subListener = listener;
  }

  private static void fireNewInstance(bool closeRequest) {
    if (subListener !is null)
      subListener.newInstanceCreated(closeRequest);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ApplicationInstanceManager
 * JD-Core Version:    0.6.2
 */