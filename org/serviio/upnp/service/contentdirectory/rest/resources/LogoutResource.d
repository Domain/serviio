module org.serviio.upnp.service.contentdirectory.rest.resources.LogoutResource;

import org.restlet.resource.Post;
import org.serviio.restlet.ResultRepresentation;

public abstract interface LogoutResource
{
  @Post("xml|json")
  public abstract ResultRepresentation logout();
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.rest.resources.LogoutResource
 * JD-Core Version:    0.6.2
 */