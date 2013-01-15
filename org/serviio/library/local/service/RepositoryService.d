module org.serviio.library.local.service.RepositoryService;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import org.serviio.db.dao.DAOFactory;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.entities.Playlist;
import org.serviio.library.entities.Repository;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.library.service.AccessGroupService;
import org.serviio.library.service.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RepositoryService
  : Service
{
  private static final Logger log = LoggerFactory.getLogger!(RepositoryService)();

  public static List!(Repository) getAllRepositories()
  {
    return DAOFactory.getRepositoryDAO().findAll();
  }

  public static Repository getRepository(Long repositoryId) {
    return cast(Repository)DAOFactory.getRepositoryDAO().read(repositoryId);
  }

  public static bool saveRepositories(List!(Repository) repositories)
  {
    List!(Repository) existingRepositories = getAllRepositories();
    List!(Repository) repsToRemove = new ArrayList!(Repository)();
    bool mediaItemsModified = false;

    foreach (Repository existingRepository ; existingRepositories) {
      if (!repositories.contains(existingRepository)) {
        log.debug_(String.format("Will remove Repository: %s", cast(Object[])[ existingRepository.toString() ]));
        repsToRemove.add(existingRepository);
      }
    }

    if (removeRepositories(repsToRemove)) {
      mediaItemsModified = true;
    }

    repositories.removeAll(repsToRemove);
    foreach (Repository repository ; repositories) {
      if (repository.getId() is null)
      {
        DAOFactory.getRepositoryDAO().create(repository);
      }
      else if (updateRepository(repository)) {
        mediaItemsModified = true;
      }
    }

    return mediaItemsModified;
  }

  public static List!(Repository) getListOfRepositories(MediaFileType mediaType, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    return DAOFactory.getRepositoryDAO().getRepositories(mediaType, accessGroup, startingIndex, requestedCount);
  }

  public static int getNumberOfRepositories(MediaFileType mediaType, AccessGroup accessGroup)
  {
    return DAOFactory.getRepositoryDAO().getRepositoriesCount(mediaType, accessGroup);
  }

  public static void markRepositoryAsScanned(Long repoId) {
    DAOFactory.getRepositoryDAO().markRepositoryAsScanned(repoId);
  }

  private static bool removeRepositories(List!(Repository) repositories)
  {
    log.debug_(String.format("Found %s repositories to be removed", cast(Object[])[ Integer.valueOf(repositories.size()) ]));
    bool mediaItemsRemoved = false;
    foreach (Repository repository ; repositories) {
      log.debug_(String.format("Removing all items in repository %s", cast(Object[])[ repository.getId() ]));

      List!(MediaItem) mediaItems = MediaService.getMediaItemsInRepository(repository.getId());
      foreach (MediaItem mediaItem ; mediaItems) {
        if (mediaItem.getFileType() == MediaFileType.AUDIO)
          AudioService.removeMusicTrackFromLibrary(mediaItem.getId());
        else if (mediaItem.getFileType() == MediaFileType.VIDEO)
          VideoService.removeVideoFromLibrary(mediaItem.getId());
        else if (mediaItem.getFileType() == MediaFileType.IMAGE) {
          ImageService.removeImageFromLibrary(mediaItem.getId());
        }
        mediaItemsRemoved = true;
      }

      List!(Playlist) playlists = PlaylistService.getPlaylistsInRepository(repository.getId());
      foreach (Playlist playlist ; playlists) {
        PlaylistService.detetePlaylistAndItems(playlist.getId());
      }

      DAOFactory.getRepositoryDAO().delete_(repository.getId());
    }
    return mediaItemsRemoved;
  }

  private static bool updateRepository(Repository repository)
  {
    bool mediaItemsRemoved = false;
    Repository existingRepository = getRepository(repository.getId());

    Set!(MediaFileType) existingSupportedFileTypes = existingRepository.getSupportedFileTypes();
    existingSupportedFileTypes.removeAll(repository.getSupportedFileTypes());

    foreach (MediaFileType unsupportedFileType ; existingSupportedFileTypes) {
      List!(MediaItem) mediaItems = MediaService.getMediaItemsInRepository(repository.getId(), unsupportedFileType);
      foreach (MediaItem mediaItem ; mediaItems) {
        if (mediaItem.getFileType() == MediaFileType.AUDIO)
          AudioService.removeMusicTrackFromLibrary(mediaItem.getId());
        else if (mediaItem.getFileType() == MediaFileType.VIDEO)
          VideoService.removeVideoFromLibrary(mediaItem.getId());
        else if (mediaItem.getFileType() == MediaFileType.IMAGE) {
          ImageService.removeImageFromLibrary(mediaItem.getId());
        }
        mediaItemsRemoved = true;
      }

    }

    List!(AccessGroup) existingAccessGroups = AccessGroupService.getAccessGroupsForRepository(repository.getId());
    if ((existingAccessGroups.size() != repository.getAccessGroupIds().size()) || (!existingAccessGroups.containsAll(repository.getAccessGroupIds()))) {
      mediaItemsRemoved = true;
    }

    if (existingRepository.isSupportsOnlineMetadata() != repository.isSupportsOnlineMetadata()) {
      List!(MediaItem) mediaItems = MediaService.getMediaItemsInRepository(repository.getId());
      foreach (MediaItem mediaItem ; mediaItems) {
        MediaService.markMediaItemAsDirty(mediaItem.getId());
      }
    }

    DAOFactory.getRepositoryDAO().update(repository);

    return mediaItemsRemoved;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.service.RepositoryService
 * JD-Core Version:    0.6.2
 */