module org.serviio.upnp.service.contentdirectory.command.image.ListImagesForCreationMonthAndYearCommand;

import java.util.List;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Image;
import org.serviio.library.local.service.ImageService;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.definition.Definition;

public class ListImagesForCreationMonthAndYearCommand : AbstractImagesRetrievalCommand
{
  public this(String contextIdentifier, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(contextIdentifier, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
  }

  protected List!(Image) retrieveEntityList()
  {
    List!(Image) images = ImageService.getListOfImagesForMonthAndYear(getMonth(), getYear(), accessGroup, startIndex, count);
    return images;
  }

  public int retrieveItemCount()
  {
    return ImageService.getNumberOfImagesForMonthAndYear(getMonth(), getYear(), accessGroup);
  }

  private Integer getYear()
  {
    Integer year = Integer.valueOf(Integer.parseInt(getInternalObjectId(Definition.instance().getParentNodeId(objectId))));
    return year;
  }

  private Integer getMonth()
  {
    Integer month = Integer.valueOf(Integer.parseInt(getInternalObjectId()));
    return month;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.image.ListImagesForCreationMonthAndYearCommand
 * JD-Core Version:    0.6.2
 */