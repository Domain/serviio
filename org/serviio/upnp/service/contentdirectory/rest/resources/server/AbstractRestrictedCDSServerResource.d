module org.serviio.upnp.service.contentdirectory.rest.resources.server.AbstractRestrictedCDSServerResource;

import java.lang.String;
import org.restlet.representation.Representation;
import org.restlet.resource.ResourceException;
import org.serviio.upnp.service.contentdirectory.rest.resources.server.AbstractCDSServerResource;

public abstract class AbstractRestrictedCDSServerResource : AbstractCDSServerResource
{
	private static const String AUTH_TOKEN_PARAMETER = "authToken";
	private String authToken;

	override protected void doInit()
	{
		super.doInit();
		authToken = getRequest().getOriginalRef().getQueryAsForm().getFirstValue(AUTH_TOKEN_PARAMETER, true);
	}

	override protected Representation doConditionalHandle()
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