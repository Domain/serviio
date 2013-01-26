module org.serviio.ui.resources.PresentationResource;

import org.restlet.resource.Get;
import org.restlet.resource.Put;
import org.serviio.restlet.ResultRepresentation;
import org.serviio.ui.representation.PresentationRepresentation;

public abstract interface PresentationResource
{
    //@Get("xml|json")
    public abstract PresentationRepresentation load();

    //@Put("xml|json")
    public abstract ResultRepresentation save(PresentationRepresentation paramPresentationRepresentation);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.resources.PresentationResource
 * JD-Core Version:    0.6.2
 */