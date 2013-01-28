module org.serviio.ui.resources.TranscodingResource;

import org.restlet.resource.Get;
import org.restlet.resource.Put;
import org.serviio.restlet.ResultRepresentation;
import org.serviio.ui.representation.TranscodingRepresentation;

public abstract interface TranscodingResource
{
    //@Put("xml|json")
    public abstract ResultRepresentation save(TranscodingRepresentation paramTranscodingRepresentation);

    //@Get("xml|json")
    public abstract TranscodingRepresentation load();
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.resources.TranscodingResource
 * JD-Core Version:    0.6.2
 */