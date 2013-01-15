module org.serviio.library.online.service.OnlineRepositoryService;

import java.util.ArrayList;
import java.util.List;
import org.serviio.db.dao.DAOFactory;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.OnlineRepository;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.library.online.OnlineItemService;
import org.serviio.library.service.Service;
import org.serviio.upnp.Device;
import org.serviio.upnp.service.contentdirectory.ContentDirectory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class OnlineRepositoryService
  : Service
{
  private static final Logger log = LoggerFactory.getLogger!(OnlineRepositoryService)();

  public static List!(OnlineRepository) getAllRepositories()
  {
    return DAOFactory.getOnlineRepositoryDAO().findAll();
  }

  public static OnlineRepository getRepository(Long repositoryId) {
    return cast(OnlineRepository)DAOFactory.getOnlineRepositoryDAO().read(repositoryId);
  }

  public static void deleteRepository(Long repositoryId) {
    DAOFactory.getOnlineRepositoryDAO().delete_(repositoryId);
  }

  public static void saveRepositories(List!(OnlineRepository) repositories)
  {
    List!(OnlineRepository) existingRepositories = getAllRepositories();
    List!(OnlineRepository) repsToRemove = new ArrayList!(OnlineRepository)();

    bool repositoryUpdated = false;

    foreach (OnlineRepository existingRepository ; existingRepositories) {
      if (!repositories.contains(existingRepository)) {
        log.debug_(String.format("Will remove OnlineRepository: %s", cast(Object[])[ existingRepository.toString() ]));
        repsToRemove.add(existingRepository);
      }
    }

    foreach (OnlineRepository repoToDelete ; repsToRemove) {
      deleteRepository(repoToDelete.getId());

      OnlineItemService.removeOnlineContentFromCache(repoToDelete.getRepositoryUrl());
      repositoryUpdated = true;
    }

    foreach (OnlineRepository repository ; repositories) {
      if (repository.getId() is null)
      {
        DAOFactory.getOnlineRepositoryDAO().create(repository);
      }
      else {
        updateRepository(repository);
      }
      repositoryUpdated = true;
    }

    if (repositoryUpdated) {
      log.debug_("Online repositories updated, notifying CDS");
      ContentDirectory cds = cast(ContentDirectory)Device.getInstance().getServiceById("urn:upnp-org:serviceId:ContentDirectory");
      cds.incrementUpdateID();
    }
  }

  public static List!(OnlineRepository) getListOfRepositories(List!(OnlineRepository.OnlineRepositoryType) repoTypes, MediaFileType mediaType, AccessGroup accessGroup, bool onlyEnabled)
  {
    return DAOFactory.getOnlineRepositoryDAO().getRepositories(repoTypes, mediaType, accessGroup, onlyEnabled);
  }

  private static void updateRepository(OnlineRepository repository)
  {
    OnlineRepository existingRepository = getRepository(repository.getId());
    if ((repository.getFileType() != existingRepository.getFileType()) || (repository.getRepoType() != existingRepository.getRepoType()) || (!repository.getRepositoryUrl().equals(existingRepository.getRepositoryUrl())) || (repository.thumbnailChanged(repository.getThumbnailUrl())))
    {
      OnlineItemService.removeOnlineContentFromCache(existingRepository.getRepositoryUrl());
    }

    DAOFactory.getOnlineRepositoryDAO().update(repository);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.service.OnlineRepositoryService
 * JD-Core Version:    0.6.2
 */