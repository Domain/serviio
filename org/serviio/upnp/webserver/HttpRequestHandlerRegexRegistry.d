module org.serviio.upnp.webserver.HttpRequestHandlerRegexRegistry;

import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.apache.http.protocol.HttpRequestHandler;
import org.apache.http.protocol.HttpRequestHandlerResolver;

public class HttpRequestHandlerRegexRegistry
  : HttpRequestHandlerResolver
{
  private Map!(String, HttpRequestHandler) handlers = new HashMap!(String, HttpRequestHandler)();

  private Map!(String, Pattern) patterns = new HashMap!(String, Pattern)();

  public HttpRequestHandler lookup(String uri)
  {
    foreach (String pattern ; patterns.keySet()) {
      if ((cast(Pattern)patterns.get(pattern)).matcher(Matcher.quoteReplacement(uri)).matches()) {
        return cast(HttpRequestHandler)handlers.get(pattern);
      }
    }
    return null;
  }

  public void register(String pattern, HttpRequestHandler handler)
  {
    if (pattern is null) {
      throw new IllegalArgumentException("URI request pattern may not be null");
    }
    if (handler is null) {
      throw new IllegalArgumentException("Request handler may not be null");
    }
    handlers.put(pattern, handler);
    patterns.put(pattern, Pattern.compile(pattern));
  }

  public void unregister(String pattern)
  {
    handlers.remove(pattern);
    patterns.remove(pattern);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.webserver.HttpRequestHandlerRegexRegistry
 * JD-Core Version:    0.6.2
 */