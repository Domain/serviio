module org.serviio.delivery.OnlineInputStream;

import java.lang.Long;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.Collections;
import java.util.List;
import org.restlet.Client;
import org.restlet.Request;
import org.restlet.Response;
import org.restlet.data.ChallengeResponse;
import org.restlet.data.ChallengeScheme;
import org.restlet.data.Method;
import org.restlet.data.Protocol;
import org.restlet.data.Range;
import org.restlet.data.Status;
import org.restlet.representation.EmptyRepresentation;
import org.serviio.util.FileUtils;
import org.serviio.util.HttpClient;
import org.serviio.util.HttpUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class OnlineInputStream : InputStream
{
  private static const int DEFAULT_CHUNK_SIZE = 1512000;
  private static immutable Logger log = LoggerFactory.getLogger!(OnlineInputStream);
  private URL contentURL;
  private String[] credentials;
  private Long contentSize;
  private long pos;
  private int bufferPos;
  private /*volatile*/ byte[] onlineBuffer;
  bool allConsumed = false;

  bool supportsRange = true;
  private InputStream wholeStream;
  private Client restletClient = new Client(Protocol.HTTP);

  private int chunkSize = DEFAULT_CHUNK_SIZE;

  public this(URL contentUrl, Long contentSize, bool supportsByterange)
  {
    contentURL = contentUrl;
    this.contentSize = contentSize;
    credentials = HttpUtils.getCredentialsFormUrl(contentUrl.toString());
    supportsRange = supportsByterange;
  }

  public this(URL contentUrl, Long contentSize, bool supportsByterange, int chunkSize) {
    this(contentUrl, contentSize, supportsByterange);
    this.chunkSize = chunkSize;
  }

  public int read()
  {
    if ((supportsRange) || ((!supportsRange) && (wholeStream is null))) {
      try {
        if ((!allConsumed) && ((onlineBuffer is null) || (bufferPos >= chunkSize)))
        {
          fill();
        }
        if ((onlineBuffer !is null) && (bufferPos < onlineBuffer.length)) {
          pos += 1L;
          return onlineBuffer[(bufferPos++)] & 0xFF;
        }
        cleanup();
        return -1;
      }
      catch (RangeNotSupportedException e) {
        supportsRange = false;
        return wholeStream.read();
      }
    }

    return wholeStream.read();
  }

  public long skip(long n)
  {
    if (supportsRange) {
      pos += n;
      try {
        fill();
      } catch (RangeNotSupportedException e) {
        supportsRange = false;
        return super.skip(n);
      }
      return n;
    }

    return wholeStream !is null ? wholeStream.skip(n) : 0L;
  }

  public int available()
  {
    if (supportsRange) {
      if (onlineBuffer !is null) {
        return onlineBuffer.length - bufferPos;
      }
      return 0;
    }

    return wholeStream !is null ? wholeStream.available() : 0;
  }

  public void close()
  {
    log.debug_("Closing stream");
    try {
      if (wholeStream !is null)
        wholeStream.close();
    }
    finally {
      cleanup();
    }
  }

  private void cleanup()
  {
    try
    {
      restletClient.stop();
      onlineBuffer = null;
    } catch (Exception e) {
      log.warn("Exception during HTTP client closing: " + e.getMessage());
    }
  }

  private void fill()
  {
    onlineBuffer = readFileChunk(pos, chunkSize);
    bufferPos = 0;
    if (onlineBuffer.length < chunkSize)
    {
      allConsumed = true;
    }
  }

  private byte[] readFileChunk(long startByte, long byteCount)
  {
    log.debug_(String.format("Reading %s bytes starting at %s", cast(Object[])[ Long.valueOf(byteCount), Long.valueOf(startByte) ]));
    Request request = new Request(Method.GET, contentURL.toString());
    if (credentials !is null) {
      ChallengeScheme scheme = ChallengeScheme.HTTP_BASIC;
      ChallengeResponse authentication = new ChallengeResponse(scheme, credentials[0], credentials[1]);
      request.setChallengeResponse(authentication);
    }
    if (supportsRange) {
      Range byteRange = new Range(startByte, byteCount);
      if ((contentSize !is null) && (startByte + byteCount > contentSize.longValue())) {
        byteRange = new Range(startByte, contentSize.longValue() - startByte);
      }
      List!(Range) ranges = Collections.singletonList(byteRange);
      request.setRanges(ranges);
    }
    Response response = restletClient.handle(request);
    if ((Status.SUCCESS_OK.equals(response.getStatus())) || ((new Status(-1)).equals(response.getStatus())))
    {
      log.debug_(String.format("Byte range not supported for %s, returning the whole stream", cast(Object[])[ contentURL.toString() ]));
      wholeStream = getResponseStream(response);
      throw new RangeNotSupportedException();
    }if (Status.SUCCESS_PARTIAL_CONTENT.equals(response.getStatus())) {
      InputStream content = getResponseStream(response);
      byte[] bytes = FileUtils.readFileBytes(content);
      log.debug_(String.format("Returning %s bytes from partial content response", cast(Object[])[ Integer.valueOf(bytes.length) ]));
      return bytes;
    }if (response.getStatus().isRedirection()) {
      contentURL = response.getLocationRef().toUrl();
      log.debug_(String.format("302 returned, redirecting to %s", cast(Object[])[ contentURL ]));
      return readFileChunk(startByte, byteCount);
    }if (response.getStatus().equals(Status.CLIENT_ERROR_REQUESTED_RANGE_NOT_SATISFIABLE)) {
      wholeStream = getResponseStream(response);
      log.debug_(String.format("Byte range not satisfiable for %s, returning the whole stream", cast(Object[])[ contentURL.toString() ]));
      throw new RangeNotSupportedException();
    }
    throw new IOException(String.format("Status '%s' received from '%s', cancelling transfer", cast(Object[])[ response.getStatus(), contentURL.toString() ]));
  }

  private InputStream getResponseStream(Response response)
  {
    if ((response.getEntity() !is null) && (!( cast(EmptyRepresentation)response.getEntity() !is null ))) {
      return response.getEntity().getStream();
    }
    if (HttpUtils.isHttpUrl(contentURL.toString())) {
      log.debug_("Trying basic stream handler");
      try {
        return HttpClient.getStreamFromURL(contentURL.toString());
      }
      catch (IOException e) {
        log.debug_("Trying ShoutCast stream handler");
        InputStream stream = HttpClient.getShoutCastStream(contentURL.toString());
        if (stream !is null) {
          return stream;
        }
      }
    }
    throw new IOException(String.format("Cannot open stream from '%s', possibly incorrect URL or invalid HTTP response", cast(Object[])[ contentURL.toString() ]));
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.OnlineInputStream
 * JD-Core Version:    0.6.2
 */