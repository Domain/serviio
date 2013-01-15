module org.serviio.upnp.service.contentdirectory.command.AbstractListOnlineObjectsByHierarchyCommand;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.library.online.OnlineItemService;
import org.serviio.library.online.metadata.NamedOnlineResource;
import org.serviio.library.online.metadata.OnlineItem;
import org.serviio.library.online.metadata.OnlineResourceContainer;
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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class AbstractListOnlineObjectsByHierarchyCommand : AbstractCommand!(DirectoryObject)
{
  private static final Logger log = LoggerFactory.getLogger!(AbstractListOnlineObjectsByHierarchyCommand)();
  private static final String FOLDER_PREFIX = "FD";
  private static final String ITEM_PREFIX = "OI";
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
    Long folderId = getFolderId();
    int returnedFoldersCount = 0;
    int existingFoldersCount = 0;

    if (objectType.supportsContainers()) {
      existingFoldersCount = folderId is null ? OnlineItemService.getCountOfParsedFeeds(fileType, accessGroup, true) : 0;
      if (startIndex < existingFoldersCount)
      {
        List!(NamedOnlineResource!(OnlineResourceContainer!(Object, Object))) resources = OnlineItemService.getListOfParsedContainerResources(fileType, accessGroup, startIndex, count, true);

        foreach (NamedOnlineResource!(OnlineResourceContainer!(Object, Object)) folder ; resources) {
          OnlineResourceContainer!(Object, Object) resource = cast(OnlineResourceContainer!(Object, Object))folder.getOnlineItem();
          String runtimeId = generateFolderObjectId(resource.getOnlineRepositoryId());
          Map!(ClassProperties, Object) values = ObjectValuesBuilder.buildObjectValues(resource.toOnlineRepository(), runtimeId, getDisplayedContainerId(objectId), objectType, getFolderName(resource, folder.getRepositoryName()), rendererProfile, accessGroup);

          objects.add(DirectoryObjectBuilder.createInstance(containerClassType, values, null, resource.getOnlineRepositoryId()));
        }
        returnedFoldersCount = resources.size();
      }
    }
    if ((count > returnedFoldersCount) && (objectType.supportsItems()))
    {
      int itemStartIndex = startIndex - existingFoldersCount + returnedFoldersCount;
      List!(NamedOnlineResource!(OnlineItem)) items = getItemsForMediaType(folderId, itemStartIndex, count - returnedFoldersCount);

      foreach (NamedOnlineResource!(OnlineItem) namedItem ; items) {
        OnlineItem item = cast(OnlineItem)namedItem.getOnlineItem();
        String runtimeId = generateItemObjectId(item.getId());
        MediaItem mediaItem = item.toMediaItem();
        Map!(ClassProperties, Object) values = ObjectValuesBuilder.buildObjectValues(mediaItem, runtimeId, getDisplayedContainerId(objectId), objectType, getItemTitle(item, namedItem.getRepositoryName()), rendererProfile, accessGroup);

        List!(Resource) res = ResourceValuesBuilder.buildResources(mediaItem, rendererProfile);
        objects.add(DirectoryObjectBuilder.createInstance(itemClassType, values, res, item.getId()));
      }
    }
    return objects;
  }

  protected DirectoryObject retrieveSingleItem()
  {
    Long itemId = getMediaItemId();
    if (itemId !is null)
    {
      NamedOnlineResource!(Object) namedItem = getItem(itemId);
      if (namedItem !is null) {
        OnlineItem item = cast(OnlineItem)namedItem.getOnlineItem();
        MediaItem mediaItem = item.toMediaItem();
        Map!(ClassProperties, Object) values = ObjectValuesBuilder.buildObjectValues(mediaItem, objectId, getRecursiveParentId(objectId), objectType, getItemTitle(item, namedItem.getRepositoryName()), rendererProfile, accessGroup);

        List!(Resource) res = ResourceValuesBuilder.buildResources(mediaItem, rendererProfile);
        return DirectoryObjectBuilder.createInstance(itemClassType, values, res, itemId);
      }
      throw new ObjectNotFoundException(String.format("OnlineItem with id %s not found in CDS", cast(Object[])[ itemId ]));
    }

    Long folderId = getFolderId();
    if (folderId !is null)
    {
      NamedOnlineResource!(Object) resource = OnlineItemService.findNamedContainerResourceById(folderId);
      if (resource !is null) {
        OnlineResourceContainer!(Object, Object) feed = cast(OnlineResourceContainer!(Object, Object))resource.getOnlineItem();
        Map!(ClassProperties, Object) values = ObjectValuesBuilder.buildObjectValues(feed.toOnlineRepository(), objectId, Definition.instance().getParentNodeId(objectId), objectType, getFolderName(feed, resource.getRepositoryName()), rendererProfile, accessGroup);

        return DirectoryObjectBuilder.createInstance(containerClassType, values, null, folderId);
      }
      throw new ObjectNotFoundException(String.format("Folder with id %s not found in CDS", cast(Object[])[ folderId ]));
    }

    throw new ObjectNotFoundException(String.format("Error retrieving object %s from CDS", cast(Object[])[ objectId ]));
  }

  public int retrieveItemCount()
  {
    return OnlineItemService.getCountOfOnlineItemsAndRepositories(fileType, objectType, getFolderId(), accessGroup, true);
  }

  private String generateFolderObjectId(Number entityId)
  {
    return generateRuntimeObjectId(FOLDER_PREFIX + entityId.toString());
  }

  private String generateItemObjectId(Number entityId) {
    if (objectId.indexOf("^") == -1)
    {
      return generateRuntimeObjectId("$OI" ~ entityId.toString());
    }
    return objectId + "$" + ITEM_PREFIX + entityId.toString();
  }

  private Long getFolderId()
  {
    if (objectId.indexOf(FOLDER_PREFIX) > -1) {
      String strippedId = objectId.substring(objectId.indexOf(FOLDER_PREFIX));
      if (strippedId.indexOf("$") > -1) {
        strippedId = strippedId.substring(0, strippedId.indexOf("$"));
      }
      return Long.valueOf(Long.parseLong(strippedId.substring(FOLDER_PREFIX.length())));
    }
    return null;
  }

  private Long getMediaItemId()
  {
    String itemPrefix = "$OI";
    if (objectId.indexOf(itemPrefix) > -1) {
      String strippedId = objectId.substring(objectId.lastIndexOf(itemPrefix));
      return Long.valueOf(Long.parseLong(strippedId.substring(itemPrefix.length())));
    }
    return null;
  }

  private String getRecursiveParentId(String objectId)
  {
    return objectId.substring(0, objectId.lastIndexOf("$"));
  }

  private String getFolderName(OnlineResourceContainer!(Object, Object) resource, String repositoryName) {
    if (ObjectValidator.isNotEmpty(repositoryName)) {
      return repositoryName;
    }
    if (ObjectValidator.isNotEmpty(resource.getDomain())) {
      return String.format("%s [%s]", cast(Object[])[ resource.getTitle(), resource.getDomain() ]);
    }
    return resource.getTitle();
  }

  private String getItemTitle(OnlineItem item, String repositoryName)
  {
    if (ObjectValidator.isNotEmpty(repositoryName)) {
      return repositoryName;
    }
    return item.getTitle();
  }

  private List!(NamedOnlineResource!(OnlineItem)) getItemsForMediaType(Long folderId, int startIndex, int count)
  {
    if (folderId is null) {
      return OnlineItemService.getListOfSingleURLItems(fileType, accessGroup, startIndex, count, true);
    }
    OnlineResourceContainer!(Object, Object) cachedContainerResource = OnlineItemService.findContainerResourceById(folderId);
    return OnlineItemService.getListOfFeedItems(cachedContainerResource, fileType, startIndex, count);
  }

  private NamedOnlineResource!(OnlineItem) getItem(Long itemId)
  {
    try {
      return OnlineItemService.findNamedOnlineItemById(itemId);
    } catch (IOException e) {
      log.debug_(String.format("Error retrieving online item %s: %s", cast(Object[])[ itemId, e.getMessage() ]), e);
    }return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.AbstractListOnlineObjectsByHierarchyCommand
 * JD-Core Version:    0.6.2
 */