module org.serviio.ui.resources.ReferenceDataResource;

import org.restlet.resource.Get;
import org.serviio.ui.representation.ReferenceDataRepresentation;

public abstract interface ReferenceDataResource
{
    //@Get("xml|json")
    public abstract ReferenceDataRepresentation load();
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.resources.ReferenceDataResource
 * JD-Core Version:    0.6.2
 */