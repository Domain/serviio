module org.serviio.ui.resources.PingResource;

import org.restlet.resource.Get;
import org.serviio.restlet.ResultRepresentation;

public abstract interface PingResource
{
    //@Get("xml|json")
    public abstract ResultRepresentation ping();
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.resources.PingResource
 * JD-Core Version:    0.6.2
 */