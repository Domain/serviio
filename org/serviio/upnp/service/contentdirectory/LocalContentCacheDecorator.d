module org.serviio.upnp.service.contentdirectory.LocalContentCacheDecorator;

import org.apache.jcs.access.exception.CacheException;
import org.serviio.cache.AbstractCacheDecorator;
import org.serviio.library.entities.AccessGroup;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObject;

public class LocalContentCacheDecorator : AbstractCacheDecorator
  , CDSCacheDecorator
{
  public this(String regionName)
  {
    super(regionName);
  }

  public BrowseItemsHolder!(DirectoryObject) retrieve(String objectID, ObjectType objectType, String browseFlag, String filter, int startingIndex, int requestedCount, String sortCriteria, Profile rendererProfile, AccessGroup accessGroup)
  {
    
	BrowseItemsHolder!(DirectoryObject) object = cast(BrowseItemsHolder!(DirectoryObject))cache.get(generateKey(objectID, objectType, browseFlag, filter, startingIndex, requestedCount, sortCriteria, rendererProfile, accessGroup));

    if (object !is null) {
      log.debug_(String.format("Found entry in the cache (%s), returning it", cast(Object[])[ regionName ]));
    }
    return object;
  }

  public void store(BrowseItemsHolder!(DirectoryObject) object, String objectID, ObjectType objectType, String browseFlag, String filter, int startingIndex, int requestedCount, String sortCriteria, Profile rendererProfile, AccessGroup accessGroup)
  {
    try
    {
      cache.put(generateKey(objectID, objectType, browseFlag, filter, startingIndex, requestedCount, sortCriteria, rendererProfile, accessGroup), object);

      log.debug_(String.format("Stored entry in the cache (%s), returning it", cast(Object[])[ regionName ]));
    } catch (CacheException e) {
      log.warn(String.format("Could not store object to local cache(%s): %s", cast(Object[])[ regionName, e.getMessage() ]));
    }
  }

  private String generateKey(String containerID, ObjectType objectType, String browseFlag, String filter, int startingIndex, int requestedCount, String sortCriteria, Profile rendererProfile, AccessGroup accessGroup)
  {
    StringBuffer sb = new StringBuffer();
    sb.append(containerID).append(":").append(browseFlag).append(":").append(objectType.toString()).append(":").append(filter).append(":").append(startingIndex).append(":").append(requestedCount).append(":").append(sortCriteria).append(":").append(rendererProfile.getId()).append(":").append(accessGroup.getId() !is null ? accessGroup.getId() : "any");

    return sb.toString();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.LocalContentCacheDecorator
 * JD-Core Version:    0.6.2
 */