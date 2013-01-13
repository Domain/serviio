module org.serviio.library.metadata.MediaFileType;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;
import org.serviio.util.CollectionUtils;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;

import java.lang.String;

public class MediaFileType
{
	enum MediaFileTypeEnum
	{
		IMAGE, 
		VIDEO, 
		AUDIO,
	}

	MediaFileTypeEnum mediaFileType;
	alias mediaFileType this;

  public String[] supportedFileExtensions()
  {
	  switch (mediaFileType)
	  {
		  case IMAGE:
			  return cast(String[])[ "jpg", "jpeg", "png", "gif", "arw", "cr2", "crw", "dng", "raf", "raw", "rw2", "mrw", "nef", "nrw", "pef", "srf", "orf" ]; 

		  case VIDEO:
			  return cast(String[])[ "mpg", "mpeg", "vob", "avi", "mp4", "m4v", "ts", "wmv", "asf", "mkv", "divx", "m2ts", "mts", "mov", "mod", "tp", "trp", "vdr", "flv", "f4v", "dvr", "dvr-ms", "wtv", "ogv", "ogm", "3gp", "rm", "rmvb" ]; 

		  case AUDIO:
			  return cast(String[])[ "mp3", "wma", "m4a", "flac", "ogg", "oga" ];
	  }
	  return null;
  }

  public static MediaFileType findMediaFileTypeByExtension(String extension)
  {
    foreach (MediaFileType mediaFileType ; values()) {
      foreach (String supportedExtension ; mediaFileType.supportedFileExtensions()) {
        if (extension.equalsIgnoreCase(supportedExtension)) {
          return mediaFileType;
        }
      }
    }
    return null;
  }

  public static MediaFileType findMediaFileTypeByMimeType(String mimeType)
  {
    if (ObjectValidator.isNotEmpty(mimeType)) {
      String mimeTypeLC = StringUtils.localeSafeToLowercase(mimeType);
      if (mimeTypeLC.startsWith("audio"))
        return AUDIO;
      if (mimeTypeLC.startsWith("image"))
        return IMAGE;
      if (mimeTypeLC.startsWith("video")) {
        return VIDEO;
      }
    }
    return null;
  }

  public static Set!(MediaFileType) parseMediaFileTypesFromString(String fileTypesCSV) {
    Set!(MediaFileType) result = new HashSet!(MediaFileType)();
    if (ObjectValidator.isNotEmpty(fileTypesCSV)) {
      String[] fileTypes = fileTypesCSV.split(",");
      foreach (String fileType ; fileTypes) {
        result.add(valueOf(StringUtils.localeSafeToUppercase(fileType.trim())));
      }
    }
    return result;
  }

  public static String parseMediaFileTypesToString(Set!(MediaFileType) fileTypes) {
    return CollectionUtils.listToCSV(new ArrayList!(MediaFileType)(fileTypes), ",", true);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.metadata.MediaFileType
 * JD-Core Version:    0.6.2
 */