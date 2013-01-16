module org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;

import java.lang.String;

public class ObjectClassType
{
	enum ObjectClassTypeEnum : String
	{
		CONTAINER = "object.container", 
		AUDIO_ITEM = "object.item.audioItem", 
		VIDEO_ITEM = "object.item.videoItem", 
		IMAGE_ITEM = "object.item.imageItem", 
		MOVIE = "object.item.videoItem.movie", 
		MUSIC_TRACK = "object.item.audioItem.musicTrack", 
		PHOTO = "object.item.imageItem.photo", 
		PLAYLIST_ITEM = "object.container", 
		PLAYLIST_CONTAINER = "object.container.playlistContainer", 
		PERSON = "object.container.person", 
		MUSIC_ARTIST = "object.container.person.musicArtist", 
		GENRE = "object.container.genre", 
		MUSIC_GENRE = "object.container.genre.musicGenre", 
		ALBUM = "object.container.album", 
		MUSIC_ALBUM = "object.container.album.musicAlbum", 
		STORAGE_FOLDER = "object.container.storageFolder",
	}

	ObjectClassTypeEnum objectClassType;
	alias objectClassType this;

  public String getClassName()
  {
	  return cast(String)objectClassType;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.ObjectClassType
 * JD-Core Version:    0.6.2
 */