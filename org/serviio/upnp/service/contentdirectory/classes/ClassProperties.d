module org.serviio.upnp.service.contentdirectory.classes.ClassProperties;

public class ClassProperties
{
	enum ClassPropertiesEnum : String
	{
		OBJECT_CLASS = "objectClass", 
		ID = "id", 
		PARENT_ID = "parentID", 
		TITLE = "title", 
		CREATOR = "creator", 
		GENRE = "genre", 
		CHILD_COUNT = "childCount", 
		REF_ID = "refID", 
		DESCRIPTION = "description", 
		LONG_DESCRIPTION = "longDescription", 
		LANGUAGE = "language", 
		PUBLISHER = "publishers", 
		ACTOR = "actors", 
		DIRECTOR = "directors", 
		PRODUCER = "producers", 
		ARTIST = "artist", 
		RIGHTS = "rights", 
		RATING = "rating", 
		RESTRICTED = "restricted", 
		SEARCHABLE = "searchable", 
		ALBUM = "album", 
		RESOURCE_URL = "resource.generatedURL", 
		RESOURCE_SIZE = "resource.size", 
		RESOURCE_DURATION = "resource.durationFormatted", 
		RESOURCE_BITRATE = "resource.bitrate", 
		RESOURCE_PROTOCOLINFO = "resource.protocolInfo", 
		RESOURCE_CHANNELS = "resource.nrAudioChannels", 
		RESOURCE_SAMPLE_FREQUENCY = "resource.sampleFrequency", 
		RESOURCE_RESOLUTION = "resource.resolution", 
		RESOURCE_COLOR_DEPTH = "resource.colorDepth", 
		ORIGINAL_TRACK_NUMBER = "originalTrackNumber", 
		DATE = "date", 
		ALBUM_ART_URI = "albumArtURIResource.generatedURL", 
		ICON = "icon.generatedURL", 
		SUBTITLES_URL = "subtitlesUrlResource.generatedURL", 
		DCM_INFO = "dcmInfo", 
		MEDIA_CLASS = "mediaClass", 
		LIVE = "live", 
		ONLINE_DB_IDENTIFIERS = "onlineIdentifiers", 
		CONTENT_TYPE = "contentType",
	}

	ClassPropertiesEnum classProperties;
	alias classProperties this;

  public String getAttributeName()
  {
	  return cast(String)classProperties;
  }

  public String[] getPropertyFilterNames()
  {
	  switch (classProperties)
	  {
		  case OBJECT_CLASS:
			  return cast(String[])[ "upnp:class" ]; 

		  case ID:
			  return cast(String[])[ "@id" ]; 

		  case PARENT_ID:
			  return cast(String[])[ "@parentID" ]; 

		  case TITLE:
			  return cast(String[])[ "dc:title" ]; 

		  case CREATOR:
			  return cast(String[])[ "dc:creator" ]; 

		  case GENRE:
			  return cast(String[])[ "upnp:genre" ]; 

		  case CHILD_COUNT:
			  return cast(String[])[ "@childCount" ]; 

		  case REF_ID:
			  return cast(String[])[ "@refID" ]; 

		  case DESCRIPTION:
			  return cast(String[])[ "dc:description" ]; 

		  case LONG_DESCRIPTION:
			  return cast(String[])[ "upnp:longDescription" ]; 

		  case LANGUAGE:
			  return cast(String[])[ "dc:language" ]; 

		  case PUBLISHER:
			  return cast(String[])[ "dc:publisher" ]; 

		  case ACTOR:
			  return cast(String[])[ "upnp:actor" ]; 

		  case DIRECTOR:
			  return cast(String[])[ "upnp:director" ]; 

		  case PRODUCER:
			  return cast(String[])[ "upnp:producer" ]; 

		  case ARTIST:
			  return cast(String[])[ "upnp:artist" ]; 

		  case RIGHTS:
			  return cast(String[])[ "dc:rights" ]; 

		  case RATING:
			  return cast(String[])[ "upnp:rating" ]; 

		  case RESTRICTED:
			  return cast(String[])[ "@restricted" ]; 

		  case SEARCHABLE:
			  return cast(String[])[ "@searchable" ]; 

		  case ALBUM:
			  return cast(String[])[ "upnp:album" ]; 

		  case RESOURCE_URL:
			  return cast(String[])[ "res" ]; 

		  case RESOURCE_SIZE:
			  return cast(String[])[ "res@size" ]; 

		  case RESOURCE_DURATION:
			  return cast(String[])[ "res@duration" ]; 

		  case RESOURCE_BITRATE:
			  return cast(String[])[ "res@bitrate" ]; 

		  case RESOURCE_PROTOCOLINFO:
			  return cast(String[])[ "res@protocolInfo" ]; 

		  case RESOURCE_CHANNELS:
			  return cast(String[])[ "res@nrAudioChannels" ]; 

		  case RESOURCE_SAMPLE_FREQUENCY:
			  return cast(String[])[ "res@sampleFrequency" ]; 

		  case RESOURCE_RESOLUTION:
			  return cast(String[])[ "res@resolution" ]; 

		  case RESOURCE_COLOR_DEPTH:
			  return cast(String[])[ "res@colorDepth" ]; 

		  case ORIGINAL_TRACK_NUMBER:
			  return cast(String[])[ "upnp:originalTrackNumber" ]; 

		  case DATE:
			  return cast(String[])[ "dc:date" ]; 

		  case ALBUM_ART_URI:
			  return cast(String[])[ "upnp:albumArtURI" ]; 

		  case ICON:
			  return cast(String[])[ "upnp:icon" ]; 

		  case SUBTITLES_URL:
			  return cast(String[])[ "sec:CaptionInfoEx", "res@pv:subtitleFileUri" ]; 

		  case DCM_INFO:
			  return cast(String[])[ "sec:dcmInfo" ]; 

		  case MEDIA_CLASS:
			  return cast(String[])[ "av:mediaClass" ]; 

		  case LIVE:
			  return new String[0]; 

		  case ONLINE_DB_IDENTIFIERS:
			  return new String[0]; 

		  case CONTENT_TYPE:
			  return new String[0];
	  }
	  return null;
  }

  public String getFirstPropertyXMLName()
  {
    int attributeSep = getPropertyFilterNames()[0].indexOf("@");
    if (attributeSep > -1) {
      return getPropertyFilterNames()[0].substring(attributeSep + 1);
    }
    return getPropertyFilterNames()[0];
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.ClassProperties
 * JD-Core Version:    0.6.2
 */