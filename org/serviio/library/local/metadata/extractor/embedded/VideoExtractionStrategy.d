module org.serviio.library.local.metadata.extractor.embedded.VideoExtractionStrategy;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import org.serviio.config.Configuration;
import org.serviio.delivery.DeliveryContext;
import org.serviio.dlna.VideoContainer;
import org.serviio.external.FFMPEGWrapper;
import org.serviio.library.local.metadata.ImageDescriptor;
import org.serviio.library.local.metadata.TransportStreamTimestamp;
import org.serviio.library.local.metadata.VideoMetadata;
import org.serviio.library.local.metadata.extractor.InvalidMediaFormatException;
import org.serviio.library.metadata.FFmpegMetadataRetriever;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class VideoExtractionStrategy
{
  private static final Logger log = LoggerFactory.getLogger!(VideoExtractionStrategy);

  public void extractMetadata(VideoMetadata metadata, File f)
  {
    log.debug_(String.format("Extracting metadata of video file: %s", cast(Object[])[ f.getAbsolutePath() ]));

    FFmpegMetadataRetriever.retrieveMetadata(metadata, f.getPath(), DeliveryContext.LOCAL);

    setupTimestampForMPEG2TS(metadata, f);

    if (Configuration.isGenerateLocalThumbnailForVideos())
    {
      byte[] thumbnailImage = FFMPEGWrapper.readVideoThumbnail(f, metadata.getDuration(), metadata.getVideoCodec(), metadata.getContainer());
      if ((thumbnailImage !is null) && (thumbnailImage.length > 0)) {
        ImageDescriptor imageDesc = new ImageDescriptor(thumbnailImage, "image/jpeg");
        metadata.setCoverImage(imageDesc);
      }
    }
  }

  protected void setupTimestampForMPEG2TS(VideoMetadata metadata, File f)
  {
    TransportStreamTimestamp ts = null;
    if (metadata.getContainer() == VideoContainer.MPEG2TS) {
      RandomAccessFile raf = null;
      try {
        raf = new RandomAccessFile(f, "r");
        byte[] packetBuffer = new byte['Å'];
        raf.read(packetBuffer);
        if (packetBuffer[0] == 71)
        {
          ts = TransportStreamTimestamp.NONE;
        }
        else if ((packetBuffer[4] == 71) && (packetBuffer['Ä'] == 71))
        {
          if ((packetBuffer[0] == 0) && (packetBuffer[1] == 0) && (packetBuffer[2] == 0) && (packetBuffer[3] == 0))
          {
            ts = TransportStreamTimestamp.ZERO;
            log.debug_("Found ZERO value timestamp in the transport stream");
          } else {
            ts = TransportStreamTimestamp.VALID;
            log.debug_("Found VALID value timestamp in the transport stream");
          }
        } else {
          log.warn("Cannot find a valid timestamp in the transport stream packet, setting it to NONE");
          ts = TransportStreamTimestamp.NONE;
        }
      }
      finally {
        if (raf !is null) {
          raf.close();
        }
      }
    }
    metadata.setTimestampType(ts);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.VideoExtractionStrategy
 * JD-Core Version:    0.6.2
 */