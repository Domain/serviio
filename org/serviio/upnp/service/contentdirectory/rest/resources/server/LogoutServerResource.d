module org.serviio.upnp.service.contentdirectory.rest.resources.server.LogoutServerResource;

import org.serviio.restlet.ResultRepresentation;
import org.serviio.upnp.service.contentdirectory.rest.resources.LogoutResource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LogoutServerResource : AbstractRestrictedCDSServerResource
  , LogoutResource
{
  private static final Logger log = LoggerFactory.getLogger!(LogoutServerResource)();

  public ResultRepresentation logout()
  {
    log.debug_("Logging out using token " + getToken());
    LoginServerResource.removeToken(getToken());
    return responseOk();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.rest.resources.server.LogoutServerResource
 * JD-Core Version:    0.6.2
 */