module org.serviio.upnp.webserver.UPnPIconRequestHandler;

import java.io.IOException;
import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.Map;
import org.apache.http.HttpException;
import org.apache.http.HttpRequest;
import org.apache.http.HttpResponse;
import org.apache.http.entity.ByteArrayEntity;
import org.apache.http.protocol.HttpContext;
import org.serviio.util.FileUtils;

public class UPnPIconRequestHandler : AbstractDescriptionRequestHandler
{
  public static final String LARGE_PNG = "largePNG";
  public static final String SMALL_PNG = "smallPNG";
  public static final String LARGE_JPG = "largeJPG";
  public static final String SMALL_JPG = "smallJPG";
  private static final Map!(String, IconDescription) icons = new HashMap!(String, IconDescription)();

  protected void handleRequest(HttpRequest request, HttpResponse response, HttpContext context)
  {
    String[] requestFields = getRequestPathFields(getRequestUri(request), "/icon", null);
    if (requestFields.length > 1)
    {
      response.setStatusCode(404);
      return;
    }
    String iconName = requestFields[0];

    if (iconName !is null) {
      log.debug_(String.format("UPnP icon request received for icon %s", cast(Object[])[ iconName ]));
      IconDescription id = cast(IconDescription)icons.get(iconName);
      if (id !is null) {
        byte[] iconBytes = FileUtils.readFileBytes(getClass().getResourceAsStream("/org/serviio/upnp/" + id.getFileName()));
        ByteArrayEntity icon = new ByteArrayEntity(iconBytes);
        icon.setContentType(id.getMimeType());
        response.setEntity(icon);
        return;
      }
    }

    response.setStatusCode(404);
    log.debug_(String.format("Icon with id %s doesn't exist, sending back 404 error", cast(Object[])[ iconName ]));
  }

  static this()
  {
    try
    {
      icons.put("smallJPG", new IconDescription("image/jpeg", "serviio-icon-small.jpg"));
      icons.put("largeJPG", new IconDescription("image/jpeg", "serviio-icon-large.jpg"));
      icons.put("smallPNG", new IconDescription("image/png", "serviio-icon-small.png"));
      icons.put("largePNG", new IconDescription("image/png", "serviio-icon-large.png"));
    } catch (URISyntaxException e) {
      e.printStackTrace();
    }
  }

  private static class IconDescription
  {
    private String mimeType;
    private String fileName;

    public this(String mimeType, String fileName)
    {
      this.mimeType = mimeType;
      this.fileName = fileName;
    }

    public String getMimeType() {
      return mimeType;
    }

    public String getFileName() {
      return fileName;
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.webserver.UPnPIconRequestHandler
 * JD-Core Version:    0.6.2
 */