module org.serviio.ui.resources.OnlinePluginsResource;

import org.restlet.resource.Get;
import org.serviio.ui.representation.OnlinePluginsRepresentation;

public abstract interface OnlinePluginsResource
{
  @Get("xml|json")
  public abstract OnlinePluginsRepresentation load();
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.resources.OnlinePluginsResource
 * JD-Core Version:    0.6.2
 */