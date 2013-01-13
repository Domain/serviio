module org.serviio.upnp.service.contentdirectory.command.AbstractListObjectsByFSHierarchyCommand;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Folder;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.entities.Repository;
import org.serviio.library.local.service.AudioService;
import org.serviio.library.local.service.FolderService;
import org.serviio.library.local.service.ImageService;
import org.serviio.library.local.service.RepositoryService;
import org.serviio.library.local.service.VideoService;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectNotFoundException;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ClassProperties;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObject;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObjectBuilder;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.classes.Resource;
import org.serviio.upnp.service.contentdirectory.definition.Definition;
import org.serviio.util.ObjectValidator;

public abstract class AbstractListObjectsByFSHierarchyCommand : AbstractCommand!(DirectoryObject)
{
  private static final String REPOSITORY_PREFIX = "R";
  private static final String FOLDER_PREFIX = "F";
  private static final String ITEM_PREFIX = "MI";
  protected MediaFileType fileType;

  public this(String objectId, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count, MediaFileType fileType)
  {
    super(objectId, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
    this.fileType = fileType;
  }

  protected Set!(ObjectClassType) getSupportedClasses()
  {
    return new HashSet!(ObjectClassType)(Arrays.asList(ObjectClassType.values()));
  }

  protected Set!(ObjectType) getSupportedObjectTypes()
  {
    return ObjectType.getAllTypes();
  }

  protected List!(DirectoryObject) retrieveList()
  {
    List!(DirectoryObject) objects = new ArrayList!(DirectoryObject)();
    Long repositoryId = getRepositoryId();
    if (repositoryId is null) {
      if (objectType.supportsContainers())
      {
        List!(Repository) repositories = RepositoryService.getListOfRepositories(fileType, accessGroup, startIndex, count);

        foreach (Repository repository ; repositories) {
          String runtimeId = generateRepositoryObjectId(repository.getId());
          Map!(ClassProperties, Object) values = ObjectValuesBuilder.buildObjectValues(repository, runtimeId, getDisplayedContainerId(objectId), objectType, getRepositoryName(repository), rendererProfile, accessGroup);
          objects.add(DirectoryObjectBuilder.createInstance(containerClassType, values, null, repository.getId()));
        }
      }
    }
    else {
      Long folderId = getFolderId();
      int returnedFoldersCount = 0;
      int existingFoldersCount = 0;
      if (objectType.supportsContainers()) {
        existingFoldersCount = FolderService.getNumberOfSubfolders(folderId, repositoryId, accessGroup);
        if (startIndex < existingFoldersCount)
        {
          List!(Folder) folders = FolderService.getListOfSubFolders(folderId, repositoryId, accessGroup, startIndex, count);

          foreach (Folder folder ; folders) {
            String runtimeId = generateFolderObjectId(folder.getId());
            Map!(ClassProperties, Object) values = ObjectValuesBuilder.buildObjectValues(folder, runtimeId, getDisplayedContainerId(objectId), objectType, folder.getName(), rendererProfile, accessGroup);
            objects.add(DirectoryObjectBuilder.createInstance(containerClassType, values, null, folder.getId()));
          }
          returnedFoldersCount = folders.size();
        }
      }
      if ((count > returnedFoldersCount) && (objectType.supportsItems()))
      {
        if (folderId is null)
        {
          folderId = FolderService.retrieveVirtualFolderId(repositoryId);
        }
        if (folderId !is null) {
          int itemStartIndex = startIndex - existingFoldersCount + returnedFoldersCount;
          List/*!(? : MediaItem)*/ items = getItemsForMediaType(folderId, itemStartIndex, count - returnedFoldersCount);

          foreach (MediaItem item ; items) {
            String runtimeId = generateItemObjectId(item.getId());
            Map!(ClassProperties, Object) values = ObjectValuesBuilder.buildObjectValues(item, runtimeId, getDisplayedContainerId(objectId), objectType, getItemTitle(item), rendererProfile, accessGroup);
            List!(Resource) res = ResourceValuesBuilder.buildResources(item, rendererProfile);
            objects.add(DirectoryObjectBuilder.createInstance(itemClassType, values, res, item.getId()));
          }
        }
      }
    }
    return objects;
  }

  protected DirectoryObject retrieveSingleItem()
  {
    Long itemId = getMediaItemId();
    if (itemId !is null)
    {
      MediaItem item = getItem(itemId);
      if (item !is null) {
        Map!(ClassProperties, Object) values = ObjectValuesBuilder.buildObjectValues(item, objectId, getRecursiveParentId(objectId), objectType, getItemTitle(item), rendererProfile, accessGroup);
        List!(Resource) res = ResourceValuesBuilder.buildResources(item, rendererProfile);
        return DirectoryObjectBuilder.createInstance(itemClassType, values, res, itemId);
      }
      throw new ObjectNotFoundException(String.format("MediaItem with id %s not found in CDS", cast(Object[])[ itemId ]));
    }

    Long folderId = getFolderId();
    if (folderId !is null)
    {
      Folder folder = FolderService.getFolder(folderId);
      if (folder !is null) {
        Map!(ClassProperties, Object) values = ObjectValuesBuilder.buildObjectValues(folder, objectId, getRecursiveParentId(objectId), objectType, folder.getName(), rendererProfile, accessGroup);
        return DirectoryObjectBuilder.createInstance(containerClassType, values, null, folderId);
      }
      throw new ObjectNotFoundException(String.format("Folder with id %s not found in CDS", cast(Object[])[ folderId ]));
    }

    Long repositoryId = getRepositoryId();
    Repository repository = RepositoryService.getRepository(repositoryId);
    if (repository !is null) {
      Map!(ClassProperties, Object) values = ObjectValuesBuilder.buildObjectValues(repository, objectId, Definition.instance().getParentNodeId(objectId), objectType, getRepositoryName(repository), rendererProfile, accessGroup);
      return DirectoryObjectBuilder.createInstance(containerClassType, values, null, repositoryId);
    }
    throw new ObjectNotFoundException(String.format("Repository with id %s not found in CDS", cast(Object[])[ objectId ]));
  }

  public int retrieveItemCount()
  {
    Long repositoryId = getRepositoryId();
    if (repositoryId is null) {
      return objectType.supportsContainers() ? RepositoryService.getNumberOfRepositories(fileType, accessGroup) : 0;
    }
    return FolderService.getNumberOfFoldersAndMediaItems(fileType, objectType, accessGroup, getFolderId(), repositoryId);
  }

  private String generateRepositoryObjectId(Number entityId)
  {
    return generateRuntimeObjectId(REPOSITORY_PREFIX + entityId.toString());
  }

  private String generateFolderObjectId(Number entityId) {
    return objectId + "$" + FOLDER_PREFIX + entityId.toString();
  }

  private String generateItemObjectId(Number entityId) {
    return objectId + "$" + ITEM_PREFIX + entityId.toString();
  }

  private Long getFolderId()
  {
    String folderPrefix = "$F";
    if (objectId.indexOf(folderPrefix) > -1) {
      String strippedId = objectId.substring(objectId.lastIndexOf(folderPrefix));
      return Long.valueOf(Long.parseLong(strippedId.substring(folderPrefix.length())));
    }
    return null;
  }

  private Long getMediaItemId()
  {
    String itemPrefix = "$MI";
    if (objectId.indexOf(itemPrefix) > -1) {
      String strippedId = objectId.substring(objectId.lastIndexOf(itemPrefix));
      return Long.valueOf(Long.parseLong(strippedId.substring(itemPrefix.length())));
    }
    return null;
  }

  private Long getRepositoryId()
  {
    if (objectId.indexOf(REPOSITORY_PREFIX) > -1) {
      String strippedId = objectId.substring(objectId.indexOf(REPOSITORY_PREFIX));
      if (strippedId.indexOf("$") > -1) {
        strippedId = strippedId.substring(0, strippedId.indexOf("$"));
      }
      return Long.valueOf(Long.parseLong(strippedId.substring(REPOSITORY_PREFIX.length())));
    }
    return null;
  }

  private String getRecursiveParentId(String objectId)
  {
    return objectId.substring(0, objectId.lastIndexOf("$"));
  }

  private String getRepositoryName(Repository repository)
  {
    File folder = repository.getFolder();
    return ObjectValidator.isNotEmpty(folder.getName()) ? folder.getName() : folder.getPath();
  }

  private List/*!(? : MediaItem)*/ getItemsForMediaType(Long folderId, int startIndex, int count) {
    if (fileType == MediaFileType.AUDIO)
      return AudioService.getListOfSongsForFolder(folderId, accessGroup, startIndex, count);
    if (fileType == MediaFileType.IMAGE)
      return ImageService.getListOfImagesForFolder(folderId, accessGroup, startIndex, count);
    if (fileType == MediaFileType.VIDEO) {
      return VideoService.getListOfVideosForFolder(folderId, accessGroup, startIndex, count);
    }
    return Collections.emptyList();
  }

  private MediaItem getItem(Long itemId)
  {
    if (fileType == MediaFileType.AUDIO)
      return AudioService.getSong(itemId);
    if (fileType == MediaFileType.IMAGE)
      return ImageService.getImage(itemId);
    if (fileType == MediaFileType.VIDEO) {
      return VideoService.getVideo(itemId);
    }
    return null;
  }

  private String getItemTitle(MediaItem item)
  {
    return item.getFileName();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.AbstractListObjectsByFSHierarchyCommand
 * JD-Core Version:    0.6.2
 */