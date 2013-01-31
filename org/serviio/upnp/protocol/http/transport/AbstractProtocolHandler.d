module org.serviio.upnp.protocol.http.transport.AbstractProtocolHandler;

import java.io.FileNotFoundException;
import org.apache.http.HttpVersion;
import org.apache.http.ProtocolVersion;
import org.serviio.delivery.HttpResponseCodeException;
import org.serviio.delivery.RangeHeaders;
import org.serviio.delivery.ResourceInfo;
import org.serviio.upnp.protocol.http.transport.ResourceTransportProtocolHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class AbstractProtocolHandler : ResourceTransportProtocolHandler
{
	protected final Logger log = LoggerFactory.getLogger(getClass());

	public RequestedResourceDescriptor getRequestedResourceDescription(String requestUri)
	{
		return new RequestedResourceDescriptor(requestUri);
	}

	public RangeHeaders handleByteRange(RangeHeaders rangeHeaders, ProtocolVersion requestHttpVersion, ResourceInfo resourceInfo, Long streamSize)
	{
		bool http11 = requestHttpVersion == HttpVersion.HTTP_1_1;

		if (supportsRangeHeader(RangeHeaders.RangeUnit.BYTES, http11, resourceInfo.isTranscoded())) {
			long startByte = rangeHeaders.getStart(RangeHeaders.RangeUnit.BYTES).longValue();
			long endByte = rangeHeaders.getEnd(RangeHeaders.RangeUnit.BYTES) !is null ? rangeHeaders.getEnd(RangeHeaders.RangeUnit.BYTES).longValue() : streamSize.longValue() - 1L;
			if ((endByte >= startByte) && (startByte < streamSize.longValue())) {
				return RangeHeaders.create(RangeHeaders.RangeUnit.BYTES, startByte, endByte, streamSize.longValue());
			}

			log.debug_("Unsupported range request, sending back 416");
			throw new HttpResponseCodeException(416);
		}

		return unsupportedRangeHeader(RangeHeaders.RangeUnit.BYTES, rangeHeaders, http11, resourceInfo.isTranscoded(), streamSize);
	}

	public RangeHeaders handleTimeRange(RangeHeaders rangeHeaders, ProtocolVersion requestHttpVersion, ResourceInfo resourceInfo)
	{
		bool http11 = requestHttpVersion == HttpVersion.HTTP_1_1;
		Integer duration = resourceInfo.getDuration();
		if (supportsRangeHeader(RangeHeaders.RangeUnit.SECONDS, http11, resourceInfo.isTranscoded()))
		{
			Double startSecond = new Double(rangeHeaders.getStart(RangeHeaders.RangeUnit.SECONDS).longValue());
			if (startSecond.doubleValue() > duration.intValue()) {
				log.debug_("Unsupported time range request, sending back 416");
				throw new HttpResponseCodeException(416);
			}
			Double endSecond = Double.valueOf(rangeHeaders.getEnd(RangeHeaders.RangeUnit.SECONDS) !is null ? rangeHeaders.getEnd(RangeHeaders.RangeUnit.SECONDS).longValue() : (new Double(duration.intValue())).doubleValue());
			if (endSecond.doubleValue() > duration.intValue()) {
				endSecond = new Double(duration.intValue());
			}
			RangeHeaders range = RangeHeaders.create(RangeHeaders.RangeUnit.SECONDS, startSecond.longValue(), endSecond.longValue(), Long.valueOf(duration.toString()).longValue());
			if (resourceInfo.getFileSize() !is null) {
				Double averageBitrate = Double.valueOf(resourceInfo.getFileSize().longValue() / resourceInfo.getDuration().intValue());
				Long startByte = Long.valueOf((new Double(averageBitrate.doubleValue() * startSecond.doubleValue())).longValue());
				Long endByte = Long.valueOf(endSecond.equals(new Long(duration.intValue())) ? resourceInfo.getFileSize().longValue() : (new Double(averageBitrate.doubleValue() * endSecond.doubleValue())).longValue());
				range.add(RangeHeaders.RangeUnit.BYTES, startByte.longValue(), endByte.longValue(), resourceInfo.getFileSize().longValue());
			}
			return range;
		}
		return unsupportedRangeHeader(RangeHeaders.RangeUnit.SECONDS, rangeHeaders, http11, resourceInfo.isTranscoded(), null);
	}

	protected abstract bool supportsRangeHeader(RangeHeaders.RangeUnit paramRangeUnit, bool paramBoolean1, bool paramBoolean2);

	protected abstract RangeHeaders unsupportedRangeHeader(RangeHeaders.RangeUnit paramRangeUnit, RangeHeaders paramRangeHeaders, bool paramBoolean1, bool paramBoolean2, Long paramLong);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.protocol.http.transport.AbstractProtocolHandler
* JD-Core Version:    0.6.2
*/