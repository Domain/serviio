module org.serviio.library.online.ThumbnailCacheDecorator;

import org.apache.jcs.access.exception.CacheException;
import org.serviio.cache.AbstractCacheDecorator;
import org.serviio.library.entities.CoverImage;

public class ThumbnailCacheDecorator : AbstractCacheDecorator
  , OnlineCacheDecorator!(CoverImage)
{
  public this(String regionName)
  {
    super(regionName);
  }

  public CoverImage retrieve(String url)
  {
    CoverImage object = cast(CoverImage)cache.get(url);
    return object;
  }

  public void store(String url, CoverImage cachedValue)
  {
    try
    {
      cache.put(url, cachedValue);
      log.debug_(String.format("Stored entry in the cache (%s), returning it", cast(Object[])[ regionName ]));
    } catch (CacheException e) {
      log.warn(String.format("Could not store object to local cache(%s): %s", cast(Object[])[ regionName, e.getMessage() ]));
    }
  }

  public void evict(String url)
  {
    try
    {
      cache.remove(url);
      log.debug_(String.format("Removed thumbnail %s from cache (%s)", cast(Object[])[ url, regionName ]));
    } catch (CacheException e) {
      log.warn(String.format("Could not remove thumbnail %s from cache (%s): %s", cast(Object[])[ url, regionName, e.getMessage() ]));
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.ThumbnailCacheDecorator
 * JD-Core Version:    0.6.2
 */