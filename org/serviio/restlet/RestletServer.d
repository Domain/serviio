module org.serviio.restlet.RestletServer;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map : Entry;
import org.restlet.Application;
import org.restlet.Component;
import org.restlet.Restlet;
import org.restlet.Server;
import org.restlet.data.Protocol;
import org.restlet.engine.Engine;
import org.restlet.engine.converter.ConverterHelper;
import org.restlet.ext.gson.GsonConverter;
import org.serviio.ui.ApiRestletApplication;
import org.serviio.upnp.service.contentdirectory.rest.ContentDirectoryRestletApplication;
import org.serviio.upnp.webserver.WebServer;
import org.serviio.util.ObjectValidator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RestletServer
{
  private static final Logger log = LoggerFactory.getLogger!(RestletServer)();

  private static Component apiComponent = new Component();
  private static Component cdsComponent = new Component();
  private static Component mbComponent = new Component();

  public static void runServer()
  {
    try
    {
      List!(ConverterHelper) registeredConverters = Engine.getInstance().getRegisteredConverters();
      registeredConverters.add(0, new GsonConverter());
      registeredConverters.add(1, new ServiioXstreamConverter());

      Application apiApp = new ApiRestletApplication();
      prepareComponent(apiComponent, Collections.singletonMap("/rest", apiApp), 23423);
      apiComponent.start();

      Application cdsApp = new ContentDirectoryRestletApplication();
      Application mbApp = cast(Application)createInstanceOfApplication("org.serviio.mediabrowser.rest.MediaBrowserRestletApplication");
      Map!(String, Application) cdsApplications = new HashMap!(String, Application)();
      cdsApplications.put("/cds", cdsApp);
      cdsApplications.put("/mediabrowser", mbApp);
      prepareComponent(cdsComponent, cdsApplications, 23424);
      cdsComponent.start();
      mbComponent.start();
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }

  public static void stopServer() {
    try {
      apiComponent.stop();
      cdsComponent.stop();
      mbComponent.stop();
    } catch (Exception e) {
      log.warn("Error during shutting down Restlet server", e);
    }
  }

  private static void prepareComponent(Component component, Map!(String, Application) applications, int port) {
    Server httpServer = null;

    String remoteHost = System.getProperty("serviio.remoteHost");
    if (ObjectValidator.isNotEmpty(remoteHost))
    {
      httpServer = new Server(Protocol.HTTP, remoteHost, port);
    }
    else {
      httpServer = new Server(Protocol.HTTP, port);
    }

    component.getServers().add(httpServer);

    httpServer.getContext().getParameters().add("outboundBufferSize", Integer.toString(WebServer.getSocketBufferSize()));
    httpServer.getContext().getParameters().add("inboundBufferSize", Integer.toString(WebServer.getSocketBufferSize()));
    httpServer.getContext().getParameters().add("persistingConnections", "false");

    foreach (Entry!(String, Application) application ; applications.entrySet()) {
      if (ObjectValidator.isNotEmpty(remoteHost))
        log.info(String.format("Starting Restlet server (%s) exposed on %s:%s", cast(Object[])[ application.getKey(), remoteHost, Integer.valueOf(port) ]));
      else {
        log.info(String.format("Starting Restlet server (%s) exposed on port %s", cast(Object[])[ application.getKey(), Integer.valueOf(port) ]));
      }
      (cast(Application)application.getValue()).setStatusService(new ServiioStatusService());
      (cast(Application)application.getValue()).getRangeService().setEnabled(false);
      component.getDefaultHost().attach(cast(String)application.getKey(), cast(Restlet)application.getValue());
    }
  }

  private static Object createInstanceOfApplication(String className)
  {
    try {
      Class!(Object) clazz = Class.forName(className);
      return clazz.newInstance();
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.restlet.RestletServer
 * JD-Core Version:    0.6.2
 */