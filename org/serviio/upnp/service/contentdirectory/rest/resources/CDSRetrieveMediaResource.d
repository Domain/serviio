module org.serviio.upnp.service.contentdirectory.rest.resources.CDSRetrieveMediaResource;

import java.io.IOException;
import org.restlet.representation.StreamRepresentation;
import org.restlet.resource.Get;

public abstract interface CDSRetrieveMediaResource
{
  @Get("xml|json")
  public abstract StreamRepresentation deliver();
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.rest.resources.CDSRetrieveMediaResource
 * JD-Core Version:    0.6.2
 */