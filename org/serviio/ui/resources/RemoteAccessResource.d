module org.serviio.ui.resources.RemoteAccessResource;

import org.restlet.resource.Get;
import org.restlet.resource.Put;
import org.serviio.restlet.ResultRepresentation;
import org.serviio.ui.representation.RemoteAccessRepresentation;

public abstract interface RemoteAccessResource
{
    //@Put("xml|json")
    public abstract ResultRepresentation save(RemoteAccessRepresentation paramRemoteAccessRepresentation);

    //@Get("xml|json")
    public abstract RemoteAccessRepresentation load();
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.resources.RemoteAccessResource
 * JD-Core Version:    0.6.2
 */