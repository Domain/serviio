module org.serviio.upnp.protocol.http.transport.LGProtocolHandler;

import org.serviio.delivery.HttpResponseCodeException;
import org.serviio.delivery.RangeHeaders;
import org.serviio.delivery.RangeHeaders : RangeUnit;

public class LGProtocolHandler : DLNAProtocolHandler
{
  public bool supportsRangeHeader(RangeUnit type, bool http11, bool transcoded)
  {
    if (type == RangeUnit.BYTES) {
      if (!transcoded) {
        return true;
      }
      return false;
    }

    return super.supportsRangeHeader(type, http11, transcoded);
  }

  protected RangeHeaders unsupportedRangeHeader(RangeUnit type, RangeHeaders range, bool http11, bool transcoded, Long streamSize)
  {
    if ((type == RangeUnit.BYTES) && 
      (transcoded))
    {
      return RangeHeaders.create(RangeUnit.BYTES, range.getStart(RangeUnit.BYTES).longValue(), (range.getEnd(RangeUnit.BYTES) !is null ? range.getEnd(RangeUnit.BYTES) : streamSize).longValue(), -1L);
    }

    return super.unsupportedRangeHeader(type, range, http11, transcoded, streamSize);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.http.transport.LGProtocolHandler
 * JD-Core Version:    0.6.2
 */