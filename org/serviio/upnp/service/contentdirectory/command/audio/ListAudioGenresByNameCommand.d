module org.serviio.upnp.service.contentdirectory.command.audio.ListAudioGenresByNameCommand;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Genre;
import org.serviio.library.local.service.GenreService;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.command.AbstractEntityContainerCommand;

public class ListAudioGenresByNameCommand : AbstractEntityContainerCommand!(Genre)
{
  public this(String objectId, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(objectId, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
  }

  protected Set!(ObjectClassType) getSupportedClasses()
  {
    return new HashSet!(ObjectClassType)(Arrays.asList(cast(ObjectClassType[])[ ObjectClassType.CONTAINER, ObjectClassType.GENRE, ObjectClassType.MUSIC_GENRE ]));
  }

  protected List!(Genre) retrieveEntityList()
  {
    List!(Genre) genres = GenreService.getListOfGenres(MediaFileType.AUDIO, startIndex, count);
    return genres;
  }

  protected Genre retrieveSingleEntity(Long entityId)
  {
    Genre genre = GenreService.getGenre(entityId);
    return genre;
  }

  public int retrieveItemCount()
  {
    return GenreService.getNumberOfGenres(MediaFileType.AUDIO);
  }

  protected String getContainerTitle(Genre genre)
  {
    return genre.getName();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.audio.ListAudioGenresByNameCommand
 * JD-Core Version:    0.6.2
 */