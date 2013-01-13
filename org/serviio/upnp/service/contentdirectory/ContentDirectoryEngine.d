module org.serviio.upnp.service.contentdirectory.ContentDirectoryEngine;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Map : Entry;
import org.serviio.library.entities.AccessGroup;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObject;
import org.serviio.upnp.service.contentdirectory.definition.ContainerNode;
import org.serviio.upnp.service.contentdirectory.definition.Definition;

public class ContentDirectoryEngine
{
  private static final String CACHE_REGION_LOCAL_DEFAULT = "local_default";
  private static final String CACHE_REGION_LOCAL_RESET_AFTER_PLAY = "local_resetafterplay";
  private static final String CACHE_REGION_NO_CACHE = "no_cache";
  private static final String BROWSE_FLAG_BrowseMetadata = "BrowseMetadata";
  private static final String BROWSE_FLAG_BrowseDirectChildren = "BrowseDirectChildren";
  private static ContentDirectoryEngine instance;
  private Map!(String, CDSCacheDecorator) cacheRegions;

  private this()
  {
    setupCache();
  }

  public static ContentDirectoryEngine getInstance()
  {
    if (instance is null) {
      instance = new ContentDirectoryEngine();
    }
    return instance;
  }

  public BrowseItemsHolder!(DirectoryObject) browse(String objectID, ObjectType objectType, String browseFlag, String filter, int startingIndex, int requestedCount, String sortCriteria, Profile rendererProfile, AccessGroup accessGroup)
  {
    if ((!browseFlag.equals(BROWSE_FLAG_BrowseMetadata)) && (!browseFlag.equals(BROWSE_FLAG_BrowseDirectChildren))) {
      throw new InvalidBrowseFlagException(String.format("Unsupported browse flag: %s", cast(Object[])[ browseFlag ]));
    }
    if (rendererProfile.getContentDirectoryDefinitionFilter() !is null)
    {
      objectID = rendererProfile.getContentDirectoryDefinitionFilter().filterObjectId(objectID, false);
    }
    ContainerNode container = Definition.instance().getContainer(objectID);
    if (container is null) {
      throw new ObjectNotFoundException();
    }

    BrowseItemsHolder!(DirectoryObject) itemsHolder = getCacheRegion(container.getCacheRegion()).retrieve(objectID, objectType, browseFlag, filter, startingIndex, requestedCount, sortCriteria, rendererProfile, accessGroup);

    if (itemsHolder is null) {
      bool storeInCache = true;

      itemsHolder = new BrowseItemsHolder!(DirectoryObject)();
      if (browseFlag.equals(BROWSE_FLAG_BrowseDirectChildren))
      {
        itemsHolder = container.retrieveContainerItems(objectID, objectType, startingIndex, requestedCount, rendererProfile, accessGroup);
      }
      else {
        DirectoryObject object = container.retrieveDirectoryObject(objectID, objectType, rendererProfile, accessGroup);
        if (object !is null) {
          itemsHolder.setTotalMatched(1);
          itemsHolder.setItems(Collections.singletonList(object));
        }
        else {
          storeInCache = false;
        }
      }
      if (storeInCache)
      {
        getCacheRegion(container.getCacheRegion()).store(itemsHolder, objectID, objectType, browseFlag, filter, startingIndex, requestedCount, sortCriteria, rendererProfile, accessGroup);
      }
    }

    return itemsHolder;
  }

  public void evictItemsAfterPlay()
  {
    (cast(CDSCacheDecorator)cacheRegions.get(CACHE_REGION_LOCAL_RESET_AFTER_PLAY)).evictAll();
  }

  void clearAllCacheRegions()
  {
    foreach (Entry!(String, CDSCacheDecorator) entry ; cacheRegions.entrySet())
      (cast(CDSCacheDecorator)entry.getValue()).evictAll();
  }

  private void setupCache()
  {
    cacheRegions = new HashMap!(String, CDSCacheDecorator)();
    cacheRegions.put(CACHE_REGION_LOCAL_DEFAULT, new LocalContentCacheDecorator(CACHE_REGION_LOCAL_DEFAULT));
    cacheRegions.put(CACHE_REGION_LOCAL_RESET_AFTER_PLAY, new LocalContentCacheDecorator(CACHE_REGION_LOCAL_RESET_AFTER_PLAY));
    cacheRegions.put(CACHE_REGION_NO_CACHE, new NoCacheDecorator());
  }

  private CDSCacheDecorator getCacheRegion(String regionName) {
    return cast(CDSCacheDecorator)cacheRegions.get(regionName);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.ContentDirectoryEngine
 * JD-Core Version:    0.6.2
 */