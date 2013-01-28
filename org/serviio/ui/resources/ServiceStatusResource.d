module org.serviio.ui.resources.ServiceStatusResource;

import org.restlet.resource.Get;
import org.serviio.ui.representation.ServiceStatusRepresentation;

public abstract interface ServiceStatusResource
{
    //@Get("xml|json")
    public abstract ServiceStatusRepresentation load();
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.resources.ServiceStatusResource
 * JD-Core Version:    0.6.2
 */