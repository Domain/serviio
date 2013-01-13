module org.serviio.upnp.service.contentdirectory.rest.resources.LoginResource;

import org.restlet.resource.Post;
import org.serviio.restlet.ResultRepresentation;

public abstract interface LoginResource
{
  @Post("xml|json")
  public abstract ResultRepresentation login();
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.rest.resources.LoginResource
 * JD-Core Version:    0.6.2
 */