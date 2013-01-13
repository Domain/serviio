module org.serviio.upnp.service.contentdirectory.rest.resources.server.CDSBrowseServerResource;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map : Entry;
import java.util.Set;
import org.restlet.resource.ResourceException;
import org.serviio.config.Configuration;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.local.OnlineDBIdentifier;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.profile.DeliveryQuality : QualityType;
import org.serviio.profile.Profile;
import org.serviio.profile.ProfileManager;
import org.serviio.restlet.HttpCodeException;
import org.serviio.restlet.ValidationException;
import org.serviio.upnp.service.contentdirectory.BrowseItemsHolder;
import org.serviio.upnp.service.contentdirectory.ContentDirectoryEngine;
import org.serviio.upnp.service.contentdirectory.HostInfo;
import org.serviio.upnp.service.contentdirectory.InvalidBrowseFlagException;
import org.serviio.upnp.service.contentdirectory.ObjectNotFoundException;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.AudioItem;
import org.serviio.upnp.service.contentdirectory.classes.Container;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObject;
import org.serviio.upnp.service.contentdirectory.classes.ImageItem;
import org.serviio.upnp.service.contentdirectory.classes.InvalidResourceException;
import org.serviio.upnp.service.contentdirectory.classes.Item;
import org.serviio.upnp.service.contentdirectory.classes.MusicTrack;
import org.serviio.upnp.service.contentdirectory.classes.Resource;
import org.serviio.upnp.service.contentdirectory.classes.VideoItem;
import org.serviio.upnp.service.contentdirectory.rest.representation.ContentDirectoryRepresentation;
import org.serviio.upnp.service.contentdirectory.rest.representation.ContentURLRepresentation;
import org.serviio.upnp.service.contentdirectory.rest.representation.DirectoryObjectRepresentation;
import org.serviio.upnp.service.contentdirectory.rest.representation.OnlineIdentifierRepresentation;
import org.serviio.upnp.service.contentdirectory.rest.resources.CDSBrowseResource;
import org.serviio.util.HttpUtils;
import org.serviio.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CDSBrowseServerResource : AbstractRestrictedCDSServerResource
  , CDSBrowseResource
{
  private static final Logger log = LoggerFactory.getLogger!(CDSBrowseServerResource);
  private String profile;
  private String objectId;
  private int startIndex;
  private int count;
  private String browseFlag;
  private ObjectType objectType;
  private HostInfo hostInfo;

  public this()
  {
    objectType = ObjectType.ALL;

    hostInfo = getHostInfo();
  }

  public ContentDirectoryRepresentation browse()
  {
    try
    {
      Profile rendererProfile = ProfileManager.getProfileById(profile);
      if (rendererProfile is null) {
        log.warn(String.format("Profile with id %s doesn't exist", cast(Object[])[ profile ]));
        throw new HttpCodeException(400);
      }
      ContentDirectoryEngine engine = ContentDirectoryEngine.getInstance();
      BrowseItemsHolder!(DirectoryObject) itemsHolder = engine.browse(objectId, objectType, browseFlag, "*", startIndex, count, "", ProfileManager.getProfileById(profile), AccessGroup.ANY);

      return buildResult(itemsHolder);
    } catch (ObjectNotFoundException e) {
      log.warn(String.format("Object with id %s doesn't exist", cast(Object[])[ objectId ]));
      throw new HttpCodeException(404);
    } catch (InvalidBrowseFlagException e) {
      log.warn(e.getMessage());
      throw new ValidationException(700);
    } catch (Exception e) {
      log.warn(String.format("Browse for object id %s failed with exception: %s", cast(Object[])[ objectId, e.getMessage() ]), e);
      throw new RuntimeException(e);
    }
  }

  protected void doInit()
  {
    super.doInit();
    objectId = HttpUtils.urlDecode(cast(String)getRequestAttributes().get("objectId"));
    browseFlag = (cast(String)getRequestAttributes().get("browseFlag"));
    startIndex = Integer.parseInt(cast(String)getRequestAttributes().get("start"));
    count = Integer.parseInt(cast(String)getRequestAttributes().get("count"));
    objectType = ObjectType.valueOf(StringUtils.localeSafeToUppercase(cast(String)getRequestAttributes().get("objectType")));
    profile = (cast(String)getRequestAttributes().get("profile"));
  }

  private ContentDirectoryRepresentation buildResult(BrowseItemsHolder!(DirectoryObject) itemsHolder)
  {
    ContentDirectoryRepresentation result = new ContentDirectoryRepresentation();
    List!(DirectoryObjectRepresentation) objects = new ArrayList!(DirectoryObjectRepresentation)();

    foreach (DirectoryObject dirObject ; itemsHolder.getItems()) {
      DirectoryObjectRepresentation.DirectoryObjectType type = ( cast(Container)dirObject !is null ) ? DirectoryObjectRepresentation.DirectoryObjectType.CONTAINER : DirectoryObjectRepresentation.DirectoryObjectType.ITEM;
      DirectoryObjectRepresentation objRep = new DirectoryObjectRepresentation(type, dirObject.getTitle(), dirObject.getId());
      objRep.setParentId(dirObject.getParentID());
      if (objRep.getType() == DirectoryObjectRepresentation.DirectoryObjectType.CONTAINER) {
        Container container = cast(Container)dirObject;
        objRep.setChildCount(container.getChildCount());
      } else {
        Item item = cast(Item)dirObject;
        List!(Resource) resources = getSuitableResources(item);
        if (resources.size() > 0) {
          Resource defaultQualityResource = cast(Resource)resources.get(0);
          objRep.setThumbnailUrl(getResourceUrl(item.getIcon()));
          storeContentUrls(objRep, resources);
          if (( cast(AudioItem)item !is null )) {
            AudioItem audioItem = cast(AudioItem)item;
            objRep.setFileType(MediaFileType.AUDIO);
            objRep.setDescription(audioItem.getDescription());
            objRep.setGenre(audioItem.getGenre());
            objRep.setLive(audioItem.getLive());
            if (( cast(MusicTrack)audioItem !is null )) {
              MusicTrack musicTrack = cast(MusicTrack)audioItem;
              objRep.setDate(musicTrack.getDate());
              objRep.setOriginalTrackNumber(musicTrack.getOriginalTrackNumber());
              objRep.setArtist(getFirstItemFromArray(musicTrack.getArtist()));
              objRep.setAlbum(musicTrack.getAlbum());
              objRep.setDuration(defaultQualityResource.getDuration());
            }
          } else if (( cast(VideoItem)item !is null )) {
            VideoItem videoItem = cast(VideoItem)item;
            objRep.setFileType(MediaFileType.VIDEO);
            objRep.setDescription(videoItem.getDescription());
            objRep.setGenre(videoItem.getGenre());
            objRep.setDate(videoItem.getDate());
            objRep.setDuration(defaultQualityResource.getDuration());
            objRep.setSubtitlesUrl(getResourceUrl(videoItem.getSubtitlesUrlResource()));
            objRep.setLive(videoItem.getLive());
            objRep.setContentType(videoItem.getContentType());
            storeOnlineIdentifiers(objRep, videoItem);
          } else if (( cast(ImageItem)item !is null )) {
            ImageItem imageItem = cast(ImageItem)item;
            objRep.setFileType(MediaFileType.IMAGE);
            objRep.setDescription(imageItem.getDescription());
            objRep.setDate(imageItem.getDate());
          }
        }
      }
      objects.add(objRep);
    }

    result.setObjects(objects);
    result.setReturnedSize(Integer.valueOf(itemsHolder.getReturnedSize()));
    result.setTotalMatched(Integer.valueOf(itemsHolder.getTotalMatched()));
    return result;
  }

  private void storeContentUrls(DirectoryObjectRepresentation objRep, List!(Resource) resources) {
    List!(ContentURLRepresentation) urls = new ArrayList!(ContentURLRepresentation)();
    QualityType preferredQualityType = findPreferredQualityType(resources);
    bool defaultQualityApplied = false;
    foreach (Resource resource ; resources) {
      ContentURLRepresentation urlRepresentation = new ContentURLRepresentation(resource.getQuality(), getResourceUrl(resource));
      urlRepresentation.setResolution(resource.getResolution());
      urlRepresentation.setTranscoded(resource.isTranscoded());
      urlRepresentation.setFileSize(resource.getSize());
      if ((!defaultQualityApplied) && (resource.getQuality() == preferredQualityType)) {
        urlRepresentation.setPreferred(Boolean.valueOf(true));
        defaultQualityApplied = true;
      }
      urls.add(urlRepresentation);
    }
    objRep.setContentUrls(urls);
  }

  private void storeOnlineIdentifiers(DirectoryObjectRepresentation objRep, VideoItem videoItem) {
    if ((videoItem.getOnlineIdentifiers() !is null) && (videoItem.getOnlineIdentifiers().size() > 0)) {
      List!(OnlineIdentifierRepresentation) reps = new ArrayList!(OnlineIdentifierRepresentation)();
      foreach (Entry!(OnlineDBIdentifier, String) entry ; videoItem.getOnlineIdentifiers().entrySet()) {
        reps.add(new OnlineIdentifierRepresentation((cast(OnlineDBIdentifier)entry.getKey()).toString(), cast(String)entry.getValue()));
      }
      objRep.setOnlineIdentifiers(reps);
    }
  }

  private QualityType findPreferredQualityType(List!(Resource) resources)
  {
    QualityType preferredQuality = Configuration.getRemotePreferredDeliveryQuality();
    Set!(QualityType) availableQualities = getResourceQualities(resources);
    if (availableQualities.contains(preferredQuality)) {
      return preferredQuality;
    }

    if (preferredQuality == QualityType.LOW)
    {
      return findAlternativeQuality(availableQualities, QualityType.MEDIUM, QualityType.ORIGINAL);
    }if (preferredQuality == QualityType.MEDIUM)
    {
      return findAlternativeQuality(availableQualities, QualityType.LOW, QualityType.ORIGINAL);
    }

    return findAlternativeQuality(availableQualities, QualityType.MEDIUM, QualityType.LOW);
  }

  private QualityType findAlternativeQuality(Set!(QualityType) availableQualities, QualityType firstChoice, QualityType fallbackChoice)
  {
    if (availableQualities.contains(firstChoice)) {
      return firstChoice;
    }
    return fallbackChoice;
  }

  private Set!(QualityType) getResourceQualities(List!(Resource) resources)
  {
    Set!(QualityType) qualities = new HashSet!(QualityType)();
    foreach (Resource res ; resources) {
      qualities.add(res.getQuality());
    }
    return qualities;
  }

  private String getFirstItemFromArray(String[] array) {
    if ((array !is null) && (array.length > 0)) {
      return array[0];
    }
    return null;
  }

  private HostInfo getHostInfo() {
    return new HostInfo(null, null, "/cds/resource");
  }

  private List!(Resource) getSuitableResources(Item item)
  {
    List!(Resource) resources = new ArrayList!(Resource)();
    foreach (Resource res ; item.getResources()) {
      if ((res.getResourceType() == Resource.ResourceType.MEDIA_ITEM) && (res.getProtocolInfoIndex().intValue() == 0)) {
        resources.add(res);
      }
    }
    Collections.sort(resources, new ResourceComparator());

    Set!(QualityType) foundQualities = new HashSet!(QualityType)();
    Iterator!(Resource) it = resources.iterator();
    while (it.hasNext()) {
      Resource r = cast(Resource)it.next();
      if (foundQualities.contains(r.getQuality()))
        it.remove();
      else {
        foundQualities.add(r.getQuality());
      }
    }
    return resources;
  }

  private String getResourceUrl(Resource resource)
  {
    if (resource !is null) {
      try {
        return String.format("%s,%s", cast(Object[])[ resource.getGeneratedURL(hostInfo).toString(), profile ]);
      } catch (InvalidResourceException e) {
        log.warn("Cannot generate resource URL because the resource is invalid.");
      }
    }
    return null;
  }
  private class ResourceComparator : Comparator!(Resource) {
    private this() {
    }

    public int compare(Resource o1, Resource o2) {
      if (o1.getQuality() == o2.getQuality()) {
        if (o1.getProtocolInfo().indexOf("CI=1") == -1) {
          return -1;
        }
        return 1;
      }
      return (new Integer(o1.getQuality().ordinal())).compareTo(new Integer(o2.getQuality().ordinal()));
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.rest.resources.server.CDSBrowseServerResource
 * JD-Core Version:    0.6.2
 */