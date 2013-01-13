module org.serviio.mediabrowser.rest.resources.MediaBrowserResource;

import java.io.IOException;
import org.restlet.representation.InputRepresentation;
import org.restlet.resource.Get;

public abstract interface MediaBrowserResource
{
  @Get("xml|json")
  public abstract InputRepresentation deliver();
}

/* Location:           D:\Program Files\Serviio\lib\serviio-media-browser.jar
 * Qualified Name:     org.serviio.mediabrowser.rest.resources.MediaBrowserResource
 * JD-Core Version:    0.6.2
 */