module org.serviio.library.online.OnlineLibraryManager;

import java.io.IOException;
import java.net.URL;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import org.serviio.config.Configuration;
import org.serviio.library.AbstractLibraryManager;
import org.serviio.library.entities.CoverImage;
import org.serviio.library.entities.OnlineRepository;
import org.serviio.library.entities.OnlineRepository : OnlineRepositoryType;
import org.serviio.library.local.metadata.ImageDescriptor;
import org.serviio.library.local.service.CoverImageService;
import org.serviio.library.metadata.InvalidMetadataException;
import org.serviio.library.metadata.LibraryIndexingListener;
import org.serviio.library.online.feed.FeedParser;
import org.serviio.library.online.metadata.FeedUpdaterThread;
import org.serviio.library.online.metadata.OnlineCDSLibraryIndexingListener;
import org.serviio.library.online.metadata.OnlineCachable;
import org.serviio.library.online.metadata.OnlineContainerItem;
import org.serviio.library.online.metadata.OnlineResourceContainer;
import org.serviio.library.online.metadata.SingleURLItem;
import org.serviio.library.online.metadata.TechnicalMetadata;
import org.serviio.util.DateUtils;
import org.serviio.util.HttpClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class OnlineLibraryManager : AbstractLibraryManager
{
  private static final Logger log = LoggerFactory.getLogger!(OnlineLibraryManager)();
  private static OnlineLibraryManager instance;
  private OnlineCacheDecorator!(OnlineCachable) onlineCache;
  private OnlineCacheDecorator!(CoverImage) thumbnailCache;
  private OnlineCacheDecorator!(TechnicalMetadata) technicalMetadataCache;
  private FeedParser feedParser;
  private SingleURLParser singleURLParser;
  private WebResourceParser webResourceParser;
  private FeedUpdaterThread feedUpdaterThread;
  private LibraryIndexingListener cdsListener;
  private Map!(String, Date) feedExpiryMonitor = Collections.synchronizedMap(new HashMap!(String, Date)());

  public static OnlineLibraryManager getInstance()
  {
    if (instance is null) {
      instance = new OnlineLibraryManager();
    }
    return instance;
  }

  private this()
  {
    onlineCache = new OnlineContentCacheDecorator("online_feeds");
    thumbnailCache = new ThumbnailCacheDecorator("thumbnails");
    technicalMetadataCache = new TechnicalMetadataCacheDecorator("online_technical_metadata");
    feedParser = new FeedParser();
    webResourceParser = new WebResourceParser();
    singleURLParser = new SingleURLParser();
    cdsListener = new OnlineCDSLibraryIndexingListener();
  }

  public void startFeedUpdaterThread()
  {
    synchronized (cdsListener) {
      feedParser.startParsing();
      webResourceParser.startParsing();
      if ((feedUpdaterThread is null) || ((feedUpdaterThread !is null) && (!feedUpdaterThread.isWorkerRunning()))) {
        feedUpdaterThread = new FeedUpdaterThread();
        feedUpdaterThread.setName("FeedUpdaterThread");
        feedUpdaterThread.setDaemon(true);
        feedUpdaterThread.setPriority(1);
        feedUpdaterThread.addListener(cdsListener);
        feedUpdaterThread.start();
      }
    }
  }

  public void startPluginCompilerThread()
  {
    AbstractOnlineItemParser.startPluginCompilerThread();
  }

  public void stopFeedUpdaterThread()
  {
    synchronized (cdsListener) {
      feedParser.stopParsing();
      webResourceParser.stopParsing();
      stopThread(feedUpdaterThread);
      feedUpdaterThread = null;
    }
  }

  public void stopPluginCompilerThread()
  {
    AbstractOnlineItemParser.stopPluginCompilerThread();

    PluginExecutionProcessor.shutdown();
  }

  public void invokeFeedUpdaterThread()
  {
    if (feedUpdaterThread !is null)
      feedUpdaterThread.invoke();
  }

  public OnlineResourceContainer!(Object, Object) findResource(OnlineRepository onlineRepository, bool onlyCached)
  {
    URL resourceUrl = new URL(onlineRepository.getRepositoryUrl());
    OnlineResourceContainer!(Object, Object) resource = null;
    synchronized (onlineCache) {
      resource = cast(OnlineResourceContainer!(Object, Object))onlineCache.retrieve(resourceUrl.toString());
    }

    if ((!onlyCached) && ((resource is null) || (isResourceExpired(resourceUrl, resource))))
    {
      log.debug_(String.format("Resource %s not in cache yet, loading it", cast(Object[])[ resourceUrl.toString() ]));
      try {
        if (onlineRepository.getRepoType() == OnlineRepositoryType.FEED)
          resource = feedParser.parse(resourceUrl, onlineRepository.getId(), onlineRepository.getFileType());
        else {
          resource = webResourceParser.parse(resourceUrl, onlineRepository.getId(), onlineRepository.getFileType());
        }
        synchronized (onlineCache) {
          onlineCache.store(resourceUrl.toString(), resource);
        }

        storeResourceExpiryDate(resourceUrl, resource);
      } catch (InvalidMetadataException e) {
        throw new IOException(String.format("Cannot parse resource from %s. Message: %s", cast(Object[])[ resourceUrl.toString(), e.getMessage() ]));
      }
    }
    return resource;
  }

  public OnlineResourceContainer!(Object, Object) findResourceInCacheOrParse(OnlineRepository onlineRepository) {
    return findResource(onlineRepository, false);
  }

  public SingleURLItem findSingleURLItemInCacheOrParse(OnlineRepository onlineRepository) {
    SingleURLItem item = null;
    if (onlineRepository !is null) {
      synchronized (onlineCache) {
        item = cast(SingleURLItem)onlineCache.retrieve(onlineRepository.getRepositoryUrl());
      }
      if (item is null) {
        item = singleURLParser.parseItem(onlineRepository);
        synchronized (onlineCache) {
          onlineCache.store(onlineRepository.getRepositoryUrl(), item);
        }
      }
    }
    return item;
  }

  public void removeOnlineContentFromCache(String resourceUrl)
  {
    synchronized (feedExpiryMonitor) {
      onlineCache.evict(resourceUrl);
      feedExpiryMonitor.remove(resourceUrl);
    }
  }

  public void removeFeedFromCache(AbstractUrlExtractor plugin)
  {
    synchronized (feedExpiryMonitor) {
      Set!(String) urls = new HashSet!(String)(feedExpiryMonitor.keySet());
      foreach (String feedUrl ; urls) {
        OnlineResourceContainer!(Object, Object) resource = cast(OnlineResourceContainer!(Object, Object))onlineCache.retrieve(feedUrl);
        if ((resource !is null) && (resource.getUsedExtractor() !is null) && (resource.getUsedExtractor().equals(plugin))) {
          log.debug_(String.format("Removing feed %s generated via %s from cache", cast(Object[])[ feedUrl, plugin.getExtractorName() ]));
          removeOnlineContentFromCache(feedUrl);
        }
      }
    }
  }

  public void storeTechnicalMetadata(String cacheKey, TechnicalMetadata md) {
    synchronized (technicalMetadataCache) {
      technicalMetadataCache.store(cacheKey, md);
    }
  }

  public TechnicalMetadata findTechnicalMetadata(String cacheKey) {
    synchronized (technicalMetadataCache) {
      if (cacheKey !is null) {
        return cast(TechnicalMetadata)technicalMetadataCache.retrieve(cacheKey);
      }
      return null;
    }
  }

  public CoverImage findThumbnail(ImageDescriptor thumbnail) {
    synchronized (thumbnailCache) {
      if ((thumbnail !is null) && (thumbnail.getImageUrl() !is null)) {
        CoverImage coverImage = cast(CoverImage)thumbnailCache.retrieve(thumbnail.getImageUrl().toString());
        if (coverImage is null) {
          try
          {
            log.debug_(String.format("Thumbnail %s not in cache yet, loading it", cast(Object[])[ thumbnail.getImageUrl().toString() ]));
            byte[] imageBytes = HttpClient.retrieveBinaryFileFromURL(thumbnail.getImageUrl().toString());
            ImageDescriptor clonedImage = new ImageDescriptor(imageBytes, null);
            coverImage = CoverImageService.prepareCoverImage(clonedImage, null);
            if (coverImage is null) {
              throw new CannotRetrieveThumbnailException(String.format("An error accured when resizing thumbnail %s", cast(Object[])[ thumbnail.getImageUrl().toString() ]));
            }
            thumbnailCache.store(thumbnail.getImageUrl().toString(), coverImage);
          } catch (IOException e) {
            throw new CannotRetrieveThumbnailException(String.format("Failed to download thumbnail %s.", cast(Object[])[ thumbnail.getImageUrl().toString() ]), e);
          }
        }
        return coverImage;
      }
      return null;
    }
  }

  private bool isResourceExpired(URL resourceUrl, OnlineResourceContainer!(Object, Object) resource)
  {
    synchronized (feedExpiryMonitor) {
      Date expiryDate = cast(Date)feedExpiryMonitor.get(resourceUrl.toString());
      if (expiryDate !is null) {
        Date currentDate = new Date();
        bool resourceExpired = currentDate.after(expiryDate);
        if (!resourceExpired)
        {
          Date itemExpiryDate = getEarliestItemExpiryDate(resource);

          if ((itemExpiryDate !is null) && (currentDate.after(DateUtils.minusMinutes(itemExpiryDate, 5)))) {
            resourceExpired = true;
          }
        }
        if (resourceExpired) {
          log.debug_(String.format("Online resource %s expired, will reload it", cast(Object[])[ resourceUrl.toString() ]));
        }
        return resourceExpired;
      }
      return true;
    }
  }

  private Date getEarliestItemExpiryDate(OnlineResourceContainer!(Object, Object) resource)
  {
    Date earliestDate = null;
    foreach (OnlineContainerItem!(Object) item ; resource.getItems())
    {
      if (item.getExpiresOn() !is null) {
        earliestDate = earliestDate.after(item.getExpiresOn()) ? item.getExpiresOn() : earliestDate is null ? item.getExpiresOn() : earliestDate;
      }
    }
    return earliestDate;
  }

  public void expireAllFeeds()
  {
    synchronized (feedExpiryMonitor) {
      foreach (String url ; feedExpiryMonitor.keySet())
        feedExpiryMonitor.put(url, new Date());
    }
  }

  public void shutdownCaches()
  {
    technicalMetadataCache.shutdown();
    thumbnailCache.shutdown();
  }

  public void removePersistentCaches() {
    technicalMetadataCache.evictAll();
  }

  private Date getUserDefinedExpiryDate() {
    Calendar cal = new GregorianCalendar();
    cal.setTime(new Date());
    cal.add(10, Configuration.getOnlineFeedExpiryInterval().intValue());
    return cal.getTime();
  }

  private void storeResourceExpiryDate(URL feedUrl, OnlineResourceContainer!(Object, Object) resource) {
    synchronized (feedExpiryMonitor) {
      Date newExpiryDate = getUserDefinedExpiryDate();
      feedExpiryMonitor.put(feedUrl.toString(), newExpiryDate);

      Date itemExpiryDate = getEarliestItemExpiryDate(resource);
      log.debug_(String.format("Resource %s will expire in the cache on %s", cast(Object[])[ feedUrl, (itemExpiryDate !is null) && (itemExpiryDate.before(newExpiryDate)) ? itemExpiryDate : newExpiryDate ]));
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.OnlineLibraryManager
 * JD-Core Version:    0.6.2
 */