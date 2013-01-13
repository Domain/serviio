module org.serviio.upnp.protocol.http.transport.ResourceTransportProtocolHandler;

import java.io.FileNotFoundException;
import java.util.Map;
import org.apache.http.ProtocolVersion;
import org.serviio.delivery.Client;
import org.serviio.delivery.HttpResponseCodeException;
import org.serviio.delivery.RangeHeaders;
import org.serviio.delivery.ResourceDeliveryProcessor : HttpMethod;
import org.serviio.delivery.ResourceInfo;

public abstract interface ResourceTransportProtocolHandler
{
  public abstract void handleResponse(Map!(String, String) paramMap, Map!(String, Object) paramMap1, HttpMethod paramHttpMethod, ProtocolVersion paramProtocolVersion, ResourceInfo paramResourceInfo, Integer paramInteger, TransferMode paramTransferMode, Client paramClient, Long paramLong, RangeHeaders paramRangeHeaders);

  public abstract RangeHeaders handleByteRange(RangeHeaders paramRangeHeaders, ProtocolVersion paramProtocolVersion, ResourceInfo paramResourceInfo, Long paramLong);

  public abstract RangeHeaders handleTimeRange(RangeHeaders paramRangeHeaders, ProtocolVersion paramProtocolVersion, ResourceInfo paramResourceInfo);

  public abstract RequestedResourceDescriptor getRequestedResourceDescription(String paramString);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.http.transport.ResourceTransportProtocolHandler
 * JD-Core Version:    0.6.2
 */