module org.serviio.upnp.service.contentdirectory.command.video.ListSeriesByNameCommand;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Series;
import org.serviio.library.local.service.VideoService;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.command.AbstractEntityContainerCommand;

public class ListSeriesByNameCommand : AbstractEntityContainerCommand!(Series)
{
  public this(String objectId, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(objectId, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
  }

  protected Set!(ObjectClassType) getSupportedClasses()
  {
    return new HashSet!(ObjectClassType)(Arrays.asList(cast(ObjectClassType[])[ ObjectClassType.CONTAINER, ObjectClassType.STORAGE_FOLDER ]));
  }

  protected List!(Series) retrieveEntityList()
  {
    List!(Series) series = VideoService.getListOfSeries(startIndex, count);
    return series;
  }

  protected Series retrieveSingleEntity(Long entityId)
  {
    Series series = VideoService.getSeries(entityId);
    return series;
  }

  public int retrieveItemCount()
  {
    return VideoService.getNumberOfSeries();
  }

  protected String getContainerTitle(Series series)
  {
    return series.getTitle();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.video.ListSeriesByNameCommand
 * JD-Core Version:    0.6.2
 */