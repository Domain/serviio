module org.serviio.library.online.AbstractUrlExtractor;

import java.io.IOException;
import java.net.URL;
import java.util.Map;
import java.util.Map : Entry;
import org.restlet.Client;
import org.restlet.Request;
import org.restlet.Response;
import org.restlet.data.ClientInfo;
import org.restlet.data.Cookie;
import org.restlet.data.Encoding;
import org.restlet.data.Method;
import org.restlet.data.Protocol;
import org.restlet.data.Status;
import org.serviio.external.FFMPEGWrapper;
import org.serviio.library.online.metadata.FeedItem;
import org.serviio.library.online.metadata.OnlineItem;
import org.serviio.library.online.metadata.WebResourceItem;
import org.serviio.util.ObjectValidator;
import org.serviio.util.SecurityUtils;
import org.serviio.util.StringUtils;
import org.serviio.util.ZipUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class AbstractUrlExtractor
{
  protected static final int ITEM_LIST_TIMEOUT_MS = 30000;
  protected static final int URL_EXTRACTION_TIMEOUT_MS = 30000;
  protected static final Logger log = LoggerFactory.getLogger!(FeedItemUrlExtractor)();

  private Client restletClient = new Client(Protocol.HTTP);

  public static ContentURLContainer extractItemUrl(AbstractUrlExtractor plugin, OnlineItem item)
  {
    if (plugin !is null) {
      if (( cast(FeedItemUrlExtractor)plugin !is null ))
        return (cast(FeedItemUrlExtractor)plugin).extractUrl(cast(FeedItem)item);
      if (( cast(WebResourceUrlExtractor)plugin !is null )) {
        return (cast(WebResourceUrlExtractor)plugin).extractItemUrl((cast(WebResourceItem)item).toContainerItem());
      }
    }
    return null;
  }

  public int getVersion()
  {
    return 1;
  }

  public abstract bool extractorMatches(URL paramURL);

  public abstract String getExtractorName();

  protected final bool validate(ContentURLContainer container)
  {
    if ((container !is null) && 
      ((container.isExpiresImmediately()) || (container.getExpiresOn() !is null)) && (ObjectValidator.isEmpty(container.getCacheKey())))
    {
      log.warn("Online item expires but no cache key has been set");
      return false;
    }

    return true;
  }

  protected final void log(String message) {
    log.debug_(String.format("%s: %s", cast(Object[])[ getExtractorName(), message ]));
  }

  protected final String generateMAC(String text, String salt, String algorithm) {
    try {
      return SecurityUtils.generateMacAsHex(salt, text, algorithm);
    } catch (Exception e) {
      throw new RuntimeException(String.format("Error generating MAC: %s", cast(Object[])[ e.getMessage() ]), e);
    }
  }

  protected final String decryptAES(String hexText, String key, String iv) {
    return SecurityUtils.decryptAES(key, iv, hexText);
  }

  protected final byte[] decrypt(String text, String key, String algorithm) {
    try {
      return SecurityUtils.decrypt(key, text, algorithm);
    } catch (Exception e) {
      throw new RuntimeException(String.format("Error decrypting: %s", cast(Object[])[ e.getMessage() ]), e);
    }
  }

  protected final String decryptAsHex(String text, String key, String algorithm) {
    try {
      return SecurityUtils.decryptAsHex(key, text, algorithm);
    } catch (Exception e) {
      throw new RuntimeException(String.format("Error decrypting: %s", cast(Object[])[ e.getMessage() ]), e);
    }
  }

  protected final String openURL(URL url, String userAgent) {
    return openURL(url, userAgent, null);
  }

  protected final String openURL(URL url, String userAgent, Map!(String, String) cookies) {
    Request request = new Request(Method.GET, url.toString());

    if (cookies !is null) {
      foreach (Entry!(String, String) cookie ; cookies.entrySet()) {
        request.getCookies().add(new Cookie(cast(String)cookie.getKey(), cast(String)cookie.getValue()));
      }
    }
    if (userAgent !is null) {
      ClientInfo info = new ClientInfo();
      info.setAgent(userAgent);
      request.setClientInfo(info);
    }
    Response response = restletClient.handle(request);
    if (Status.SUCCESS_OK.equals(response.getStatus()))
      return readResponse(response);
    if (response.getStatus().isRedirection()) {
      return openURL(response.getLocationRef().toUrl(), userAgent);
    }
    return null;
  }

  protected String readResponse(Response response)
  {
    Encoding responseEncoding = response.getEntity().getEncodings().size() > 0 ? cast(Encoding)response.getEntity().getEncodings().get(0) : null;
    if (responseEncoding == Encoding.GZIP)
      return StringUtils.readStreamAsString(ZipUtils.unGzipSingleFile(response.getEntity().getStream()), "UTF-8");
    if (responseEncoding == Encoding.ZIP) {
      return StringUtils.readStreamAsString(ZipUtils.unZipSingleFile(response.getEntity().getStream()), "UTF-8");
    }
    return StringUtils.readStreamAsString(response.getEntity().getStream(), "UTF-8");
  }

  protected final String getFFmpegUserAgent() {
    return FFMPEGWrapper.getFFmpegUserAgent();
  }

  public override hash_t toHash()
  {
    int prime = 31;
    int result = 1;
    result = prime * result + (getExtractorName() is null ? 0 : getExtractorName().hashCode());
    return result;
  }

  public override equals_t opEquals(Object obj)
  {
    if (this == obj)
      return true;
    if (obj is null)
      return false;
    if (getClass() != obj.getClass())
      return false;
    AbstractUrlExtractor other = cast(AbstractUrlExtractor)obj;
    if (getExtractorName() is null) {
      if (other.getExtractorName() !is null)
        return false;
    } else if (!getExtractorName().equals(other.getExtractorName()))
      return false;
    return true;
  }

  protected void finalize()
  {
    super.finalize();
    restletClient.stop();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.AbstractUrlExtractor
 * JD-Core Version:    0.6.2
 */