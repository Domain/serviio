module org.serviio.ui.resources.ApplicationResource;

import org.restlet.resource.Get;
import org.serviio.ui.representation.ApplicationRepresentation;

public abstract interface ApplicationResource
{
    //@Get("xml|json")
    public abstract ApplicationRepresentation load();
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.resources.ApplicationResource
 * JD-Core Version:    0.6.2
 */