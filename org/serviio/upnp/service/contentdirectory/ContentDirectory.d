module org.serviio.upnp.service.contentdirectory.ContentDirectory;

import java.lang.String;
import java.lang.reflect.Constructor;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.local.service.MediaService;
import org.serviio.library.service.AccessGroupService;
import org.serviio.profile.Profile;
import org.serviio.profile.ProfileManager;
import org.serviio.renderer.entities.Renderer;
import org.serviio.upnp.protocol.soap.InvocationError;
import org.serviio.upnp.protocol.soap.OperationResult;
import org.serviio.upnp.protocol.soap.SOAPParameter;
import org.serviio.upnp.protocol.soap.SOAPParameters;
import org.serviio.upnp.service.Service;
import org.serviio.upnp.service.StateVariable;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObject;
import org.serviio.upnp.service.contentdirectory.definition.ContainerNode;
import org.serviio.upnp.service.contentdirectory.definition.Definition;
import org.serviio.util.XmlUtils;
import org.serviio.upnp.service.contentdirectory.ContentDirectoryEngine;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;

public class ContentDirectory : Service
{
  private static immutable Logger log;
  private static const String VAR_A_ARG_TYPE_SortCriteria = "A_ARG_TYPE_SortCriteria";
  private static const String VAR_A_ARG_TYPE_UpdateID = "A_ARG_TYPE_UpdateID";
  private static const String VAR_A_ARG_TYPE_SearchCriteria = "A_ARG_TYPE_SearchCriteria";
  private static const String VAR_A_ARG_TYPE_Index = "A_ARG_TYPE_Index";
  private static const String VAR_A_ARG_TYPE_TagValueList = "A_ARG_TYPE_TagValueList";
  private static const String VAR_SortCapabilities = "SortCapabilities";
  private static const String VAR_SearchCapabilities = "SearchCapabilities";
  private static const String VAR_A_ARG_TYPE_Count = "A_ARG_TYPE_Count";
  private static const String VAR_A_ARG_TYPE_BrowseFlag = "A_ARG_TYPE_BrowseFlag";
  private static const String VAR_SystemUpdateID = "SystemUpdateID";
  private static const String VAR_A_ARG_TYPE_BrowseLetter = "A_ARG_TYPE_BrowseLetter";
  private static const String VAR_A_ARG_TYPE_URI = "A_ARG_TYPE_URI";
  private static const String VAR_A_ARG_TYPE_Featurelist = "A_ARG_TYPE_Featurelist";
  private static const int BOOKMARK_OFFSET = 10;
  private ContentDirectoryEngine engine;
  
  static this()
  {
      log = LoggerFactory.getLogger!(ContentDirectory)();
  }

  protected void setupService()
  {
    serviceId = "urn:upnp-org:serviceId:ContentDirectory";
    serviceType = "urn:schemas-upnp-org:service:ContentDirectory:1";
    setupStateVariables();
    engine = ContentDirectoryEngine.getInstance();
  }

  public OperationResult GetSystemUpdateID()
  {
    OperationResult result = new OperationResult();
    result.addOutputParameter("Id", getStateVariable(VAR_SystemUpdateID).getValue());
    return result;
  }

  public OperationResult GetSearchCapabilities()
  {
    OperationResult result = new OperationResult();
    result.addOutputParameter("SearchCaps", getStateVariable(VAR_SearchCapabilities).getValue());
    return result;
  }

  public OperationResult GetSortCapabilities()
  {
    OperationResult result = new OperationResult();
    result.addOutputParameter("SortCaps", getStateVariable(VAR_SortCapabilities).getValue());
    return result;
  }

  public OperationResult Browse(/*@SOAPParameters({@SOAPParameter("ObjectID"), @SOAPParameter("ContainerID")})*/ String objectID, /*@SOAPParameter("BrowseFlag")*/ String browseFlag, /*@SOAPParameter("Filter")*/ String filter, /*@SOAPParameter("StartingIndex")*/ int startingIndex, /*@SOAPParameter("RequestedCount")*/ int requestedCount, /*@SOAPParameter("SortCriteria")*/ String sortCriteria, Renderer renderer)
  {
    if (renderer !is null) {
      log.debug_(String.format("Browse() called for renderer %s (profile %s) with parameters: objectID = %s, browseFlag = %s, filter = %s, startIndex = %s, count = %s, sortCriteria = %s", cast(Object[])[ renderer.getName(), renderer.getProfileId(), objectID, browseFlag, filter, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), sortCriteria ]));
    }
    else {
      log.debug_(String.format("Browse() called for unknown renderer with parameters: objectID = %s, browseFlag = %s, filter = %s, startIndex = %s, count = %s, sortCriteria = %s", cast(Object[])[ objectID, browseFlag, filter, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), sortCriteria ]));
    }

    OperationResult result = new OperationResult();

    Profile rendererProfile = ProfileManager.getProfile(renderer);
    AccessGroup userProfile = AccessGroupService.getAccessGroupForRenderer(renderer);
    try {
      BrowseItemsHolder!(DirectoryObject) itemsHolder = engine.browse(objectID, ObjectType.ALL, browseFlag, filter, startingIndex, requestedCount, sortCriteria, rendererProfile, userProfile);
      setupSuccessfulResult(result, itemsHolder, filter, rendererProfile);
    } catch (ObjectNotFoundException e) {
      log.warn(String.format("Object with id %s doesn't exist", cast(Object[])[ objectID ]));
      result.setError(InvocationError.CON_MAN_NO_SUCH_OBJECT);
    } catch (InvalidBrowseFlagException e) {
      log.warn(e.getMessage());
      result.setError(InvocationError.INVALID_ARGS);
      return result;
    } catch (Exception e) {
      log.warn(String.format("Browse for object id %s failed with exception: %s", cast(Object[])[ objectID, e.getMessage() ]), e);
      result.setError(InvocationError.ACTION_FAILED);
    }
    return result;
  }

  public OperationResult Search(/*@SOAPParameter("ContainerID")*/ String containerID, /*@SOAPParameter("SearchCriteria")*/ String searchCriteria, /*@SOAPParameter("Filter")*/ String filter, /*@SOAPParameter("StartingIndex")*/ int startingIndex, /*@SOAPParameter("RequestedCount")*/ int requestedCount, /*@SOAPParameter("SortCriteria")*/ String sortCriteria, Renderer renderer)
  {
    log.debug_(String.format("Search() called for renderer %s with parameters: containerID = %s, searchCriteria = %s, filter = %s, startIndex = %s, count = %s, sortCriteria = %s", cast(Object[])[ renderer !is null ? renderer.getName() : "Unknown", containerID, searchCriteria, filter, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount), sortCriteria ]));

    OperationResult result = new OperationResult();

    Profile rendererProfile = ProfileManager.getProfile(renderer);
    AccessGroup userProfile = AccessGroupService.getAccessGroupForRenderer(renderer);
    try {
      if (rendererProfile.getContentDirectoryDefinitionFilter() !is null)
      {
        containerID = rendererProfile.getContentDirectoryDefinitionFilter().filterObjectId(containerID, true);
      }
      ContainerNode container = Definition.instance().getContainer(containerID);
      if (container is null)
      {
        log.warn(String.format("Object with id %s doesn't exist", cast(Object[])[ containerID ]));
        result.setError(InvocationError.CON_MAN_NO_SUCH_OBJECT);
        return result;
      }

      BrowseItemsHolder!(DirectoryObject) itemsHolder = container.retrieveContainerItems(containerID, ObjectType.ALL, startingIndex, requestedCount, rendererProfile, userProfile);
      setupSuccessfulResult(result, itemsHolder, filter, rendererProfile);
    }
    catch (ObjectNotFoundException e) {
      log.warn(String.format("Container with id %s doesn't exist", cast(Object[])[ containerID ]));
      result.setError(InvocationError.CON_MAN_NO_SUCH_OBJECT);
    } catch (Exception e) {
      log.warn(String.format("Search in container %s failed with exception: %s", cast(Object[])[ containerID, e.getMessage() ]), e);
      result.setError(InvocationError.ACTION_FAILED);
    }
    return result;
  }

  public OperationResult X_SetBookmark(/*@SOAPParameter("CategoryType")*/ int categoryType, /*@SOAPParameter("RID")*/ int rid, /*@SOAPParameter("ObjectID")*/ String objectID, /*@SOAPParameter("PosSecond")*/ int posSecond, Renderer renderer)
  {
    OperationResult result = new OperationResult();

    if (renderer is null)
    {
      log.warn("No associated Renderer exists for the request, will not bookmark the last viewed position");
    } else {
      ContainerNode container = Definition.instance().getContainer(objectID);
      if (container is null)
      {
        log.warn(String.format("Object with id %s doesn't exist", cast(Object[])[ objectID ]));
        result.setError(InvocationError.CON_MAN_NO_SUCH_OBJECT);
      } else {
        Profile rendererProfile = ProfileManager.getProfile(renderer);
        DirectoryObject object = container.retrieveDirectoryObject(objectID, ObjectType.ALL, rendererProfile, AccessGroup.ANY);
        if ((object !is null) && (object.getEntityId() !is null)) {
          if (MediaItem.isLocalMedia(object.getEntityId()))
          {
            int position = posSecond >= BOOKMARK_OFFSET ? posSecond - BOOKMARK_OFFSET : 0;
            MediaService.setMediaItemBookmark(object.getEntityId(), Integer.valueOf(position));

            engine.clearAllCacheRegions();
          }
        }
        else log.warn(String.format("ObjectId %s is not recognized, will not bookmark the last viewed position", cast(Object[])[ objectID ]));
      }
    }

    return result;
  }

  public OperationResult X_GetFeatureList()
  {
    OperationResult result = new OperationResult();
    result.addOutputParameter("FeatureList", getStateVariable(VAR_A_ARG_TYPE_Featurelist).getValue());
    return result;
  }

  public synchronized void incrementUpdateID()
  {
    incrementUpdateID(true);
  }

  public synchronized void incrementUpdateID(bool cleanCache)
  {
    Integer currentValue = cast(Integer)getStateVariable(VAR_SystemUpdateID).getValue();
    setStateVariable(VAR_SystemUpdateID, currentValue);
    if (cleanCache)
      engine.clearAllCacheRegions();
  }

  private void setupStateVariables()
  {
    stateVariables.add(new StateVariable(VAR_A_ARG_TYPE_SortCriteria, null));
    stateVariables.add(new StateVariable(VAR_A_ARG_TYPE_UpdateID, null));
    stateVariables.add(new StateVariable(VAR_A_ARG_TYPE_SearchCriteria, null));
    stateVariables.add(new StateVariable(VAR_A_ARG_TYPE_Index, null));
    stateVariables.add(new StateVariable(VAR_A_ARG_TYPE_TagValueList, null));
    stateVariables.add(new StateVariable(VAR_SortCapabilities, ""));
    stateVariables.add(new StateVariable(VAR_SearchCapabilities, ""));
    stateVariables.add(new StateVariable(VAR_A_ARG_TYPE_Count, null));
    stateVariables.add(new StateVariable(VAR_A_ARG_TYPE_BrowseFlag, null));
    stateVariables.add(new StateVariable(VAR_SystemUpdateID, new Integer(1), true, 2000));
    stateVariables.add(new StateVariable(VAR_A_ARG_TYPE_BrowseLetter, null));
    stateVariables.add(new StateVariable(VAR_A_ARG_TYPE_URI, null));
    stateVariables.add(new StateVariable(VAR_A_ARG_TYPE_Featurelist, "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Features xmlns=\"urn:schemas-upnp-org:av:avs\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\" urn:schemas-upnp-org:av:avs http://www.upnp.org/schemas/av/avs.xsd\"><Feature name=\"samsung.com_BASICVIEW\" version=\"1\"><container id=\"I\" type=\"object.item.imageItem\"/><container id=\"A\" type=\"object.item.audioItem\"/><container id=\"V\" type=\"object.item.videoItem\"/></Feature></Features>"));
  }

  private void setupSuccessfulResult(OperationResult result, BrowseItemsHolder!(DirectoryObject) itemsHolder, String filter, Profile rendererProfile)
  {
    ContentDirectoryMessageBuilder messageBuilder = instantiateMessageBuilder(filter, rendererProfile);
    Document xmlDocument = messageBuilder.buildXML(itemsHolder.getItems());

    result.addOutputParameter("Result", XmlUtils.getStringFromDocument(xmlDocument));
    result.addOutputParameter("NumberReturned", Integer.valueOf(itemsHolder.getReturnedSize()));
    result.addOutputParameter("TotalMatches", Integer.valueOf(itemsHolder.getTotalMatched()));
    result.addOutputParameter("UpdateID", getStateVariable(VAR_SystemUpdateID).getValue());
  }

  private ContentDirectoryMessageBuilder instantiateMessageBuilder(T : ContentDirectoryMessageBuilder)(String filter, Profile rendererProfile) {
    Class!(Object) builderClass = rendererProfile.getContentDirectoryMessageBuilder();
    if (builderClass is null)
      throw new RuntimeException("MessageBuilder class not defined in Profile");
    try
    {
      Constructor!(Object) c = builderClass.getConstructor(cast(Class[])[ String.class_ ]);
      return cast(ContentDirectoryMessageBuilder)c.newInstance(cast(Object[])[ filter ]);
    } catch (Exception e) {
      throw new RuntimeException(String.format("Cannot instantiate ContentDirectoryMessageBuilder. Message: %s", cast(Object[])[ e.getMessage() ]), e);
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.ContentDirectory
 * JD-Core Version:    0.6.2
 */