module org.serviio.library.online.OnlineCacheDecorator;

import java.lang.String;
import org.serviio.cache.CacheDecorator;

public abstract interface OnlineCacheDecorator(T) : CacheDecorator
{
    public abstract void store(String paramString, T paramT);

    public abstract T retrieve(String paramString);

    public abstract void evict(String paramString);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.online.OnlineCacheDecorator
* JD-Core Version:    0.6.2
*/