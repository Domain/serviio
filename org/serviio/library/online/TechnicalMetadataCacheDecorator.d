module org.serviio.library.online.TechnicalMetadataCacheDecorator;

import org.apache.jcs.access.exception.CacheException;
import org.serviio.cache.AbstractCacheDecorator;
import org.serviio.library.online.metadata.TechnicalMetadata;

public class TechnicalMetadataCacheDecorator : AbstractCacheDecorator
  , OnlineCacheDecorator!(TechnicalMetadata)
{
  public this(String regionName)
  {
    super(regionName);
  }

  public TechnicalMetadata retrieve(String url)
  {
    TechnicalMetadata object = cast(TechnicalMetadata)cache.get(url);
    return object;
  }

  public void store(String url, TechnicalMetadata cachedValue)
  {
    try
    {
      cache.put(url, cachedValue);
      log.debug_(String.format("Stored technical metadata for online item '%s' in the cache (%s), returning it", cast(Object[])[ url, regionName ]));
    } catch (CacheException e) {
      log.warn(String.format("Could not store object to local cache (%s): %s", cast(Object[])[ regionName, e.getMessage() ]));
    }
  }

  public void evict(String url)
  {
    try
    {
      cache.remove(url);
      log.debug_(String.format("Removed technical metadata fro online item '%s' from cache (%s)", cast(Object[])[ url, regionName ]));
    } catch (CacheException e) {
      log.warn(String.format("Could not remove feed %s from cache (%s): %s", cast(Object[])[ url, regionName, e.getMessage() ]));
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.TechnicalMetadataCacheDecorator
 * JD-Core Version:    0.6.2
 */