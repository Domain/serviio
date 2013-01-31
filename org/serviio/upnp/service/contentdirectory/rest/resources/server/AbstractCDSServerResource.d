module org.serviio.upnp.service.contentdirectory.rest.resources.server.AbstractCDSServerResource;

import java.lang.String;
import java.util.Arrays;
import java.util.Map;
import java.util.Map : Entry;
import org.restlet.Request;
import org.restlet.Response;
import org.restlet.data.CacheDirective;
import org.restlet.data.Form;
import org.restlet.data.Parameter;
import org.restlet.representation.Representation;
import org.restlet.resource.ResourceException;
import org.serviio.MediaServer;
import org.serviio.UPnPServerStatus;
import org.serviio.restlet.AbstractProEditionServerResource;
import org.serviio.restlet.ServerUnavailableException;
import org.serviio.util.CaseInsensitiveMap;
import org.serviio.util.StringUtils;

public abstract class AbstractCDSServerResource : AbstractProEditionServerResource
{
	private static const String ORG_RESTLET_HTTP_HEADERS = "org.restlet.http.headers";

	protected void doInit()
	{
		getResponse().setCacheDirectives(Arrays.asList(cast(CacheDirective[])[ new CacheDirective("no-cache") ]));
	}

	override protected Representation doConditionalHandle()
	{
		if (MediaServer.getStatus() == UPnPServerStatus.STARTED) {
			return super.doConditionalHandle();
		}
		throw new ServerUnavailableException();
	}

	protected Map!(String, String) getRequestHeaders(Request request)
	{
		Form form = cast(Form)request.getAttributes().get(ORG_RESTLET_HTTP_HEADERS);
		Map!(String, String) headers = new CaseInsensitiveMap!(String)();
		foreach (Parameter p ; form) {
			headers.put(p.getName(), p.getValue());
		}
		return headers;
	}

	protected void setCustomHeader(Response response, String name, String value) {
		Form form = cast(Form)response.getAttributes().get(ORG_RESTLET_HTTP_HEADERS);
		if (form is null) {
			form = new Form();
			response.getAttributes().put(ORG_RESTLET_HTTP_HEADERS, form);
		}
		form.add(name, value);
	}

	protected Object getHeaderValue(String headerName, Map!(String, Object) headers) {
		String lowercaseHeaderName = StringUtils.localeSafeToLowercase(headerName);
		foreach (Entry!(String, Object) header ; headers.entrySet()) {
			if (lowercaseHeaderName.equals(StringUtils.localeSafeToLowercase(cast(String)header.getKey()))) {
				return header.getValue();
			}
		}
		return null;
	}

	protected String getHeaderStringValue(String headerName, Map!(String, Object) headers) {
		Object value = getHeaderValue(headerName, headers);
		if (value !is null) {
			return value.toString();
		}
		return null;
	}
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.service.contentdirectory.rest.resources.server.AbstractCDSServerResource
* JD-Core Version:    0.6.2
*/