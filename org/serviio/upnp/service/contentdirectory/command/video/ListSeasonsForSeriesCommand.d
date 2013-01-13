module org.serviio.upnp.service.contentdirectory.command.video.ListSeasonsForSeriesCommand;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Map : Entry;
import java.util.Set;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.local.service.VideoService;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ClassProperties;
import org.serviio.upnp.service.contentdirectory.classes.Container;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObjectBuilder;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.command.AbstractCommand;
import org.serviio.upnp.service.contentdirectory.command.CommandExecutionException;
import org.serviio.upnp.service.contentdirectory.command.ObjectValuesBuilder;
import org.serviio.upnp.service.contentdirectory.definition.Definition;
import org.serviio.upnp.service.contentdirectory.definition.i18n.BrowsingCategoriesMessages;

public class ListSeasonsForSeriesCommand : AbstractCommand!(Container)
{
  public this(String contextIdentifier, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(contextIdentifier, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
  }

  protected Set!(ObjectClassType) getSupportedClasses()
  {
    return new HashSet!(ObjectClassType)(Arrays.asList(cast(ObjectClassType[])[ ObjectClassType.CONTAINER, ObjectClassType.STORAGE_FOLDER ]));
  }

  protected Set!(ObjectType) getSupportedObjectTypes()
  {
    return ObjectType.getContainerTypes();
  }

  protected List!(Container) retrieveList()
  {
    List!(Container) items = new ArrayList!(Container)();

    List!(Integer) seasons = VideoService.getListOfSeasonsForSeries(new Long(getInternalObjectId()), accessGroup, startIndex, count);

    Integer lastViewedSeason = getLastViewedSeason(new Long(getInternalObjectId()));

    foreach (Integer seasonNumber ; seasons) {
      String runtimeId = generateRuntimeObjectId(seasonNumber);
      String containerTitle = String.format("%s %s%s", cast(Object[])[ BrowsingCategoriesMessages.getMessage("season", new Object[0]), seasonNumber, (lastViewedSeason !is null) && (lastViewedSeason.equals(seasonNumber)) ? " **" : "" ]);
      Map!(ClassProperties, Object) values = ObjectValuesBuilder.instantiateValuesForContainer(containerTitle, runtimeId, getDisplayedContainerId(objectId), objectType, accessGroup);
      items.add(cast(Container)DirectoryObjectBuilder.createInstance(containerClassType, values, null, null));
    }
    return items;
  }

  protected Container retrieveSingleItem()
  {
    Long seriesId = Long.valueOf(Long.parseLong(getInternalObjectId(Definition.instance().getParentNodeId(objectId))));
    Integer seasonNumber = new Integer(getInternalObjectId());

    Integer lastViewedSeason = getLastViewedSeason(seriesId);

    String containerTitle = String.format("%s %s%s", cast(Object[])[ BrowsingCategoriesMessages.getMessage("season", new Object[0]), seasonNumber, (lastViewedSeason !is null) && (lastViewedSeason.equals(seasonNumber)) ? " **" : "" ]);
    Map!(ClassProperties, Object) values = ObjectValuesBuilder.instantiateValuesForContainer(containerTitle, objectId, Definition.instance().getParentNodeId(objectId), objectType, accessGroup);
    return cast(Container)DirectoryObjectBuilder.createInstance(containerClassType, values, null, null);
  }

  public int retrieveItemCount()
  {
    return VideoService.getNumberOfSeasonsForSeries(new Long(getInternalObjectId()), accessGroup);
  }

  protected Integer getLastViewedSeason(Long seriesId)
  {
    Map!(Long, Integer) lastViewed = VideoService.getLastViewedEpisode(seriesId);
    if (lastViewed !is null)
    {
      return cast(Integer)(cast(Entry!(Long, Integer))lastViewed.entrySet().iterator().next()).getValue();
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.video.ListSeasonsForSeriesCommand
 * JD-Core Version:    0.6.2
 */