module org.serviio.util.CaseInsensitiveMap;

import java.util.LinkedHashMap;

public class CaseInsensitiveMap(V) : LinkedHashMap!(String, V)
{
  private static final long serialVersionUID = 1741026453099609195L;

  public V put(String key, V value)
  {
    return super.put(StringUtils.localeSafeToLowercase(key.toString()), value);
  }

  public V get(Object key)
  {
    return super.get(StringUtils.localeSafeToLowercase(key.toString()));
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.CaseInsensitiveMap
 * JD-Core Version:    0.6.2
 */