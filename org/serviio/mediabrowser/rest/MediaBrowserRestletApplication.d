module org.serviio.mediabrowser.rest.MediaBrowserRestletApplication;

import org.restlet.Application;
import org.restlet.Restlet;
import org.restlet.routing.Router;
import org.serviio.mediabrowser.rest.resources.server.MediaBrowserServerResource;

public class MediaBrowserRestletApplication : Application
{
  public static final String APP_CONTEXT = "/mediabrowser";

  public Restlet createInboundRoot()
  {
    Router router = new Router(getContext());
    router.setDefaultMatchingMode(1);

    router.attachDefault(MediaBrowserServerResource.class_);
    return router;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio-media-browser.jar
 * Qualified Name:     org.serviio.mediabrowser.rest.MediaBrowserRestletApplication
 * JD-Core Version:    0.6.2
 */