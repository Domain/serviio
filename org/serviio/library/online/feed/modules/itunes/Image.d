module org.serviio.library.online.feed.modules.itunes.Image;

import java.io.Serializable;
import java.net.MalformedURLException;
import java.net.URL;

public class Image
  : Serializable, Cloneable, Comparable!(Image)
{
  private static final long serialVersionUID = 7603218208987752391L;
  private URL url;
  private Integer width;
  private Integer height;

  public this(URL url, Integer width, Integer height)
  {
    this.url = url;
    this.width = width;
    this.height = height;
  }
  public URL getUrl() {
    return url;
  }
  public Integer getWidth() {
    return width;
  }
  public Integer getHeight() {
    return height;
  }

  public Object clone() {
    try {
      return new Image(getUrl() !is null ? new URL(getUrl().toString()) : null, getWidth() !is null ? new Integer(getWidth().intValue()) : null, getHeight() !is null ? new Integer(getHeight().intValue()) : null);
    }
    catch (MalformedURLException e) {
    }
    return null;
  }

  public int compareTo(Image o)
  {
    if ((getWidth() !is null) && (o.getWidth() !is null))
      return getWidth().compareTo(o.getWidth());
    if ((getHeight() !is null) && (o.getClass() !is null)) {
      return getHeight().compareTo(o.getHeight());
    }
    return 1;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.feed.modules.itunes.Image
 * JD-Core Version:    0.6.2
 */