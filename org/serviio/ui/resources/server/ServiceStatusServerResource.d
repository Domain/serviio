module org.serviio.ui.resources.server.ServiceStatusServerResource;

import org.serviio.restlet.AbstractServerResource;
import org.serviio.ui.representation.ServiceStatusRepresentation;
import org.serviio.ui.resources.ServiceStatusResource;

public class ServiceStatusServerResource : AbstractServerResource
  , ServiceStatusResource
{
  public ServiceStatusRepresentation load()
  {
    return new ServiceStatusRepresentation();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.resources.server.ServiceStatusServerResource
 * JD-Core Version:    0.6.2
 */