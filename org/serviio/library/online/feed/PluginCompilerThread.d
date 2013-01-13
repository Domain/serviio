module org.serviio.library.online.feed.PluginCompilerThread;

import groovy.lang.GroovyClassLoader;
import groovy.lang.GroovyCodeSource;
import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import org.codehaus.groovy.control.CompilationFailedException;
import org.serviio.ApplicationSettings;
import org.serviio.library.entities.OnlineRepository : OnlineRepositoryType;
import org.serviio.library.online.AbstractUrlExtractor;
import org.serviio.library.online.FeedItemUrlExtractor;
import org.serviio.library.online.OnlineLibraryManager;
import org.serviio.library.online.WebResourceUrlExtractor;
import org.serviio.util.FileUtils;
import org.serviio.util.ObjectValidator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PluginCompilerThread : Thread
{
  private static final Logger log = LoggerFactory.getLogger!(PluginCompilerThread);
  private static final int PLUGIN_COMPILER_CHECK_INTERVAL = 10;
  private File pluginsFolder;
  private Map!(AbstractUrlExtractor, OnlineRepositoryType) urlExtractors = new HashMap!(AbstractUrlExtractor, OnlineRepositoryType)();
  private Map!(File, Date) seenFilesCache = new HashMap!(File, Date)();
  private GroovyClassLoader gcl = new GroovyClassLoader();
  private bool workerRunning;
  private bool isSleeping = false;

  public this()
  {
    pluginsFolder = getPluginsDirectoryPath();
  }

  public void run()
  {
    if ((pluginsFolder !is null) && (pluginsFolder.isDirectory())) {
      log.info("Started looking for plugins");
      workerRunning = true;
      while (workerRunning) {
        searchForPlugins();
        try
        {
          if (workerRunning) {
            isSleeping = true;
            Thread.sleep(PLUGIN_COMPILER_CHECK_INTERVAL*1000L);
            isSleeping = false;
          }
        } catch (InterruptedException e) {
          isSleeping = false;
        }
      }
      log.info("Finished looking for plugins");
    }
    else {
      log.warn(String.format("Plugins folder '%s' does not exist. No plugins will be compiled.", cast(Object[])[ pluginsFolder ]));
    }
  }

  public void stopWorker() {
    workerRunning = false;
    if (isSleeping)
      interrupt();
  }

  public bool isWorkerRunning()
  {
    return workerRunning;
  }

  private File getPluginsDirectoryPath()
  {
    String pluginFolderName = ApplicationSettings.getStringProperty("plugins_directory");
    File pluginFolder = new File(System.getProperty("serviio.home"), pluginFolderName);
    if (!ObjectValidator.isEmpty(System.getProperty("plugins.location"))) {
      pluginFolder = new File(System.getProperty("plugins.location"), pluginFolderName);
    }
    log.info(String.format("Looking for plugins at %s", cast(Object[])[ pluginFolder.getPath() ]));
    return pluginFolder;
  }

  private void searchForPlugins()
  {
    File[] foundPlugins = pluginsFolder.listFiles(new class() FilenameFilter {
      public bool accept(File dir, String name)
      {
        if (name.endsWith(".groovy")) {
          return true;
        }
        return false;
      }
    });
    foreach (File pluginFile ; foundPlugins)
      if ((!seenFilesCache.containsKey(pluginFile)) || (FileUtils.getLastModifiedDate(pluginFile).after(cast(Date)seenFilesCache.get(pluginFile))))
      {
        compilePluginFile(pluginFile);
      }
  }

  private void compilePluginFile(File pluginFile)
  {
    try {
      log.debug_(String.format("Starting plugin %s compilation", cast(Object[])[ pluginFile.getName() ]));
      Class!(Object) pluginClass = gcl.parseClass(new GroovyCodeSource(pluginFile), false);
      if (AbstractUrlExtractor.class_.isAssignableFrom(pluginClass)) {
        bool feedPlugin = true;
        AbstractUrlExtractor pluginInstance = cast(AbstractUrlExtractor)pluginClass.newInstance();
        if (FeedItemUrlExtractor.class_.isAssignableFrom(pluginClass)) {
          urlExtractors.put(pluginInstance, OnlineRepositoryType.FEED);
        } else if (WebResourceUrlExtractor.class_.isAssignableFrom(pluginClass)) {
          urlExtractors.put(pluginInstance, OnlineRepositoryType.WEB_RESOURCE);
          feedPlugin = false;
        } else {
          log.warn("Unsupported plugin class");
          return;
        }
        seenFilesCache.put(pluginFile, FileUtils.getLastModifiedDate(pluginFile));
        OnlineLibraryManager.getInstance().removeFeedFromCache(pluginInstance);
        log.info(String.format("Added %s plugin %s (%s), version: %d", cast(Object[])[ feedPlugin ? "Feed" : "Web Resouce", pluginInstance.getExtractorName(), pluginFile.getName(), Integer.valueOf(pluginInstance.getVersion()) ]));
      } else {
        log.warn(String.format("Groovy class %s (%s) doesn't extend %s, it will not be used", cast(Object[])[ pluginClass.getName(), pluginFile.getName(), FeedItemUrlExtractor.class_.getName() ]));
      }
    }
    catch (CompilationFailedException e) {
      log.warn(String.format("Plugin %s failed to compile: %s", cast(Object[])[ pluginFile.getName(), e.getMessage() ]));
    } catch (IOException e) {
      log.warn(String.format("Plugin %s failed to load: %s", cast(Object[])[ pluginFile.getName(), e.getMessage() ]));
    } catch (Exception e) {
      log.warn(String.format("Unexpected error during adding plugin %s: %s", cast(Object[])[ pluginFile.getName(), e.getMessage() ]), e);
    }
  }

  public Map!(AbstractUrlExtractor, OnlineRepositoryType) getUrlExtractors() {
    return Collections.unmodifiableMap(urlExtractors);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.feed.PluginCompilerThread
 * JD-Core Version:    0.6.2
 */