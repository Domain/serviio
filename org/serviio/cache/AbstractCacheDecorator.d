module org.serviio.cache.AbstractCacheDecorator;

import java.lang.String;
import org.apache.jcs.JCS;
import org.apache.jcs.access.exception.CacheException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.serviio.cache.CacheDecorator;

public abstract class AbstractCacheDecorator
  : CacheDecorator
{
  protected immutable Logger log = LoggerFactory.getLogger(getClass());
  protected JCS cache;
  protected String regionName;

  public this(String regionName)
  {
    try
    {
      cache = JCS.getInstance(regionName);
      this.regionName = regionName;
    } catch (CacheException e) {
      throw new RuntimeException(e);
    }
  }

  public void evictAll()
  {
    try
    {
      cache.clear();
      log.debug_(String.format("Cleared cache (%s)", cast(Object[])[ regionName ]));
    } catch (CacheException e) {
      log.warn(String.format("Could not clean local cache (%s): %s", cast(Object[])[ regionName, e.getMessage() ]));
    }
  }

  public void shutdown()
  {
    cache.dispose();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.cache.AbstractCacheDecorator
 * JD-Core Version:    0.6.2
 */