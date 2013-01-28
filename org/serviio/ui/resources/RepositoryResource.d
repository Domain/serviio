module org.serviio.ui.resources.RepositoryResource;

import org.restlet.resource.Get;
import org.restlet.resource.Put;
import org.serviio.restlet.ResultRepresentation;
import org.serviio.ui.representation.RepositoryRepresentation;

public abstract interface RepositoryResource
{
    //@Get("xml|json")
    public abstract RepositoryRepresentation load();

    //@Put("xml|json")
    public abstract ResultRepresentation save(RepositoryRepresentation paramRepositoryRepresentation);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.resources.RepositoryResource
 * JD-Core Version:    0.6.2
 */