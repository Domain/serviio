module org.serviio.ui.representation.RepositoryRepresentation;

import java.util.List;
import org.serviio.library.online.PreferredQuality;

public class RepositoryRepresentation
{
  private List!(SharedFolder) sharedFolders;
  private Boolean searchHiddenFiles;
  private Boolean searchForUpdates;
  private Boolean automaticLibraryUpdate;
  private Integer automaticLibraryUpdateInterval;
  private List!(OnlineRepository) onlineRepositories;
  private Integer maxNumberOfItemsForOnlineFeeds;
  private Integer onlineFeedExpiryInterval;
  private PreferredQuality onlineContentPreferredQuality;

  public List!(SharedFolder) getSharedFolders()
  {
    return sharedFolders;
  }

  public void setSharedFolders(List!(SharedFolder) repositories) {
    sharedFolders = repositories;
  }

  public Boolean isSearchHiddenFiles() {
    return searchHiddenFiles;
  }

  public void setSearchHiddenFiles(Boolean searchHiddenFiles) {
    this.searchHiddenFiles = searchHiddenFiles;
  }

  public Boolean isAutomaticLibraryUpdate() {
    return automaticLibraryUpdate;
  }

  public void setAutomaticLibraryUpdate(Boolean automaticLibraryUpdate) {
    this.automaticLibraryUpdate = automaticLibraryUpdate;
  }

  public Integer getAutomaticLibraryUpdateInterval() {
    return automaticLibraryUpdateInterval;
  }

  public void setAutomaticLibraryUpdateInterval(Integer automaticLibraryUpdateInterval) {
    this.automaticLibraryUpdateInterval = automaticLibraryUpdateInterval;
  }

  public Boolean isSearchForUpdates() {
    return searchForUpdates;
  }

  public void setSearchForUpdates(Boolean searchForUpdates) {
    this.searchForUpdates = searchForUpdates;
  }

  public List!(OnlineRepository) getOnlineRepositories() {
    return onlineRepositories;
  }

  public void setOnlineRepositories(List!(OnlineRepository) onlineRepositories) {
    this.onlineRepositories = onlineRepositories;
  }

  public Integer getMaxNumberOfItemsForOnlineFeeds() {
    return maxNumberOfItemsForOnlineFeeds;
  }

  public void setMaxNumberOfItemsForOnlineFeeds(Integer maxNumberOfItemsForOnlineFeeds) {
    this.maxNumberOfItemsForOnlineFeeds = maxNumberOfItemsForOnlineFeeds;
  }

  public Integer getOnlineFeedExpiryInterval() {
    return onlineFeedExpiryInterval;
  }

  public void setOnlineFeedExpiryInterval(Integer onlineFeedExpiryInterval) {
    this.onlineFeedExpiryInterval = onlineFeedExpiryInterval;
  }

  public PreferredQuality getOnlineContentPreferredQuality() {
    return onlineContentPreferredQuality;
  }

  public void setOnlineContentPreferredQuality(PreferredQuality onlineContentPreferredQuality) {
    this.onlineContentPreferredQuality = onlineContentPreferredQuality;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.representation.RepositoryRepresentation
 * JD-Core Version:    0.6.2
 */