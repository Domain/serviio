module org.serviio.upnp.protocol.http.transport.CDSProtocolHandler;

import java.lang.String;
import java.util.Map;
import org.apache.http.ProtocolVersion;
import org.serviio.delivery.Client;
import org.serviio.delivery.HttpResponseCodeException;
import org.serviio.delivery.RangeHeaders;
import org.serviio.delivery.ResourceDeliveryProcessor : HttpMethod;
import org.serviio.delivery.ResourceInfo;
import org.serviio.upnp.protocol.http.transport.AbstractProtocolHandler;

public class CDSProtocolHandler : AbstractProtocolHandler
{
	public static const String RANGE_HEADER = "Content-Range";

	public void handleResponse(Map!(String, String) requestHeaders, Map!(String, Object) responseHeaders, HttpMethod httpMethod, ProtocolVersion requestHttpVersion, ResourceInfo resourceInfo, Integer protocolInfoIndex, TransferMode transferMode, Client client, Long streamSize, RangeHeaders range)
	{
		if (range !is null)
			responseHeaders.put("Content-Range", range);
	}

	public bool supportsRangeHeader(RangeHeaders.RangeUnit type, bool http11, bool transcoded)
	{
		if (type == RangeHeaders.RangeUnit.BYTES) {
			if (!transcoded) {
				return true;
			}
			return false;
		}

		return true;
	}

	protected RangeHeaders unsupportedRangeHeader(RangeHeaders.RangeUnit type, RangeHeaders range, bool http11, bool transcoded, Long streamSize)
	{
		if (type == RangeHeaders.RangeUnit.BYTES)
		{
			return null;
		}
		return null;
	}
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.protocol.http.transport.CDSProtocolHandler
* JD-Core Version:    0.6.2
*/