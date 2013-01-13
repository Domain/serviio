module org.serviio.upnp.service.contentdirectory.command.ObjectValuesBuilder;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import org.serviio.db.entities.PersistedEntity;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Folder;
import org.serviio.library.entities.Genre;
import org.serviio.library.entities.Image;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.entities.MusicAlbum;
import org.serviio.library.entities.MusicTrack;
import org.serviio.library.entities.OnlineRepository;
import org.serviio.library.entities.Person;
import org.serviio.library.entities.Person : RoleType;
import org.serviio.library.entities.Playlist;
import org.serviio.library.entities.Repository;
import org.serviio.library.entities.Series;
import org.serviio.library.entities.Video;
import org.serviio.library.local.service.AudioService;
import org.serviio.library.local.service.FolderService;
import org.serviio.library.local.service.GenreService;
import org.serviio.library.local.service.PersonService;
import org.serviio.library.local.service.SubtitlesService;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ClassProperties;
import org.serviio.upnp.service.contentdirectory.classes.Resource;
import org.serviio.upnp.service.contentdirectory.definition.Definition;
import org.serviio.util.CollectionUtils;
import org.serviio.util.DateUtils;

public class ObjectValuesBuilder
{
  public static Map!(ClassProperties, Object) buildObjectValues(PersistedEntity entity, String objectId, String parentId, ObjectType objectType, String title, Profile rendererProfile, AccessGroup accessGroup)
  {
    Map!(ClassProperties, Object) values = null;
    if (( cast(Folder)entity !is null )) {
      values = instantiateValuesForContainer(title, objectId, parentId, objectType, accessGroup);
    } else if (( cast(Person)entity !is null )) {
      values = instantiateValuesForContainer(title, objectId, parentId, objectType, accessGroup);
    } else if (( cast(Playlist)entity !is null )) {
      values = instantiateValuesForContainer(title, objectId, parentId, objectType, accessGroup);
    } else if (( cast(Genre)entity !is null )) {
      values = instantiateValuesForContainer(title, objectId, parentId, objectType, accessGroup);
    } else if (( cast(Series)entity !is null )) {
      values = instantiateValuesForContainer(title, objectId, parentId, objectType, accessGroup);
    } else if (( cast(MusicAlbum)entity !is null )) {
      MusicAlbum album = cast(MusicAlbum)entity;
      values = instantiateValuesForContainer(title, objectId, parentId, objectType, accessGroup);
      Person albumArtist = cast(Person)CollectionUtils.getFirstItem(PersonService.getListOfPersonsForMusicAlbum(album.getId(), RoleType.ALBUM_ARTIST));
      if (albumArtist !is null)
        values.put(ClassProperties.ARTIST, albumArtist.getName());
    }
    else if (( cast(Image)entity !is null )) {
      Image image = cast(Image)entity;
      values = instantiateValuesForItem(title, objectId, parentId, image);
      values.put(ClassProperties.DATE, DateUtils.formatISO8601YYYYMMDD(image.getDate()));
      values.put(ClassProperties.DESCRIPTION, image.getDescription());
      if (image.isLocalMedia())
        values.put(ClassProperties.ALBUM, FolderService.getFolder(image.getFolderId()).getName());
    }
    else if (( cast(MusicTrack)entity !is null )) {
      MusicTrack track = cast(MusicTrack)entity;
      values = instantiateValuesForItem(title, objectId, parentId, track);
      values.put(ClassProperties.ALBUM, AudioService.getMusicAlbum(track.getAlbumId()));
      values.put(ClassProperties.GENRE, GenreService.getGenre(track.getGenreId()));
      if (track.isLocalMedia()) {
        Person artist = cast(Person)CollectionUtils.getFirstItem(PersonService.getListOfPersonsForMediaItem(track.getId(), RoleType.ARTIST));
        values.put(ClassProperties.CREATOR, artist);
        values.put(ClassProperties.ARTIST, artist);
      }
      values.put(ClassProperties.DATE, DateUtils.formatISO8601YYYYMMDD(track.getDate()));
      values.put(ClassProperties.ORIGINAL_TRACK_NUMBER, track.getTrackNumber());
      values.put(ClassProperties.DESCRIPTION, track.getDescription());
      values.put(ClassProperties.LIVE, Boolean.valueOf(track.isLive()));
    } else if (( cast(Video)entity !is null )) {
      Video video = cast(Video)entity;
      values = instantiateValuesForItem(title, objectId, parentId, video);
      values.put(ClassProperties.RATING, video.getRating());
      values.put(ClassProperties.DESCRIPTION, video.getDescription());
      values.put(ClassProperties.DATE, DateUtils.formatISO8601YYYYMMDD(video.getDate()));
      values.put(ClassProperties.LIVE, Boolean.valueOf(video.isLive()));
      values.put(ClassProperties.ONLINE_DB_IDENTIFIERS, video.getOnlineIdentifiers());
      values.put(ClassProperties.CONTENT_TYPE, video.getContentType());
      if (video.isLocalMedia()) {
        values.put(ClassProperties.GENRE, GenreService.getGenre(video.getGenreId()));
        values.put(ClassProperties.SUBTITLES_URL, generateSubtitlesResource(video));
      }

    }
    else if (( cast(Repository)entity !is null )) {
      values = instantiateValuesForContainer(title, objectId, parentId, objectType, accessGroup);
    } else if (( cast(OnlineRepository)entity !is null )) {
      values = instantiateValuesForContainer(title, objectId, parentId, objectType, accessGroup);
    } else {
      return null;
    }

    if (rendererProfile.getContentDirectoryDefinitionFilter() !is null) {
      rendererProfile.getContentDirectoryDefinitionFilter().filterClassProperties(objectId, values);
    }
    return values;
  }

  public static Map!(ClassProperties, Object) instantiateValuesForContainer(String containerTitle, String objectId, String parentId, ObjectType objectType, AccessGroup accessGroup)
  {
    Map!(ClassProperties, Object) values = new HashMap!(ClassProperties, Object)();
    values.put(ClassProperties.ID, objectId);
    values.put(ClassProperties.TITLE, getBrowsableTitle(containerTitle, objectId));
    values.put(ClassProperties.PARENT_ID, parentId);
    values.put(ClassProperties.CHILD_COUNT, Integer.valueOf(Definition.instance().getContainer(objectId).retrieveContainerItemsCount(objectId, objectType, accessGroup)));
    values.put(ClassProperties.SEARCHABLE, Boolean.FALSE);
    return values;
  }

  public static Map!(ClassProperties, Object) instantiateValuesForItem(String itemTitle, String objectId, String parentId, MediaItem item)
  {
    Map!(ClassProperties, Object) values = new HashMap!(ClassProperties, Object)();
    Resource icon = generateThumbnailResource(item);
    values.put(ClassProperties.ID, objectId);
    values.put(ClassProperties.TITLE, getBrowsableTitle(itemTitle, objectId));
    values.put(ClassProperties.PARENT_ID, parentId);
    values.put(ClassProperties.ICON, icon);
    values.put(ClassProperties.ALBUM_ART_URI, icon);
    values.put(ClassProperties.DCM_INFO, generateDcmInfo(item));
    return values;
  }

  protected static final Resource generateThumbnailResource(MediaItem item)
  {
    if (item.getThumbnailId() !is null) {
      try {
        return new Resource(Resource.ResourceType.COVER_IMAGE, item.getThumbnailId(), null, null, null, null);
      } catch (Exception e) {
        return null;
      }
    }
    return null;
  }

  protected static final Resource generateSubtitlesResource(Video item)
  {
    File subtitleFile = SubtitlesService.findSubtitleFile(item.getId());
    if (subtitleFile !is null) {
      try {
        return new Resource(Resource.ResourceType.SUBTITLE, item.getId(), null, null, null, null);
      } catch (Exception e) {
        return null;
      }
    }
    return null;
  }

  protected static final String generateDcmInfo(MediaItem item)
  {
    if (item.getBookmark() !is null) {
      return String.format("CREATIONDATE=0,YEAR=%s,BM=%s", cast(Object[])[ Integer.valueOf(DateUtils.getYear(item.getDate())), item.getBookmark() ]);
    }
    return null;
  }

  private static String getBrowsableTitle(String itemTitle, String objectId) {
    String parentsTitle = Definition.instance().getContentOnlyParentTitles(objectId);
    if (parentsTitle !is null) {
      return String.format("%s %s", cast(Object[])[ itemTitle, parentsTitle ]);
    }
    return itemTitle;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.ObjectValuesBuilder
 * JD-Core Version:    0.6.2
 */