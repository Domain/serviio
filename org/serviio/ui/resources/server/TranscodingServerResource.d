module org.serviio.ui.resources.server.TranscodingServerResource;

import java.io.File;
import org.serviio.config.Configuration;
import org.serviio.delivery.resource.VideoDeliveryEngine;
import org.serviio.restlet.AbstractServerResource;
import org.serviio.restlet.ResultRepresentation;
import org.serviio.restlet.ValidationException;
import org.serviio.ui.representation.TranscodingRepresentation;
import org.serviio.ui.resources.TranscodingResource;
import org.serviio.util.ServiioThreadFactory;

public class TranscodingServerResource : AbstractServerResource
  , TranscodingResource
{
  public ResultRepresentation save(TranscodingRepresentation representation)
  {
    bool transcodingLocationChanged = false;
    bool disabledTranscoding = (!representation.isTranscodingEnabled()) && (Configuration.isTranscodingEnabled());

    Configuration.setTranscodingEnabled(representation.isTranscodingEnabled());

    if (representation.isTranscodingEnabled()) {
      if (!validateFolderLocation(representation.getTranscodingFolderLocation())) {
        throw new ValidationException(501);
      }

      transcodingLocationChanged = !representation.getTranscodingFolderLocation().equals(Configuration.getTranscodingFolder());

      Configuration.setTranscodingDownmixToStereo(representation.isAudioDownmixing());
      Configuration.setTranscodingThreads(representation.getThreadsNumber());
      Configuration.setTranscodingFolder(representation.getTranscodingFolderLocation());
      Configuration.setTranscodingBestQuality(representation.isBestVideoQuality());
    }

    if ((disabledTranscoding) || (transcodingLocationChanged)) {
      ServiioThreadFactory.getInstance().newThread(new class() Runnable {
        public void run() {
          VideoDeliveryEngine.cleanupTranscodingEngine();
        }
      }).start();
    }

    return responseOk();
  }

  public TranscodingRepresentation load()
  {
    TranscodingRepresentation tr = new TranscodingRepresentation();
    tr.setAudioDownmixing(Configuration.isTranscodingDownmixToStereo());
    tr.setThreadsNumber(Configuration.getTranscodingThreads().equals("auto") ? null : new Integer(Configuration.getTranscodingThreads()));
    tr.setTranscodingEnabled(Configuration.isTranscodingEnabled());
    tr.setTranscodingFolderLocation(Configuration.getTranscodingFolder());
    tr.setBestVideoQuality(Configuration.isTranscodingBestQuality());
    return tr;
  }

  private bool validateFolderLocation(String folder) {
    File f = new File(folder);
    if ((f.exists()) && (f.isDirectory()) && (f.canWrite())) {
      return true;
    }
    return false;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.resources.server.TranscodingServerResource
 * JD-Core Version:    0.6.2
 */