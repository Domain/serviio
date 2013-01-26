module org.serviio.library.online.OnlineItemService;

import java.lang.Long;
import java.lang.String;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.CoverImage;
import org.serviio.library.entities.OnlineRepository;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.library.online.metadata.NamedOnlineResource;
import org.serviio.library.online.metadata.OnlineItem;
import org.serviio.library.online.metadata.OnlineResourceContainer;
import org.serviio.library.online.metadata.SingleURLItem;
import org.serviio.library.online.service.OnlineRepositoryService;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.util.CollectionUtils;
import org.serviio.library.online.OnlineLibraryManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class OnlineItemService
{
    private static OnlineLibraryManager onlineLibraryManager;

    private static immutable Logger log;

    static this()
    {
        onlineLibraryManager = OnlineLibraryManager.getInstance();
        log = LoggerFactory.getLogger!(OnlineItemService)();
    }

    public static OnlineResourceContainer!(Object, Object) findContainerResourceById(Long onlineRepositoryId)
    {
        NamedOnlineResource!(OnlineResourceContainer!(Object, Object)) resource = findNamedContainerResourceById(onlineRepositoryId);
        if (resource !is null) {
            return cast(OnlineResourceContainer!(Object, Object))resource.getOnlineItem();
        }
        return null;
    }

    public static NamedOnlineResource!(OnlineResourceContainer!(Object, Object)) findNamedContainerResourceById(Long onlineRepositoryId)
    {
        OnlineRepository onlineRepository = OnlineRepositoryService.getRepository(onlineRepositoryId);
        try {
            OnlineResourceContainer!(Object, Object) resource = findContainerResourceById(onlineRepository);
            if (resource !is null) {
                return new NamedOnlineResource!(OnlineResourceContainer!(Object, Object))(resource, onlineRepository.getRepositoryName());
            }
            return null;
        } catch (IOException e) {
            log.warn(String.format("Unexpected error retrieving resource %s: %s", cast(Object[])[ onlineRepositoryId, e.getMessage() ]));
        }return null;
    }

    public static SingleURLItem findSingleURLItemById(Long onlineRepositoryId)
    {
        OnlineRepository onlineRepository = OnlineRepositoryService.getRepository(onlineRepositoryId);
        return onlineLibraryManager.findSingleURLItemInCacheOrParse(onlineRepository);
    }

    public static OnlineItem findOnlineItemById(Long onlineItemId)
    {
        NamedOnlineResource!(Object) namedItem = findNamedOnlineItemById(onlineItemId);
        if (namedItem !is null) {
            return cast(OnlineItem)namedItem.getOnlineItem();
        }
        return null;
    }

    public static NamedOnlineResource!(OnlineItem) findNamedOnlineItemById(Long onlineItemId) 
    {
        OnlineItemId itemId = OnlineItemId.parse(onlineItemId);
        OnlineRepository onlineRepository = OnlineRepositoryService.getRepository(Long.valueOf(itemId.getRepositoryId()));
        if (onlineRepository !is null) {
            if (getContainerResourceTypes().contains(onlineRepository.getRepoType())) {
                OnlineResourceContainer!(Object, Object) resource = findContainerResourceById(Long.valueOf(itemId.getRepositoryId()));
                if (resource !is null)
                    try {
                        OnlineItem resourceItem = cast(OnlineItem)resource.getItems().get(itemId.getSequence() - 1);
                        if (resourceItem !is null) {
                            return new NamedOnlineResource!(OnlineItem)(resourceItem, resourceItem.getTitle());
                        }
                        return null;
                    }
                catch (IndexOutOfBoundsException e) {
                    return null;
                }
            }
            else {
                SingleURLItem item = OnlineLibraryManager.getInstance().findSingleURLItemInCacheOrParse(onlineRepository);
                if (item !is null) {
                    return new NamedOnlineResource!(OnlineItem)(item, onlineRepository.getRepositoryName());
                }
                return null;
            }
        }
        else log.warn("Cannot find online repository with id " + itemId.getRepositoryId());

        return null;
    }

    public static CoverImage findThumbnail(Long onlineItemId)
    {
        OnlineItem onlineItem = findOnlineItemById(onlineItemId);
        if (onlineItem !is null) {
            try {
                CoverImage thumbnail = onlineLibraryManager.findThumbnail(onlineItem.getThumbnail());
                thumbnail.setId(onlineItemId);
                return thumbnail;
            } catch (CannotRetrieveThumbnailException e) {
                log.warn(e.getMessage(), e);
                return null;
            }
        }
        return null;
    }

    public static List!(NamedOnlineResource!(OnlineItem)) getListOfFeedItems(OnlineResourceContainer!(Object, Object) resource, MediaFileType itemType, int start, int count)
    {
        List!(Object) resourceItems = filterContainerResourceItems(resource.getItems(), itemType);
        if (resourceItems.size() >= start) {

            List!(OnlineItem) requestedItems = cast(List!(OnlineItem)) CollectionUtils.getSubList(resourceItems, start, count);
            List!(NamedOnlineResource!(OnlineItem)) result = new ArrayList!(NamedOnlineResource!(OnlineItem))();
            foreach (OnlineItem item ; requestedItems) {
                result.add(new NamedOnlineResource!(OnlineItem)(item, item.getTitle()));
            }
            return result;
        }
        return Collections.emptyList();
    }

    public static void removeOnlineContentFromCache(String repoUrl)
    {
        OnlineLibraryManager.getInstance().removeOnlineContentFromCache(repoUrl);
    }

    public static List!(NamedOnlineResource!(OnlineResourceContainer!(Object, Object))) getListOfParsedContainerResources(MediaFileType itemType, AccessGroup accessGroup, int start, int count, bool onlyEnabled) 
    {
        List!(NamedOnlineResource!(OnlineResourceContainer!(Object, Object))) result = getAllParsedContainerResources(itemType, accessGroup, onlyEnabled);
        return CollectionUtils.getSubList(result, start, count);
    }

    public static int getCountOfParsedFeeds(MediaFileType itemType, AccessGroup accessGroup, bool onlyEnabled) 
    {
        return getAllParsedContainerResources(itemType, accessGroup, onlyEnabled).size();
    }

    public static int getCountOfOnlineItemsAndRepositories(MediaFileType itemType, ObjectType objectType, Long onlineRepositoryId, AccessGroup accessGroup, bool onlyEnabled)
    {
        if (onlineRepositoryId is null)
        {
            int count = 0;
            if (objectType.supportsContainers()) {
                count += getCountOfParsedFeeds(itemType, accessGroup, onlyEnabled);
            }
            if (objectType.supportsItems()) {
                count += getCountOfSingleURLItems(itemType, accessGroup, onlyEnabled);
            }
            return count;
        }

        if (objectType.supportsItems()) {
            OnlineResourceContainer!(Object, Object) resource = findContainerResourceById(onlineRepositoryId);
            return getCountOfContainerItems(resource, itemType);
        }
        return 0;
    }

    public static List!(NamedOnlineResource!(OnlineItem)) getListOfSingleURLItems(MediaFileType itemType, AccessGroup accessGroup, int start, int count, bool onlyEnabled)
    {
        List!(OnlineRepository) repositories = OnlineRepositoryService.getListOfRepositories(getSingleUrlRepositoryTypes(), itemType, accessGroup, onlyEnabled);
        List!(NamedOnlineResource!(OnlineItem)) onlineItems = new ArrayList!(NamedOnlineResource!(OnlineItem))();
        foreach (OnlineRepository repo ; repositories) {
            SingleURLItem item = onlineLibraryManager.findSingleURLItemInCacheOrParse(repo);
            if (item !is null) {
                SingleURLItem filteredItem = cast(SingleURLItem)filterFeedItem(item, itemType);
                if (filteredItem !is null) {
                    onlineItems.add(new NamedOnlineResource!(OnlineItem)(filteredItem, repo.getRepositoryName()));
                }
            }
        }
        if (onlineItems.size() >= start) {
            List!(NamedOnlineResource!(OnlineItem)) requestedItems = CollectionUtils.getSubList(onlineItems, start, count);
            return requestedItems;
        }
        return Collections.emptyList();
    }

    public static int getCountOfSingleURLItems(MediaFileType itemType, AccessGroup accessGroup, bool onlyEnabled)
    {
        List!(OnlineRepository) repositories = OnlineRepositoryService.getListOfRepositories(getSingleUrlRepositoryTypes(), itemType, accessGroup, onlyEnabled);
        List!(SingleURLItem) onlineItems = convertOnlineRepositories(repositories);
        return filterContainerResourceItems(onlineItems, itemType).size();
    }

    private static int getCountOfContainerItems(OnlineResourceContainer!(Object, Object) resource, MediaFileType itemType)
    {
        List!(Object) items = filterContainerResourceItems(resource.getItems(), itemType);
        return items.size();
    }

    private static List!(NamedOnlineResource!(OnlineResourceContainer!(Object, Object))) getAllParsedContainerResources(MediaFileType itemType, AccessGroup accessGroup, bool onlyEnabled) 
    {
        List!(OnlineRepository) allRepositories = OnlineRepositoryService.getListOfRepositories(getContainerResourceTypes(), itemType, accessGroup, onlyEnabled);
        List!(NamedOnlineResource!(OnlineResourceContainer!(Object, Object))) result = new ArrayList!(NamedOnlineResource!(OnlineResourceContainer!(Object, Object)))();
        foreach (OnlineRepository repo ; allRepositories)
            try {
                OnlineResourceContainer!(Object, Object) parsedResource = onlineLibraryManager.findResource(repo, true);
                if (parsedResource !is null)
                    result.add(new NamedOnlineResource!(OnlineResourceContainer!(Object, Object))(parsedResource, repo.getRepositoryName()));
            }
        catch (IOException e)
        {
        }
        return result;
    }

    private static OnlineResourceContainer!(Object, Object) findContainerResourceById(OnlineRepository onlineRepository)
    {
        if (onlineRepository !is null) {
            return onlineLibraryManager.findResource(onlineRepository, true);
        }
        return null;
    }

    private static List!(T) filterContainerResourceItems(T : OnlineItem)(List!(T) items, MediaFileType type)
    {
        List!(T) filteredItems = new ArrayList!(T)();
        foreach (OnlineItem feedItem ; items) {

            T filteredItem = cast(T) filterFeedItem(feedItem, type);
            if (filteredItem !is null) {
                filteredItems.add(filteredItem);
            }
        }
        return filteredItems;
    }

    private static T filterFeedItem(T : OnlineItem)(T item, MediaFileType type)
    {
        if ((item.getType() == type) && (item.isCompletelyLoaded())) {
            return item;
        }
        return null;
    }

    private static List!(SingleURLItem) convertOnlineRepositories(List!(OnlineRepository) repositories)
    {
        List!(SingleURLItem) onlineItems = new ArrayList!(SingleURLItem)();
        foreach (OnlineRepository repo ; repositories) {
            SingleURLItem item = onlineLibraryManager.findSingleURLItemInCacheOrParse(repo);
            if (item !is null) {
                onlineItems.add(item);
            }
        }
        return onlineItems;
    }

    private static List!(OnlineRepository.OnlineRepositoryType) getSingleUrlRepositoryTypes() 
    {
        return Collections.singletonList(OnlineRepository.OnlineRepositoryType.LIVE_STREAM);
    }

    private static List!(OnlineRepository.OnlineRepositoryType) getContainerResourceTypes() 
    {
        return Arrays.asList(cast(OnlineRepository.OnlineRepositoryType[])[ OnlineRepository.OnlineRepositoryType.FEED, OnlineRepository.OnlineRepositoryType.WEB_RESOURCE ]);
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.online.OnlineItemService
* JD-Core Version:    0.6.2
*/