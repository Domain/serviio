module org.serviio.upnp.service.contentdirectory.NoCacheDecorator;

import org.serviio.library.entities.AccessGroup;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObject;

public class NoCacheDecorator
  : CDSCacheDecorator
{
  public void evictAll()
  {
  }

  public BrowseItemsHolder!(DirectoryObject) retrieve(String objectID, ObjectType objectType, String browseFlag, String filter, int startingIndex, int requestedCount, String sortCriteria, Profile rendererProfile, AccessGroup accessGroup)
  {
    return null;
  }

  public void store(BrowseItemsHolder!(DirectoryObject) object, String objectID, ObjectType objectType, String browseFlag, String filter, int startingIndex, int requestedCount, String sortCriteria, Profile rendererProfile, AccessGroup accessGroup)
  {
  }

  public void shutdown()
  {
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.NoCacheDecorator
 * JD-Core Version:    0.6.2
 */