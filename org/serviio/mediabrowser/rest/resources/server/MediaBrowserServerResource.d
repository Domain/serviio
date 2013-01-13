module org.serviio.mediabrowser.rest.resources.server.MediaBrowserServerResource;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Date;
import org.restlet.Request;
import org.restlet.data.MediaType;
import org.restlet.representation.InputRepresentation;
import org.serviio.mediabrowser.rest.resources.MediaBrowserResource;
import org.serviio.restlet.AbstractServerResource;
import org.serviio.util.FileUtils;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;

public class MediaBrowserServerResource : AbstractServerResource
  , MediaBrowserResource
{
  public static final String RESOURCE_CONTEXT = "/";
  public static final String INDEX_HTML = "/index.html";
  private static final int CACHE_SECONDS = 36000;

  public InputRepresentation deliver()
  {
    Request request = getRequest();
    String requestPath = request.getOriginalRef().getPath();
    String resourcePath = requestPath.substring(requestPath.indexOf("/mediabrowser") + "/mediabrowser".length());
    if (ObjectValidator.isEmpty(resourcePath))
    {
      getResponse().redirectTemporary("/mediabrowser/");
      return null;
    }
    if (isRootPagePequested(resourcePath)) {
      resourcePath = INDEX_HTML;
    }
    InputStream contentFileStream = null;
    try {
      contentFileStream = FileUtils.getStreamFromClasspath("/org/serviio/mediabrowser" + resourcePath, getClass());
      byte[] contentBytes = FileUtils.readFileBytes(contentFileStream);
      InputRepresentation rep = new InputRepresentation(new ByteArrayInputStream(contentBytes), getMediaType(StringUtils.localeSafeToLowercase(resourcePath)), contentBytes.length);
      rep.setExpirationDate(new Date(System.currentTimeMillis() + CACHE_SECONDS * 1000));
      return rep;
    } finally {
      FileUtils.closeQuietly(contentFileStream);
    }
  }

  private bool isRootPagePequested(String path)
  {
    String p = path.trim();
    if ((p.equals("")) || (p.equals(RESOURCE_CONTEXT))) {
      return true;
    }
    return false;
  }

  private MediaType getMediaType(String fileName) {
    if ((fileName.endsWith(".jpg")) || (fileName.endsWith(".jpeg")))
      return MediaType.IMAGE_JPEG;
    if (fileName.endsWith(".png"))
      return MediaType.IMAGE_PNG;
    if (fileName.endsWith(".js"))
      return MediaType.TEXT_JAVASCRIPT;
    if ((fileName.endsWith(".swf")) || (fileName.endsWith(".flv")))
      return MediaType.APPLICATION_OCTET_STREAM;
    if (fileName.endsWith(".css"))
      return MediaType.TEXT_CSS;
    if ((fileName.endsWith(".html")) || (fileName.endsWith(".htm")))
      return MediaType.TEXT_HTML;
    if (fileName.endsWith(".ico")) {
      return MediaType.IMAGE_ICON;
    }
    return MediaType.APPLICATION_OCTET_STREAM;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio-media-browser.jar
 * Qualified Name:     org.serviio.mediabrowser.rest.resources.server.MediaBrowserServerResource
 * JD-Core Version:    0.6.2
 */