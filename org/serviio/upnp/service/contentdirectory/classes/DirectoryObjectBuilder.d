module org.serviio.upnp.service.contentdirectory.classes.DirectoryObjectBuilder;

import java.lang.Long;
import java.lang.String;
import java.util.List;
import java.util.Map;
import org.serviio.library.local.ContentType;
import org.serviio.upnp.service.contentdirectory.definition.Definition;
import org.serviio.upnp.service.contentdirectory.classes.all;
static import org.serviio.library.entities.Person;

public class DirectoryObjectBuilder
{
    public static DirectoryObject createInstance(ObjectClassType type, Map!(ClassProperties, Object) values, List!(Resource) resources, Long entityId)
    {
        if (type == ObjectClassType.CONTAINER) 
        {
            Container container = new Container(cast(String)values.get(ClassProperties.ID), cast(String)values.get(ClassProperties.TITLE));
            setupContainer(container, values, resources, entityId);
            return container;
        }
        if (type == ObjectClassType.AUDIO_ITEM) 
        {
            AudioItem item = new AudioItem(cast(String)values.get(ClassProperties.ID), cast(String)values.get(ClassProperties.TITLE));
            setupAudioItem(item, values, resources, entityId);
            return item;
        }
        if (type == ObjectClassType.MUSIC_TRACK) 
        {
            MusicTrack item = new MusicTrack(cast(String)values.get(ClassProperties.ID), cast(String)values.get(ClassProperties.TITLE));
            setupMusicTrack(item, values, resources, entityId);
            return item;
        }
        if (type == ObjectClassType.GENRE) 
        {
            Genre container = new Genre(cast(String)values.get(ClassProperties.ID), cast(String)values.get(ClassProperties.TITLE));
            setupGenre(container, values, resources, entityId);
            return container;
        }
        if (type == ObjectClassType.MUSIC_GENRE) 
        {
            MusicGenre container = new MusicGenre(cast(String)values.get(ClassProperties.ID), cast(String)values.get(ClassProperties.TITLE));
            setupGenre(container, values, resources, entityId);
            return container;
        }
        if (type == ObjectClassType.PERSON) {
            Person container = new Person(cast(String)values.get(ClassProperties.ID), cast(String)values.get(ClassProperties.TITLE));
            setupPerson(container, values, resources, entityId);
            return container;
        }
        if (type == ObjectClassType.MUSIC_ARTIST) 
        {
            MusicArtist container = new MusicArtist(cast(String)values.get(ClassProperties.ID), cast(String)values.get(ClassProperties.TITLE));
            setupMusicArtist(container, values, resources, entityId);
            return container;
        }
        if (type == ObjectClassType.IMAGE_ITEM) {
            ImageItem item = new ImageItem(cast(String)values.get(ClassProperties.ID), cast(String)values.get(ClassProperties.TITLE));
            setupImageItem(item, values, resources, entityId);
            return item;
        }
        if (type == ObjectClassType.PHOTO) 
        {
            Photo item = new Photo(cast(String)values.get(ClassProperties.ID), cast(String)values.get(ClassProperties.TITLE));
            setupPhoto(item, values, resources, entityId);
            return item;
        }
        if (type == ObjectClassType.VIDEO_ITEM) 
        {
            VideoItem item = new VideoItem(cast(String)values.get(ClassProperties.ID), cast(String)values.get(ClassProperties.TITLE));
            setupVideoItem(item, values, resources, entityId);
            return item;
        }
        if (type == ObjectClassType.MOVIE) 
        {
            Movie item = new Movie(cast(String)values.get(ClassProperties.ID), cast(String)values.get(ClassProperties.TITLE));
            setupMovie(item, values, resources, entityId);
            return item;
        }
        if (type == ObjectClassType.STORAGE_FOLDER) 
        {
            StorageFolder container = new StorageFolder(cast(String)values.get(ClassProperties.ID), cast(String)values.get(ClassProperties.TITLE));
            setupStorageFolder(container, values, resources, entityId);
            return container;
        }
        if (type == ObjectClassType.MUSIC_ALBUM) 
        {
            MusicAlbum container = new MusicAlbum(cast(String)values.get(ClassProperties.ID), cast(String)values.get(ClassProperties.TITLE));
            setupMusicAlbum(container, values, resources, entityId);
            return container;
        }
        if (type == ObjectClassType.PLAYLIST_CONTAINER) 
        {
            PlaylistContainer container = new PlaylistContainer(cast(String)values.get(ClassProperties.ID), cast(String)values.get(ClassProperties.TITLE));
            setupPlaylistContainer(container, values, resources, entityId);
            return container;
        }
        return null;
    }

    private static void setupObject(DirectoryObject object, Map!(ClassProperties, Object) values, List!(Resource) resources, Long entityId)
    {
        org.serviio.library.entities.Person creator = cast(org.serviio.library.entities.Person)values.get(ClassProperties.CREATOR);
        if (creator !is null) {
            object.setCreator(creator.getName());
        }
        object.setParentID(cast(String)values.get(ClassProperties.PARENT_ID));
        object.setResources(resources);
        object.setEntityId(entityId);
    }

    private static void setupContainer(Container container, Map!(ClassProperties, Object) values, List!(Resource) resources, Long entityId) 
    {
        setupObject(container, values, resources, entityId);
        container.setChildCount(cast(Integer)values.get(ClassProperties.CHILD_COUNT));
        container.setSearchable((cast(Boolean)values.get(ClassProperties.SEARCHABLE)).boolValue());

        String mediaClass = getMediaClass(container);
        container.setMediaClass(mediaClass);
    }

    private static void setupItem(Item item, Map!(ClassProperties, Object) values, List!(Resource) resources, Long entityId) 
    {
        setupObject(item, values, resources, entityId);
        item.setRefID(cast(String)values.get(ClassProperties.REF_ID));
        item.setIcon(cast(Resource)values.get(ClassProperties.ICON));
        item.setDcmInfo(cast(String)values.get(ClassProperties.DCM_INFO));
    }

    private static void setupAudioItem(AudioItem item, Map!(ClassProperties, Object) values, List!(Resource) resources, Long entityId) 
    {
        setupItem(item, values, resources, entityId);
        item.setDescription(cast(String)values.get(ClassProperties.DESCRIPTION));
        org.serviio.library.entities.Genre genre = cast(org.serviio.library.entities.Genre)values.get(ClassProperties.GENRE);
        if (genre !is null) {
            item.setGenre(genre.getName());
        }
        item.setLanguage(cast(String)values.get(ClassProperties.LANGUAGE));
        item.setLongDescription(cast(String)values.get(ClassProperties.LONG_DESCRIPTION));
        item.setPublisher(cast(String)values.get(ClassProperties.PUBLISHER));
        item.setRights(cast(String)values.get(ClassProperties.RIGHTS));
        item.setAlbumArtURIResource(cast(Resource)values.get(ClassProperties.ALBUM_ART_URI));
        item.setLive(cast(Boolean)values.get(ClassProperties.LIVE));
    }

    private static void setupMusicTrack(MusicTrack item, Map!(ClassProperties, Object) values, List!(Resource) resources, Long entityId) 
    {
        setupAudioItem(item, values, resources, entityId);
        org.serviio.library.entities.MusicAlbum album = cast(org.serviio.library.entities.MusicAlbum)values.get(ClassProperties.ALBUM);
        if (album !is null) {
            item.setAlbum(album.getTitle());
        }
        org.serviio.library.entities.Person artist = cast(org.serviio.library.entities.Person)values.get(ClassProperties.ARTIST);
        if (artist !is null) {
            item.setArtist(cast(String[])[ artist.getName() ]);
        }
        item.setDate(cast(String)values.get(ClassProperties.DATE));
        item.setOriginalTrackNumber(cast(Integer)values.get(ClassProperties.ORIGINAL_TRACK_NUMBER));
    }

    private static void setupGenre(Genre item, Map!(ClassProperties, Object) values, List!(Resource) resources, Long entityId) 
    {
        setupContainer(item, values, resources, entityId);
    }

    private static void setupPerson(Person item, Map!(ClassProperties, Object) values, List!(Resource) resources, Long entityId) 
    {
        setupContainer(item, values, resources, entityId);
    }

    private static void setupMusicArtist(MusicArtist item, Map!(ClassProperties, Object) values, List!(Resource) resources, Long entityId) 
    {
        setupPerson(item, values, resources, entityId);
    }

    private static void setupImageItem(ImageItem item, Map!(ClassProperties, Object) values, List!(Resource) resources, Long entityId) 
    {
        setupItem(item, values, resources, entityId);
        item.setDescription(cast(String)values.get(ClassProperties.DESCRIPTION));
        item.setLongDescription(cast(String)values.get(ClassProperties.LONG_DESCRIPTION));
        item.setRights(cast(String)values.get(ClassProperties.RIGHTS));
        item.setPublisher(cast(String[])values.get(ClassProperties.PUBLISHER));
        item.setDate(cast(String)values.get(ClassProperties.DATE));
        item.setAlbumArtURIResource(cast(Resource)values.get(ClassProperties.ALBUM_ART_URI));
    }

    private static void setupPhoto(Photo item, Map!(ClassProperties, Object) values, List!(Resource) resources, Long entityId) 
    {
        setupImageItem(item, values, resources, entityId);
        item.setAlbum(cast(String)values.get(ClassProperties.ALBUM));
    }

    private static void setupVideoItem(VideoItem item, Map!(ClassProperties, Object) values, List!(Resource) resources, Long entityId)
    {
        setupItem(item, values, resources, entityId);
        org.serviio.library.entities.Genre genre = cast(org.serviio.library.entities.Genre)values.get(ClassProperties.GENRE);
        if (genre !is null) {
            item.setGenre(genre.getName());
        }
        item.setDescription(cast(String)values.get(ClassProperties.DESCRIPTION));
        item.setDate(cast(String)values.get(ClassProperties.DATE));
        item.setLongDescription(cast(String)values.get(ClassProperties.LONG_DESCRIPTION));
        item.setRating(cast(String)values.get(ClassProperties.RATING));
        item.setLanguage(cast(String)values.get(ClassProperties.LANGUAGE));
        item.setSubtitlesUrlResource(cast(Resource)values.get(ClassProperties.SUBTITLES_URL));
        item.setPublishers(getPersonsNames(cast(List)values.get(ClassProperties.PUBLISHER)));
        item.setActors(getPersonsNames(cast(List)values.get(ClassProperties.ACTOR)));
        item.setDirectors(getPersonsNames(cast(List)values.get(ClassProperties.DIRECTOR)));
        item.setProducers(getPersonsNames(cast(List)values.get(ClassProperties.PRODUCER)));
        item.setAlbumArtURIResource(cast(Resource)values.get(ClassProperties.ALBUM_ART_URI));
        item.setLive(cast(Boolean)values.get(ClassProperties.LIVE));
        item.setContentType(cast(ContentType)values.get(ClassProperties.CONTENT_TYPE));
        item.setOnlineIdentifiers(cast(Map)values.get(ClassProperties.ONLINE_DB_IDENTIFIERS));
    }

    private static void setupMovie(Movie item, Map!(ClassProperties, Object) values, List!(Resource) resources, Long entityId) 
    {
        setupVideoItem(item, values, resources, entityId);
    }

    private static void setupStorageFolder(StorageFolder container, Map!(ClassProperties, Object) values, List!(Resource) resources, Long entityId) 
    {
        setupContainer(container, values, resources, entityId);
    }

    private static void setupMusicAlbum(MusicAlbum container, Map!(ClassProperties, Object) values, List!(Resource) resources, Long entityId) 
    {
        setupContainer(container, values, resources, entityId);
        container.setArtist(cast(String)values.get(ClassProperties.ARTIST));
    }

    private static void setupPlaylistContainer(PlaylistContainer container, Map!(ClassProperties, Object) values, List!(Resource) resources, Long entityId) 
    {
        setupContainer(container, values, resources, entityId);
    }

    private static String[] getPersonsNames(List!(org.serviio.library.entities.Person.Person) persons)
    {
        if ((persons !is null) && (persons.size() > 0)) {
            String[] names = new String[persons.size()];
            for (int i = 0; i < persons.size(); i++) {
                org.serviio.library.entities.Person person = cast(org.serviio.library.entities.Person)persons.get(i);
                names[i] = person.getName();
            }
            return names;
        }
        return null;
    }

    private static String getMediaClass(Container container)
    {
        String mediaClass = getContainerMediaClass(container.getId());
        if (mediaClass is null) {
            String parentId = container.getId();
            while ((mediaClass is null) && (!parentId.equals("-1"))) {
                parentId = Definition.instance().getParentNodeId(parentId);
                mediaClass = getContainerMediaClass(parentId);
            }
        }
        return mediaClass;
    }

    private static String getContainerMediaClass(String containerId) 
    {
        if ((containerId.equals("-1")) || (containerId.equals("0")))
            return null;
        if (containerId.equals("A"))
            return "M";
        if (containerId.equals("I"))
            return "P";
        if (containerId.equals("V")) {
            return "V";
        }
        return null;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.DirectoryObjectBuilder
* JD-Core Version:    0.6.2
*/