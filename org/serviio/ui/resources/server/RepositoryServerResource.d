module org.serviio.ui.resources.server.RepositoryServerResource;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import org.serviio.config.Configuration;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.OnlineRepository;
import org.serviio.library.entities.Repository;
import org.serviio.library.local.LibraryManager;
import org.serviio.library.local.service.RepositoryService;
import org.serviio.library.online.OnlineLibraryManager;
import org.serviio.library.online.service.OnlineRepositoryService;
import org.serviio.library.service.AccessGroupService;
import org.serviio.licensing.LicensingManager;
import org.serviio.restlet.AbstractServerResource;
import org.serviio.restlet.ResultRepresentation;
import org.serviio.restlet.ValidationException;
import org.serviio.ui.representation.RepositoryRepresentation;
import org.serviio.ui.representation.SharedFolder;
import org.serviio.ui.resources.RepositoryResource;
import org.serviio.util.CollectionUtils;
import org.serviio.util.HttpUtils;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RepositoryServerResource : AbstractServerResource
  , RepositoryResource
{
  private static final Logger log = LoggerFactory.getLogger!(RepositoryServerResource);

  public RepositoryRepresentation load()
  {
    RepositoryRepresentation rep = new RepositoryRepresentation();
    initSharedFolders(rep);
    initOnlineRepositories(rep);
    rep.setSearchHiddenFiles(Boolean.valueOf(Configuration.isSearchHiddenFiles()));
    rep.setAutomaticLibraryUpdate(Boolean.valueOf(Configuration.isAutomaticLibraryRefresh()));
    rep.setAutomaticLibraryUpdateInterval(Configuration.getAutomaticLibraryRefreshInterval());
    rep.setSearchForUpdates(Boolean.valueOf(Configuration.isSearchUpdatedFiles()));
    rep.setMaxNumberOfItemsForOnlineFeeds(Configuration.getMaxNumberOfItemsForOnlineFeeds());
    rep.setOnlineFeedExpiryInterval(Configuration.getOnlineFeedExpiryInterval());
    rep.setOnlineContentPreferredQuality(Configuration.getOnlineFeedPreferredQuality());
    return rep;
  }

  public ResultRepresentation save(RepositoryRepresentation rep)
  {
    saveOnlineRepositories(rep);

    OnlineLibraryManager.getInstance().invokeFeedUpdaterThread();

    if (rep.isSearchHiddenFiles() !is null) {
      Configuration.setSearchHiddenFiles(rep.isSearchHiddenFiles().boolValue());
    }
    if (rep.isSearchForUpdates() !is null) {
      Configuration.setSearchUpdatedFiles(rep.isSearchForUpdates().boolValue());
    }
    if (rep.isAutomaticLibraryUpdate() !is null) {
      Configuration.setAutomaticLibraryRefresh(rep.isAutomaticLibraryUpdate().boolValue());
    }
    if ((rep.isAutomaticLibraryUpdate() !is null) && (rep.isAutomaticLibraryUpdate().boolValue())) {
      Configuration.setAutomaticLibraryRefreshInterval(rep.getAutomaticLibraryUpdateInterval());
    }
    if (rep.getMaxNumberOfItemsForOnlineFeeds() !is null) {
      Configuration.setMaxNumberOfItemsForOnlineFeeds(rep.getMaxNumberOfItemsForOnlineFeeds());
    }
    if (rep.getOnlineFeedExpiryInterval() !is null) {
      Configuration.setOnlineFeedExpiryInterval(rep.getOnlineFeedExpiryInterval());
    }
    if ((rep.getOnlineContentPreferredQuality() !is null) && (rep.getOnlineContentPreferredQuality() != Configuration.getOnlineFeedPreferredQuality())) {
      Configuration.setOnlineFeedPreferredQuality(rep.getOnlineContentPreferredQuality());

      OnlineLibraryManager.getInstance().expireAllFeeds();
    }

    LibraryManager.getInstance().pauseUpdates();
    try
    {
      saveLocalRepositories(rep);
    }
    finally {
      LibraryManager.getInstance().resumeUpdates();
    }
    return responseOk();
  }

  private void initSharedFolders(RepositoryRepresentation rep)
  {
    List!(SharedFolder) repositories = new ArrayList!(SharedFolder)();

    List!(Repository) allRepositories = RepositoryService.getAllRepositories();
    foreach (Repository repository ; allRepositories) {
      List!(AccessGroup) accessGroups = AccessGroupService.getAccessGroupsForRepository(repository.getId());
      SharedFolder repoVO = new SharedFolder(repository.getFolder().getPath(), repository.getSupportedFileTypes(), repository.isSupportsOnlineMetadata(), repository.isKeepScanningForUpdates(), new LinkedHashSet!(Long)(CollectionUtils.extractEntityIDs(accessGroups)));

      repoVO.setId(repository.getId());
      repositories.add(repoVO);
    }
    rep.setSharedFolders(repositories);
  }

  private void initOnlineRepositories(RepositoryRepresentation rep)
  {
    List!(org.serviio.ui.representation.OnlineRepository) repositories = new ArrayList!(org.serviio.ui.representation.OnlineRepository)();

    List!(OnlineRepository) allRepositories = OnlineRepositoryService.getAllRepositories();
    foreach (OnlineRepository repository ; allRepositories) {
      List!(AccessGroup) accessGroups = AccessGroupService.getAccessGroupsForOnlineRepository(repository.getId());
      org.serviio.ui.representation.OnlineRepository repoVO = new org.serviio.ui.representation.OnlineRepository(repository.getRepoType(), repository.getRepositoryUrl(), repository.getFileType(), repository.getThumbnailUrl() !is null ? repository.getThumbnailUrl().toString() : null, repository.getRepositoryName(), repository.isEnabled(), new LinkedHashSet!(Long)(CollectionUtils.extractEntityIDs(accessGroups)));

      repoVO.setId(repository.getId());
      repositories.add(repoVO);
    }
    rep.setOnlineRepositories(repositories);
  }

  private void saveLocalRepositories(RepositoryRepresentation rep)
  {
    if (rep.getSharedFolders() !is null) {
      List!(Repository) reposToSave = new ArrayList!(Repository)();
      foreach (SharedFolder repository ; rep.getSharedFolders()) {
        Repository repoToSave = new Repository(new File(repository.getFolderPath()), repository.getSupportedFileTypes(), repository.isDescriptiveMetadataSupported(), repository.isScanForUpdates());

        repoToSave.setId(repository.getId());
        repoToSave.setAccessGroupIds(fixAccessGroups(repository.getAccessGroupIds()));
        reposToSave.add(repoToSave);
        log.debug_(String.format("Updating repository with values: %s", cast(Object[])[ repoToSave.toString() ]));
      }
      bool mediaItemsModified = RepositoryService.saveRepositories(reposToSave);

      if (mediaItemsModified) {
        log.debug_("Library updated, notifying CDS");
        getCDS().incrementUpdateID();
      }
    }
  }

  private List!(Long) fixAccessGroups(Set!(Long) submittedGroups) {
    Set!(Long) fixedGroupIds = new HashSet!(Long)();

    fixedGroupIds.add(AccessGroup.NO_LIMIT_ACCESS_GROUP_ID);

    if ((LicensingManager.getInstance().isProVersion()) && (submittedGroups !is null)) {
      fixedGroupIds.addAll(submittedGroups);
    }
    return new ArrayList!(Long)(fixedGroupIds);
  }

  private void saveOnlineRepositories(RepositoryRepresentation rep) {
    if (rep.getOnlineRepositories() !is null) {
      List!(OnlineRepository) reposToSave = new ArrayList!(OnlineRepository)();
      for (int i = 0; i < rep.getOnlineRepositories().size(); i++) {
        org.serviio.ui.representation.OnlineRepository repository = cast(org.serviio.ui.representation.OnlineRepository)rep.getOnlineRepositories().get(i);
        String contentUrl = validateUrl(StringUtils.trim(repository.getContentUrl()), repository.getRepositoryType());
        org.serviio.library.entities.OnlineRepository repoToSave = new org.serviio.library.entities.OnlineRepository(repository.getRepositoryType(), contentUrl, repository.getFileType(), repository.getRepositoryName(), Integer.valueOf(i + 1));

        if ((repository.getRepositoryType() == OnlineRepository.OnlineRepositoryType.LIVE_STREAM) && (ObjectValidator.isNotEmpty(repository.getThumbnailUrl()))) {
          repoToSave.setThumbnailUrl(validateFeedUrl(StringUtils.trim(repository.getThumbnailUrl())));
        }
        repoToSave.setId(repository.getId());
        repoToSave.setEnabled(repository.isEnabled());
        repoToSave.setAccessGroupIds(fixAccessGroups(repository.getAccessGroupIds()));
        reposToSave.add(repoToSave);
        log.debug_(String.format("Updating repository with values: %s", cast(Object[])[ repoToSave.toString() ]));
      }
      OnlineRepositoryService.saveRepositories(reposToSave);
    }
  }

  protected String validateUrl(String urlString, OnlineRepository.OnlineRepositoryType type)
  {
    if ((type == OnlineRepository.OnlineRepositoryType.FEED) || (type == OnlineRepository.OnlineRepositoryType.WEB_RESOURCE)) {
      return validateFeedUrl(urlString).toString();
    }
    String urlToCheck = normalizeLiveStreamUrl(urlString);
    try {
      new URI(urlToCheck);
      return urlString;
    } catch (URISyntaxException e) {
      log.debug_(String.format("Invalid URL: %s", cast(Object[])[ urlString ]));
    }throw new ValidationException(503, Collections.singletonList(urlString));
  }

  private String normalizeLiveStreamUrl(String url)
  {
    if ((url.startsWith("rtmp")) && (url.indexOf(" ") > -1))
    {
      url = url.substring(0, url.indexOf(" ")).trim();
    }
    else {
      url = url.replaceAll(" ", "%20");
    }
    return url;
  }

  private URL validateFeedUrl(String urlString) {
    String fixedUrl = fixFeedUrl(urlString);
    if (HttpUtils.isHttpUrl(fixedUrl)) {
      try {
        return new URL(fixedUrl);
      } catch (MalformedURLException e) {
        log.debug_(String.format("Invalid URL: %s", cast(Object[])[ fixedUrl ]));
        throw new ValidationException(503, Collections.singletonList(fixedUrl));
      }
    }

    log.debug_(String.format("Invalid URL of a feed: %s", cast(Object[])[ urlString ]));
    throw new ValidationException(503, Collections.singletonList(urlString));
  }

  protected String fixFeedUrl(String url)
  {
    if (url !is null) {
      return url.replaceFirst("feed://", "http://");
    }
    return url;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.resources.server.RepositoryServerResource
 * JD-Core Version:    0.6.2
 */