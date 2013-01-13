module org.serviio.upnp.protocol.http.UniversalHttpServerConnection;

import java.io.IOException;
import org.apache.http.HttpEntity;
import org.apache.http.HttpException;
import org.apache.http.HttpRequestFactory;
import org.apache.http.HttpResponse;
import org.apache.http.impl.DefaultHttpServerConnection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class UniversalHttpServerConnection : DefaultHttpServerConnection
{
  private static final Logger log = LoggerFactory.getLogger!(UniversalHttpServerConnection);
  private String connectionId;
  private HttpEntity streamedEntity;

  public this(String connectionId)
  {
    this.connectionId = connectionId;

    log.trace(String.format("Initializing connection %s", cast(Object[])[ connectionId ]));
  }

  protected HttpRequestFactory createHttpRequestFactory()
  {
    return new UniversalHttpRequestFactory();
  }

  public String getSocketAddress() {
    return getSocket().getRemoteSocketAddress().toString();
  }

  public void sendResponseEntity(HttpResponse response)
  {
    if ((response.getEntity() !is null) && (response.getEntity() !is null))
    {
      streamedEntity = response.getEntity();
    }

    super.sendResponseEntity(response);
  }

  public void closeEntityStream()
  {
    try
    {
      if ((streamedEntity !is null) && (streamedEntity.getContent() !is null)) {
        log.trace(String.format("Closing input stream for connection %s", cast(Object[])[ connectionId ]));
        streamedEntity.getContent().close();
        streamedEntity = null;
      }
    }
    catch (IOException e) {
      log.warn(String.format("Cannot close input stream for connection %s: %s", cast(Object[])[ connectionId, e.getMessage() ]));
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.http.UniversalHttpServerConnection
 * JD-Core Version:    0.6.2
 */