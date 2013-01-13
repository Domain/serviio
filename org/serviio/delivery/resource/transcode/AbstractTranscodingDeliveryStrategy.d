module org.serviio.delivery.resource.transcode.AbstractTranscodingDeliveryStrategy;

import java.lang.Double;
import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import org.serviio.external.FFMPEGWrapper;
import org.serviio.library.entities.MediaItem;

public abstract class AbstractTranscodingDeliveryStrategy
{
  protected OutputStream invokeTranscoder(MediaItem mediaItem, Double timeOffsetInSeconds, Double durationInSeconds, File transcodedFile, TranscodingDefinition trDef, TranscodingJobListener jobListener)
  {
    OutputStream transcodedStream = FFMPEGWrapper.transcodeFile(mediaItem, mediaItem.getDeliveryContext(), transcodedFile, trDef, jobListener, timeOffsetInSeconds, durationInSeconds);
    return transcodedStream;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.resource.transcode.AbstractTranscodingDeliveryStrategy
 * JD-Core Version:    0.6.2
 */