module org.serviio.cache.CacheDecorator;

public abstract interface CacheDecorator
{
  public abstract void evictAll();

  public abstract void shutdown();
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.cache.CacheDecorator
 * JD-Core Version:    0.6.2
 */