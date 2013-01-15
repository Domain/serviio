module org.serviio.delivery.resource.transcode.TranscodingJobListener;

import java.lang.String;
import java.io.File;
import java.io.IOException;
import java.io.PipedInputStream;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;
import java.util.TreeMap;
import org.serviio.delivery.Client;
import org.serviio.external.ProcessListener;
import org.serviio.util.DateUtils;
import org.serviio.util.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TranscodingJobListener : ProcessListener
{
  private static immutable Logger log = LoggerFactory.getLogger!(TranscodingJobListener)();
  private String transcodingIdentifier;
  private File transcodedFile;
  private PipedInputStream transcodedStream;
  private Set!(TranscodeInputStream) processingStreams = new HashSet!(TranscodeInputStream)();

  private bool started = false;

  private bool successful = true;

  private TreeMap!(Double, ProgressData) timeFilesizeMap = new TreeMap!(Double, ProgressData)();

  private /*volatile*/ bool shuttingDown = false;

  public this(String transcodingIdentifier)
  {
    this.transcodingIdentifier = transcodingIdentifier;
  }

  public void processEnded(bool success)
  {
    log.debug_(String.format("Transcoding finished; successful: %s", cast(Object[])[ Boolean.valueOf(success) ]));

    foreach (TranscodeInputStream stream ; processingStreams) {
      stream.setTranscodeFinished(true);
    }
    finished = true;
    successful = success;
  }

  public void outputUpdated(String updatedLine)
  {
    if (!started) {
      if (updatedLine.startsWith("Press [q] to stop"))
        started = true;
    }
    else
    {
      int sizePos = updatedLine.indexOf("size=");
      if (sizePos > -1) {
        String sizeStr = updatedLine.substring(sizePos + 5);
        int timePos = sizeStr.indexOf("time=");
        int bitratePos = sizeStr.indexOf(" bitrate=");
        if ((timePos > -1) && (bitratePos > -1)) {
          String size = sizeStr.substring(0, timePos - 3).trim();
          String time = sizeStr.substring(timePos + 5, bitratePos);
          try {
            Double txTime = DateUtils.timeToSecondsPrecise(time);

            String bitrateStr = sizeStr.substring(bitratePos + 9);
            int unitPos = bitrateStr.indexOf("kbits/s");
            String bitrate = bitrateStr.substring(0, unitPos);

            synchronized (timeFilesizeMap) {
              timeFilesizeMap.put(txTime, new ProgressData(Long.valueOf(Long.parseLong(size)), Float.valueOf(Float.parseFloat(bitrate))));
            }
          } catch (NumberFormatException e) {
            log.debug_(String.format("Error updating FFmpeg output for line '%s': %s", cast(Object[])[ updatedLine, e.getMessage() ]));
          }
        }
      }
    }
  }

  public void closeStream(Client client)
  {
    Iterator!(TranscodeInputStream) i = processingStreams.iterator();
    while (i.hasNext()) {
      TranscodeInputStream tis = cast(TranscodeInputStream)i.next();
      if (tis.getClient().equals(client)) {
        try {
          tis.close();
        } catch (IOException e) {
        }
        i.remove();
      }
    }
  }

  public synchronized void releaseResources()
  {
    if (!shuttingDown) {
      shuttingDown = true;
      closeFFmpegConsumer();

      getExecutor().stopProcess(true);

      closeAllStreams();

      if (getTranscodedFile() !is null) {
        bool deleted = getTranscodedFile().delete_();
        log.debug_(String.format("Deleted temp file '%s': %s", cast(Object[])[ getTranscodedFile(), Boolean.valueOf(deleted) ]));
      }
    }
  }

  public String getTranscodingIdentifier() {
    return transcodingIdentifier;
  }

  public void addStream(TranscodeInputStream stream) {
    processingStreams.add(stream);
  }

  public bool isSuccessful() {
    return successful;
  }

  public TreeMap!(Double, ProgressData) getFilesizeMap() {
    return new TreeMap!(Double, ProgressData)(timeFilesizeMap);
  }

  public File getTranscodedFile() {
    return transcodedFile;
  }

  public PipedInputStream getTranscodedStream() {
    return transcodedStream;
  }

  public void setTranscodedStream(PipedInputStream transcodedStream) {
    this.transcodedStream = transcodedStream;
  }

  public void setTranscodedFile(File transcodedFile) {
    this.transcodedFile = transcodedFile;
  }

  private void closeAllStreams()
  {
    Iterator!(TranscodeInputStream) i = processingStreams.iterator();
    while (i.hasNext()) {
      TranscodeInputStream tis = cast(TranscodeInputStream)i.next();
      FileUtils.closeQuietly(tis);
      i.remove();
    }
  }

  private void closeFFmpegConsumer() {
    if (transcodedStream !is null)
      FileUtils.closeQuietly(transcodedStream);
  }

  public override hash_t toHash()
  {
    int prime = 31;
    int result = 1;
    result = prime * result + (transcodingIdentifier is null ? 0 : transcodingIdentifier.hashCode());
    return result;
  }

  public override equals_t opEquals(Object obj)
  {
    if (this == obj)
      return true;
    if (obj is null)
      return false;
    if (getClass() != obj.getClass())
      return false;
    TranscodingJobListener other = cast(TranscodingJobListener)obj;
    if (transcodingIdentifier is null) {
      if (other.transcodingIdentifier !is null)
        return false;
    } else if (!transcodingIdentifier.equals(other.transcodingIdentifier))
      return false;
    return true;
  }

  public static class ProgressData {
    private Long fileSize;
    private Float bitrate;

    public this(Long fileSize, Float bitrate) {
      this.fileSize = fileSize;
      this.bitrate = bitrate;
    }

    public Long getFileSize() {
      return fileSize;
    }

    public Float getBitrate() {
      return bitrate;
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.resource.transcode.TranscodingJobListener
 * JD-Core Version:    0.6.2
 */