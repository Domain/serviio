module org.serviio.library.local.service.FolderService;

import java.util.List;
import org.serviio.db.dao.DAOFactory;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Folder;
import org.serviio.library.entities.Repository;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.library.service.Service;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.util.FileUtils;
import org.serviio.util.ObjectValidator;

public class FolderService
  : Service
{
  public static Folder getFolder(Long folderId)
  {
    Folder folder = cast(Folder)DAOFactory.getFolderDAO().read(folderId);
    if (folder !is null) {
      normalizeFolderName(folder);
    }
    return folder;
  }

  public static Long createOrReadFolder(Repository repository, String relativeFilePath)
  {
    Long folderId = DAOFactory.getFolderDAO().getOrCreateFolder(FileUtils.getRelativeDirectory(repository.getFolder(), relativeFilePath), repository.getId());

    return folderId;
  }

  public static void removeFolderAndItsParents(Long folderId)
  {
    if (folderId !is null)
    {
      Folder folder = cast(Folder)DAOFactory.getFolderDAO().read(folderId);

      if ((DAOFactory.getFolderDAO().getNumberOfMediaItems(folderId) == 0) && (DAOFactory.getFolderDAO().getNumberOfSubFolders(folderId, folder.getRepositoryId(), AccessGroup.ANY) == 0))
      {
        DAOFactory.getFolderDAO().delete_(folderId);

        removeFolderAndItsParents(folder.getParentFolderId());
      }
    }
  }

  public static List!(Folder) getListOfFoldersWithMedia(MediaFileType mediaType, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    List!(Folder) folders = DAOFactory.getFolderDAO().retrieveFoldersWithMedia(mediaType, accessGroup, startingIndex, requestedCount);
    foreach (Folder folder ; folders) {
      normalizeFolderName(folder);
    }
    return folders;
  }

  public static int getNumberOfFoldersWithMedia(MediaFileType mediaType, AccessGroup accessGroup)
  {
    return DAOFactory.getFolderDAO().getFoldersWithMediaCount(mediaType, accessGroup);
  }

  public static int getNumberOfFoldersAndMediaItems(MediaFileType fileType, ObjectType objectType, AccessGroup accessGroup, Long folderId, Long repositoryId) {
    return DAOFactory.getFolderDAO().getNumberOfFoldersAndMediaItems(fileType, objectType, accessGroup, folderId, repositoryId);
  }

  public static List!(Folder) getListOfSubFolders(Long folderId, Long repositoryId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    List!(Folder) folders = DAOFactory.getFolderDAO().retrieveSubFolders(folderId, repositoryId, accessGroup, startingIndex, requestedCount);
    foreach (Folder folder ; folders) {
      normalizeFolderName(folder);
    }
    return folders;
  }

  public static int getNumberOfSubfolders(Long folderId, Long repositoryId, AccessGroup accessGroup)
  {
    return DAOFactory.getFolderDAO().getNumberOfSubFolders(folderId, repositoryId, accessGroup);
  }

  public static Long retrieveVirtualFolderId(Long repositoryId)
  {
    return DAOFactory.getFolderDAO().retrieveVirtualFolderId(repositoryId);
  }

  private static void normalizeFolderName(Folder folder)
  {
    if (folder.getName().equals("!(virtual)"))
    {
      Repository repository = RepositoryService.getRepository(folder.getRepositoryId());
      folder.setName(ObjectValidator.isNotEmpty(repository.getFolder().getName()) ? repository.getFolder().getName() : repository.getFolder().getPath());
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.service.FolderService
 * JD-Core Version:    0.6.2
 */