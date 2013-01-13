module org.serviio.ui.resources.server.ActionsServerResource;

import java.io.IOException;
import org.restlet.data.Status;
import org.serviio.MediaServer;
import org.serviio.delivery.DeliveryContext;
import org.serviio.library.entities.OnlineRepository;
import org.serviio.library.local.LibraryManager;
import org.serviio.library.local.metadata.MetadataFactory;
import org.serviio.library.local.metadata.extractor.InvalidMediaFormatException;
import org.serviio.library.metadata.FFmpegMetadataRetriever;
import org.serviio.library.metadata.ItemMetadata;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.library.online.OnlineLibraryManager;
import org.serviio.library.online.service.OnlineRepositoryService;
import org.serviio.restlet.AbstractServerResource;
import org.serviio.restlet.OperationException;
import org.serviio.restlet.ResultRepresentation;
import org.serviio.restlet.ValidationException;
import org.serviio.ui.representation.ActionRepresentation;
import org.serviio.ui.resources.ActionsResource;
import org.serviio.upnp.discovery.DiscoveryManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ActionsServerResource : AbstractServerResource
  , ActionsResource
{
  private static final Logger log = LoggerFactory.getLogger!(ActionsServerResource);

  public ResultRepresentation execute(ActionRepresentation representation)
  {
    if (representation is null) {
      log.error("No action name specified, returning 400");
      setStatus(Status.CLIENT_ERROR_BAD_REQUEST);
    } else {
      log.debug_(String.format("Action with name '%s' was requested", cast(Object[])[ representation.getName() ]));
      if (representation.getName().equals("forceVideoFilesMetadataUpdate"))
        return forceOnlineVideoFilesUpdate(representation);
      if (representation.getName().equals("forceLibraryRefresh"))
        return forceLibraryRefresh(representation);
      if (representation.getName().equals("forceOnlineResourceRefresh"))
        return forceOnlineResourceRefresh(representation);
      if (representation.getName().equals("startServer"))
        return startServer(representation);
      if (representation.getName().equals("stopServer"))
        return stopServer(representation);
      if (representation.getName().equals("exitServiio"))
        return exitServiio(representation);
      if (representation.getName().equals("advertiseService"))
        return advertiseService(representation);
      if (representation.getName().equals("checkStreamUrl")) {
        return checkStreamUrl(representation);
      }
      log.error(String.format("Action with name '%s' is not implemented, returning 400", cast(Object[])[ representation.getName() ]));
      setStatus(Status.CLIENT_ERROR_BAD_REQUEST);
    }

    return null;
  }

  private ResultRepresentation forceOnlineVideoFilesUpdate(ActionRepresentation representation)
  {
    LibraryManager.getInstance().forceMetadataUpdate(MediaFileType.VIDEO);
    return responseOk();
  }

  private synchronized ResultRepresentation forceLibraryRefresh(ActionRepresentation representation)
  {
    LibraryManager.getInstance().stopLibraryAdditionsCheckerThread();
    LibraryManager.getInstance().stopLibraryUpdatesCheckerThread();
    LibraryManager.getInstance().startLibraryAdditionsCheckerThread();
    LibraryManager.getInstance().startLibraryUpdatesCheckerThread();
    return responseOk();
  }

  private synchronized ResultRepresentation forceOnlineResourceRefresh(ActionRepresentation representation)
  {
    validateParameters(representation, 1);
    OnlineRepository rep = OnlineRepositoryService.getRepository(Long.valueOf(Long.parseLong(cast(String)representation.getParameters().get(0))));
    OnlineLibraryManager.getInstance().removeOnlineContentFromCache(rep.getRepositoryUrl());
    return responseOk();
  }

  private ResultRepresentation startServer(ActionRepresentation representation) {
    MediaServer.startServer();
    return responseOk();
  }

  private ResultRepresentation stopServer(ActionRepresentation representation) {
    MediaServer.stopServer();
    return responseOk();
  }

  private ResultRepresentation exitServiio(ActionRepresentation representation) {
    try {
      return responseOk();
    } finally {
      MediaServer.exit();
    }
  }

  private ResultRepresentation advertiseService(ActionRepresentation representation) {
    try {
      DiscoveryManager.instance().sendSSDPAlive();
      return responseOk();
    } catch (IOException e) {
      throw new OperationException(e, 602);
    }
  }

  private ResultRepresentation checkStreamUrl(ActionRepresentation representation)
  {
    validateParameters(representation, 2);
    try {
      MediaFileType fileType = MediaFileType.valueOf(cast(String)representation.getParameters().get(0));
      String url = cast(String)representation.getParameters().get(1);

      ItemMetadata md = MetadataFactory.getMetadataInstance(fileType);
      FFmpegMetadataRetriever.retrieveOnlineMetadata(md, url, new DeliveryContext(false, null));
      return responseOk();
    } catch (InvalidMediaFormatException e) {
      return responseOk(603);
    } catch (IOException e) {
      return responseOk(603);
    } catch (Exception e) {
      throw new ValidationException(e.getMessage(), 700);
    }
  }

  private void validateParameters(ActionRepresentation representation, int paramNumber) {
    if ((representation.getParameters() is null) || (representation.getParameters().size() != paramNumber))
      throw new ValidationException(700);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.resources.server.ActionsServerResource
 * JD-Core Version:    0.6.2
 */