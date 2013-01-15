module org.serviio.delivery.resource.transcode.FileBasedTranscodingDeliveryStrategy;

import java.lang.String;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import org.serviio.delivery.Client;
import org.serviio.delivery.DeliveryListener;
import org.serviio.library.entities.MediaItem;
import org.serviio.util.ThreadUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.serviio.delivery.resource.transcode.AbstractTranscodingDeliveryStrategy;
import org.serviio.delivery.resource.transcode.TranscodingDeliveryStrategy;

public class FileBasedTranscodingDeliveryStrategy : AbstractTranscodingDeliveryStrategy
  , TranscodingDeliveryStrategy!(File)
{
  private static immutable Logger log = LoggerFactory.getLogger!(FileBasedTranscodingDeliveryStrategy)();

  public StreamDescriptor createInputStream(TranscodingJobListener jobListener, Client client)
  {
    File transcodedFile = jobListener.getTranscodedFile();
    if (!transcodedFile.exists())
      throw new IOException(String.format("Transcoded file '%s' cannot be found, FFmpeg execution probably failed", cast(Object[])[ transcodedFile.getPath() ]));
    if ((jobListener.isFinished()) && (!jobListener.isSuccessful())) {
      throw new IOException("FFmpeg execution failed");
    }
    transcodedFile.deleteOnExit();
    StreamDescriptor stream = null;
    if (!jobListener.isFinished()) {
      log.debug_("Sending transcoding stream");

      InputStream fis = new TranscodeInputStream(transcodedFile, client);
      jobListener.addStream(cast(TranscodeInputStream)fis);
      stream = new StreamDescriptor(fis, null);
    }
    else {
      log.debug_(String.format("Transcoded file '%s' is complete, sending simple stream", cast(Object[])[ transcodedFile ]));
      InputStream fis = new FileInputStream(transcodedFile);
      stream = new StreamDescriptor(fis, Long.valueOf(transcodedFile.length()));
    }
    return stream;
  }

  public TranscodingJobListener invokeTranscoder(String transcodingIdentifier, MediaItem mediaItem, Double timeOffsetInSeconds, Double durationInSeconds, TranscodingDefinition trDef, Client client, DeliveryListener deliveryListener)
  {
    File transcodedFile = prepareTranscodedOutput(transcodingIdentifier);

    TranscodingJobListener jobListener = new TranscodingJobListener(transcodingIdentifier);
    jobListener.setTranscodedFile(transcodedFile);

    invokeTranscoder(mediaItem, timeOffsetInSeconds, durationInSeconds, jobListener.getTranscodedFile(), trDef, jobListener);

    int retries = 0;
    int maxRetries = mediaItem.isLocalMedia() ? 15 : 50;
    while (((!transcodedFile.exists()) || (transcodedFile.length() == 0L)) && (retries++ < maxRetries)) {
      ThreadUtils.currentThreadSleep(500L);
    }
    return jobListener;
  }

  private File prepareTranscodedOutput(String transcodingIdentifier)
  {
    File transcodingFolder = prepareTranscodingFolder();
    return new File(transcodingFolder, transcodingIdentifier);
  }

  private File prepareTranscodingFolder()
  {
    File transcodingFolder = AbstractTranscodingDeliveryEngine.getTranscodingFolder();
    if (!transcodingFolder.exists()) {
      bool created = transcodingFolder.mkdirs();
      if (!created) {
        throw new IOException(String.format("Cannot create transcoding folder: %s", cast(Object[])[ transcodingFolder.getAbsolutePath() ]));
      }
    }
    return transcodingFolder;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.resource.transcode.FileBasedTranscodingDeliveryStrategy
 * JD-Core Version:    0.6.2
 */