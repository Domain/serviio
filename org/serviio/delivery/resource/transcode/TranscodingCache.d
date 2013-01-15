module org.serviio.delivery.resource.transcode.TranscodingCache;

import java.lang.Long;
import org.serviio.dlna.MediaFormatProfile;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TranscodingCache
{
  private static immutable Logger log = LoggerFactory.getLogger!(TranscodingCache)();
  private Long mediaItemId;
  private MediaFormatProfile transcodedProfile;
  private byte[] transcodedData;

  public void storeInCache(Long mediaItemId, MediaFormatProfile transcodedProfile, byte[] transcodedData)
  {
    log.debug_(String.format("Storing media item %s with profile %s to cache", cast(Object[])[ mediaItemId, transcodedProfile.toString() ]));
    this.mediaItemId = mediaItemId;
    this.transcodedProfile = transcodedProfile;
    this.transcodedData = transcodedData;
  }

  public bool isInCache(Long mediaItemId, MediaFormatProfile transcodedProfile)
  {
    if ((this.mediaItemId !is null) && (this.mediaItemId.equals(mediaItemId)) && (this.transcodedProfile == transcodedProfile))
    {
      return true;
    }
    return false;
  }

  public byte[] getCachedBytes()
  {
    if (transcodedData !is null) {
      log.debug_(String.format("Retrieving media item %s with profile %s from cache", cast(Object[])[ mediaItemId, transcodedProfile.toString() ]));
      byte[] dst = new byte[transcodedData.length];
      System.arraycopy(transcodedData, 0, dst, 0, transcodedData.length);
      return dst;
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.resource.transcode.TranscodingCache
 * JD-Core Version:    0.6.2
 */