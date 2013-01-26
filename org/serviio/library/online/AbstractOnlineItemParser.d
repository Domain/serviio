module org.serviio.library.online.AbstractOnlineItemParser;

import java.lang.String;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Collections;
import java.util.Map : Entry;
import java.util.Set;
import org.serviio.library.entities.OnlineRepository;
import org.serviio.library.local.metadata.ImageDescriptor;
import org.serviio.library.online.feed.PluginCompilerThread;
import org.serviio.library.online.metadata.OnlineContainerItem;
import org.serviio.library.online.metadata.OnlineItem;
import org.serviio.util.HttpUtils;
import org.serviio.util.ThreadUtils;
import org.serviio.library.online.AbstractUrlExtractor;
import org.serviio.library.online.ContentURLContainer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class AbstractOnlineItemParser
{
    protected immutable Logger log;

    protected bool isAlive = true;
    private static PluginCompilerThread pluginCompiler;

    public this()
    {
        log = LoggerFactory.getLogger!(AbstractOnlineItemParser)();
    }

    public static synchronized void startPluginCompilerThread()
    {
        if ((pluginCompiler is null) || ((pluginCompiler !is null) && (!pluginCompiler.isWorkerRunning()))) {
            pluginCompiler = new PluginCompilerThread();
            pluginCompiler.setName("PluginCompilerThread");
            pluginCompiler.setDaemon(true);
            pluginCompiler.setPriority(1);
            pluginCompiler.start();
        }
    }

    public static synchronized void stopPluginCompilerThread()
    {
        stopThread(pluginCompiler);
        pluginCompiler = null;
    }

    public static Set!(AbstractUrlExtractor) getListOfPlugins() {
        if (pluginCompiler !is null) {
            return cast(Set!(AbstractUrlExtractor)) pluginCompiler.getUrlExtractors().keySet();
        }
        return Collections.emptySet();
    }

    public void stopParsing()
    {
        isAlive = false;
    }

    public void startParsing() {
        isAlive = true;
    }

    protected AbstractUrlExtractor findSuitableExtractorPlugin(URL feedUrl, OnlineRepository.OnlineRepositoryType type)
    {
        if ((pluginCompiler !is null) && (pluginCompiler.getUrlExtractors() !is null)) {
            foreach (Entry!(AbstractUrlExtractor, OnlineRepository.OnlineRepositoryType) urlExtractorEntry ; pluginCompiler.getUrlExtractors().entrySet()) {
                AbstractUrlExtractor urlExtractor = cast(AbstractUrlExtractor)urlExtractorEntry.getKey();
                try {
                    if ((urlExtractorEntry.getValue() == type) && (urlExtractor.extractorMatches(feedUrl))) {
                        log.debug_(String.format("Found matching url extractor (%s) for resource %s", cast(Object[])[ urlExtractor.getExtractorName(), feedUrl ]));
                        return urlExtractor;
                    }
                } catch (Exception e) {
                    log.debug_(String.format("Unexpected error during url extractor plugin matching (%s): %s", cast(Object[])[ urlExtractor.getExtractorName(), e.getMessage() ]));
                }
            }
        }
        return null;
    }

    protected void applyContentUrlOnItem(ContentURLContainer extractedUrl, OnlineContainerItem!(Object) resourceItem, AbstractUrlExtractor urlExtractor) {
        if (extractedUrl !is null) {
            resourceItem.setContentUrl(extractedUrl.getContentUrl());
            resourceItem.setExpiresOn(extractedUrl.getExpiresOn());
            resourceItem.setExpiresImmediately(extractedUrl.isExpiresImmediately());
            resourceItem.setCacheKey(extractedUrl.getCacheKey());
            resourceItem.setLive(extractedUrl.isLive());
            resourceItem.setType(extractedUrl.getFileType());
            resourceItem.setUserAgent(extractedUrl.getUserAgent());
            if (extractedUrl.getThumbnailUrl() !is null) {
                resourceItem.setThumbnail(new ImageDescriptor(extractedUrl.getThumbnailUrl()));
            }
            resourceItem.setPlugin(urlExtractor);
        } else {
            log.warn(String.format("Plugin %s returned no value for resource item '%s'", cast(Object[])[ urlExtractor.getExtractorName(), resourceItem.getTitle() ]));
        }
    }

    protected void alterUrlsWithCredentials(String[] credentials, OnlineItem onlineItem) {
        if (credentials !is null) {
            String contentUrl = onlineItem.getContentUrl();
            onlineItem.setContentUrl(getCredentialAlteredUrl(contentUrl, credentials));
            if ((onlineItem.getThumbnail() !is null) && (onlineItem.getThumbnail().getImageUrl() !is null)) {
                URL thumbnailUrl = onlineItem.getThumbnail().getImageUrl();
                onlineItem.getThumbnail().setImageUrl(getCredentialAlteredUrl(thumbnailUrl, credentials));
            }
        }
    }

    private String getCredentialAlteredUrl(String urlString, String[] credentials)
    {
        if (urlString !is null)
            try {
                if (HttpUtils.getCredentialsFormUrl(urlString) is null)
                {
                    URL url = new URL(urlString);
                    try {
                        return (new URL(String.format("%s://%s:%s@%s%s", cast(Object[])[ url.getProtocol(), credentials[0], credentials[1], url.getHost(), url.getPath(), url.getQuery() ]))).toString();
                    }
                    catch (MalformedURLException e) {
                        log.warn("Cannot construct secure content URL: " + e.getMessage());
                    }
                }
            }
        catch (MalformedURLException e)
        {
        }
        return urlString;
    }

    private URL getCredentialAlteredUrl(URL url, String[] credentials) {
        if (url !is null) {
            try {
                return new URL(getCredentialAlteredUrl(url.toString(), credentials));
            } catch (MalformedURLException e) {
                log.warn("Cannot construct secure content URL: " + e.getMessage());
            }
        }
        return url;
    }

    private static void stopThread(PluginCompilerThread thread) {
        if (thread !is null)
        {
            thread.stopWorker();

            while (thread.isAlive())
                ThreadUtils.currentThreadSleep(100L);
        }
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.online.AbstractOnlineItemParser
* JD-Core Version:    0.6.2
*/