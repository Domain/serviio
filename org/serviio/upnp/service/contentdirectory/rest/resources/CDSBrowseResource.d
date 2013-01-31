module org.serviio.upnp.service.contentdirectory.rest.resources.CDSBrowseResource;

import org.restlet.resource.Get;
import org.serviio.upnp.service.contentdirectory.rest.representation.ContentDirectoryRepresentation;

public abstract interface CDSBrowseResource
{
	//@Get("xml|json")
	public abstract ContentDirectoryRepresentation browse();
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.rest.resources.CDSBrowseResource
 * JD-Core Version:    0.6.2
 */