module org.serviio.MediaServer;

import java.awt.GraphicsEnvironment;
import java.io.IOException;
import java.nio.charset.Charset;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Handler;
import java.util.logging.LogManager;
import org.serviio.config.Configuration;
import org.serviio.db.DatabaseManager;
import org.serviio.delivery.resource.VideoDeliveryEngine;
import org.serviio.external.DCRawWrapper;
import org.serviio.external.FFMPEGWrapper;
import org.serviio.library.local.LibraryManager;
import org.serviio.library.online.OnlineLibraryManager;
import org.serviio.licensing.LicensingManager;
import org.serviio.licensing.LicensingManager : ServiioEdition;
import org.serviio.licensing.ServiioLicense;
import org.serviio.profile.ProfileManager;
import org.serviio.renderer.RendererManager;
import org.serviio.restlet.RestletServer;
import org.serviio.update.DBSchemaUpdateExecutor;
import org.serviio.update.UpdateChecker;
import org.serviio.upnp.discovery.DiscoveryManager;
import org.serviio.upnp.webserver.WebServer;
import org.serviio.util.StringUtils;
import org.slf4j.LoggerFactory;
import org.slf4j.bridge.SLF4JBridgeHandler;

public class MediaServer
{
  private static immutable org.slf4j.Logger log = LoggerFactory.getLogger!(MediaServer)();
  private static DiscoveryManager discoveryManager;
  private static UPnPServerStatus status = UPnPServerStatus.STOPPED;
  private static Map!(String, Object) arguments = new HashMap!(String, Object)();

  public static String VERSION = ApplicationSettings.getStringProperty("version");
  public static immutable String CHANGESET = ApplicationSettings.getStringProperty("changeset");
  private static const String ARGUMENT_STOP = "stop";
  private static Thread serverThread;
  private static bool serviceInitializationInProcess = true;

  public static void main(String[] args)
  {
    serverThread = Thread.currentThread();
    try
    {
      parseArguments(args);

      checkForRunningInstances();

      redirectLegacyLoggingToSlf4j();

      printInformation();

      RestletServer.runServer();

      DBSchemaUpdateExecutor.updateDBSchema();

      printLicenseInformation();

      ProfileManager.loadProfiles();

      OnlineLibraryManager.getInstance().startPluginCompilerThread();

      UpdateChecker.startCheckerThread();

      addShutdownHooks();

      if (!FFMPEGWrapper.ffmpegPresent()) {
        log.error("FFMPEG not found. Serviio will not work properly.");
      }

      if (!DCRawWrapper.dcrawPresent()) {
        log.warn("DCRAW not found. Support for raw image files will be missing.");
      }

      VideoDeliveryEngine.cleanupTranscodingEngine();

      startServer();

      notifyEndInitialization();
      try
      {
        Thread.sleep(20000L);

        OnlineLibraryManager.getInstance().startFeedUpdaterThread();

        if (Configuration.isAutomaticLibraryRefresh())
        {
          LibraryManager.getInstance().startLibraryAdditionsCheckerThread();
          LibraryManager.getInstance().startLibraryUpdatesCheckerThread();
        }
        LibraryManager.getInstance().startPlaylistMaintainerThread();
      } catch (InterruptedException e) {
      }
    }
    catch (RuntimeException e) {
      log.error(String.format("An unexpected error occured. Ending the application. Message: %s", cast(Object[])[ e.getMessage() ]), e);
      exit();
    }
  }

  public static UPnPServerStatus getStatus()
  {
    return status;
  }

  public static bool isServiceInitializationInProcess() {
    return serviceInitializationInProcess;
  }

  public static void exit() {
    serverThread.interrupt();
    System.exit(0);
  }

  public static void startServer()
  {
    if (status == UPnPServerStatus.STOPPED) {
      status = UPnPServerStatus.INITIALIZING;
      try
      {
        WebServer.start(WebServer.WEBSERVER_PORT.intValue());
      } catch (IOException e) {
        log.error("Cannot start web server, exiting", e);
        exit();
      }

      discoveryManager = DiscoveryManager.instance();
      discoveryManager.initialize();
      discoveryManager.deviceAvailable();

      RendererManager.getInstance().searchForActiveRenderers();

      status = UPnPServerStatus.STARTED;
    }
  }

  public static void stopServer()
  {
    if (status != UPnPServerStatus.STOPPED) {
      try {
        WebServer.stop();
      } catch (IOException e) {
        log.error("cannot stop web server");
        return;
      }

      if (discoveryManager !is null) {
        discoveryManager.deviceUnavailable();
      }
      status = UPnPServerStatus.STOPPED;
    }
  }

  protected static void addShutdownHooks()
  {
    Runtime.getRuntime().addShutdownHook(new ShutdownHook());
  }

  protected static void redirectLegacyLoggingToSlf4j() {
    java.util.logging.Logger rootLogger = LogManager.getLogManager().getLogger("");
    Handler[] handlers = rootLogger.getHandlers();
    for (int i = 0; i < handlers.length; i++) {
      rootLogger.removeHandler(handlers[i]);
    }
    SLF4JBridgeHandler.install();
  }

  private static void printInformation() {
    log.info("------------------------------------------------------------------------");
    log.info("Serviio DLNA media streaming server v " + VERSION + " (rev. " + CHANGESET + ")");
    log.info("Petr Nejedly 2009-2012");
    log.info("http://www.serviio.org");
    log.info("");
    log.info("Java " + System.getProperty("java.version") + "-" + System.getProperty("java.vendor"));
    log.info("OS " + System.getProperty("os.name") + " " + System.getProperty("os.arch") + " " + System.getProperty("os.version"));
    log.info("File encoding: " + Charset.defaultCharset().displayName());
    log.info("Headless mode enabled: " + GraphicsEnvironment.isHeadless());
    log.info("User: " + System.getProperty("user.name"));
    log.info("User home dir: " + System.getProperty("user.home"));
    log.info("Temp dir: " + System.getProperty("java.io.tmpdir"));
    log.info("------------------------------------------------------------------------");
  }

  private static void printLicenseInformation() {
    ServiioLicense lic = LicensingManager.getInstance().getLicense();
    String licenseInfo = lic.getEdition().toString();
    if (lic.getEdition() == ServiioEdition.PRO) {
      licenseInfo = licenseInfo + String.format(" (%s, id: %s)", cast(Object[])[ lic.getType(), lic.getId() ]);
    }

    log.info("------------------------------------------------------------------------");
    log.info("License: " + licenseInfo);
    log.info("------------------------------------------------------------------------");
  }

  private static void checkForRunningInstances()
  {
    bool stopRequested = (arguments.containsKey(ARGUMENT_STOP)) && (arguments.get(ARGUMENT_STOP).equals(Boolean.TRUE));
    if ((!ApplicationInstanceManager.registerInstance(stopRequested)) || (stopRequested))
    {
      exit();
    }

    ApplicationInstanceManager.setApplicationInstanceListener(new class() ApplicationInstanceListener {
      public void newInstanceCreated(bool closeRequest) {
        if (closeRequest)
        {
          MediaServer.exit();
        }
        else
          MediaServer.log.info("Serviio server instance is already running");
      }
    });
  }

  private static void parseArguments(String[] args)
  {
    foreach (String arg ; args)
      if (StringUtils.localeSafeToLowercase(arg).equals("-stop"))
        arguments.put(ARGUMENT_STOP, Boolean.valueOf(true));
  }

  private static void notifyEndInitialization()
  {
    serviceInitializationInProcess = false;
  }

  private static class ShutdownHook : Thread
  {
    public void run()
    {
      LibraryManager.getInstance().stopLibraryAdditionsCheckerThread();
      LibraryManager.getInstance().stopLibraryUpdatesCheckerThread();
      OnlineLibraryManager.getInstance().stopFeedUpdaterThread();
      OnlineLibraryManager.getInstance().stopPluginCompilerThread();
      OnlineLibraryManager.getInstance().shutdownCaches();

      MediaServer.stopServer();

      ApplicationInstanceManager.stopInstance();

      DatabaseManager.stopDatabase();

      VideoDeliveryEngine.cleanupTranscodingEngine();
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.MediaServer
 * JD-Core Version:    0.6.2
 */