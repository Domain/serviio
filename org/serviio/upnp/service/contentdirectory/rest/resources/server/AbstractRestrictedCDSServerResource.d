module org.serviio.upnp.service.contentdirectory.rest.resources.server.AbstractRestrictedCDSServerResource;

import org.restlet.representation.Representation;
import org.restlet.resource.ResourceException;

public abstract class AbstractRestrictedCDSServerResource : AbstractCDSServerResource
{
  private static final String AUTH_TOKEN_PARAMETER = "authToken";
  private String authToken;

  protected void doInit()
  {
    super.doInit();
    authToken = getRequest().getOriginalRef().getQueryAsForm().getFirstValue(AUTH_TOKEN_PARAMETER, true);
  }

  protected Representation doConditionalHandle()
  {
    LoginServerResource.validateToken(authToken);
    return super.doConditionalHandle();
  }

  protected String getToken() {
    return authToken;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.rest.resources.server.AbstractRestrictedCDSServerResource
 * JD-Core Version:    0.6.2
 */