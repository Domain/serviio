module org.serviio.library.local.metadata.extractor.CoverImageInFolderExtractor;

import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.apache.sanselan.ImageInfo;
import org.apache.sanselan.ImageReadException;
import org.apache.sanselan.Sanselan;
import org.serviio.library.entities.Repository;
import org.serviio.library.local.metadata.AudioMetadata;
import org.serviio.library.local.metadata.ImageDescriptor;
import org.serviio.library.local.metadata.LocalItemMetadata;
import org.serviio.library.local.metadata.VideoMetadata;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.util.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CoverImageInFolderExtractor : AbstractLocalFileExtractor
{
  private static final Logger log = LoggerFactory.getLogger!(CoverImageInFolderExtractor)();

  private static final String[] AUDIO_FILES = { "folder.jpg", "cover.jpg", "front_cover.jpg", ".*\\[front\\].jpg", "albumart.jpg" };

  private static final String[] VIDEO_FILES = { "dvdcover.jpg", "folder.jpg", "movie.jpg", ".*poster.*.jpg" };
  private Pattern[] audioPatterns;
  private Pattern[] videoPatterns;

  public ExtractorType getExtractorType()
  {
    return ExtractorType.COVER_IMAGE_IN_FOLDER;
  }

  protected MetadataFile getMetadataFile(File mediaFile, MediaFileType fileType, Repository repository)
  {
    if ((fileType == MediaFileType.AUDIO) || (fileType == MediaFileType.VIDEO)) {
      final Pattern[] regexPatterns = precompileRegexPatterns(mediaFile, fileType);

      File folder = mediaFile.getParentFile();
      if ((folder !is null) && (folder.exists()) && (folder.isDirectory()))
      {
        File[] foundFiles = folder.listFiles(new class() FileFilter {
          public bool accept(File file)
          {
            return fileMatches(file, regexPatterns) > -1;
          }
        });
        if (foundFiles.length > 0)
        {
          File imageFile = findFileByPriority(foundFiles, regexPatterns);
          log.debug_(String.format("Found cover image %s", cast(Object[])[ imageFile.getName() ]));
          MetadataFile metadataFile = new MetadataFile(getExtractorType(), FileUtils.getLastModifiedDate(imageFile), imageFile.getName(), mediaFile);

          return metadataFile;
        }

        return null;
      }

      return null;
    }

    return null;
  }

  protected void retrieveMetadata(LocalItemMetadata metadata, File imageFile, File mediaFile)
  {
    try
    {
      ImageInfo imageInfo = Sanselan.getImageInfo(imageFile);
      ImageDescriptor image = new ImageDescriptor(FileUtils.readFileBytes(imageFile), imageInfo.getMimeType());
      if (( cast(AudioMetadata)metadata !is null ))
        (cast(AudioMetadata)metadata).setCoverImage(image);
      else if (( cast(VideoMetadata)metadata !is null ))
        (cast(VideoMetadata)metadata).setCoverImage(image);
    }
    catch (ImageReadException e) {
      throw new InvalidMediaFormatException(String.format("Cannot read cover image %s: %s", cast(Object[])[ imageFile.getName(), e.getMessage() ]));
    }
  }

  protected Pattern[] precompileRegexPatterns(File mediaFile, MediaFileType fileType)
  {
    Pattern[] compiledPatterns = null;
    if (fileType == MediaFileType.AUDIO) {
      if (audioPatterns is null) {
        audioPatterns = compilePatterns(AUDIO_FILES);
      }
      compiledPatterns = audioPatterns;
    } else {
      if (videoPatterns is null) {
        videoPatterns = compilePatterns(VIDEO_FILES);
      }
      compiledPatterns = new Pattern[videoPatterns.length + 1];
      String literalizedFileName = Pattern.quote(FileUtils.getFileNameWithoutExtension(mediaFile) + ".jpg");
      compiledPatterns[0] = Pattern.compile(literalizedFileName, 2);
      for (int i = 1; i < compiledPatterns.length; i++) {
        compiledPatterns[i] = videoPatterns[(i - 1)];
      }
    }

    return compiledPatterns;
  }

  protected int fileMatches(File f, Pattern[] regexPatterns)
  {
    for (int i = 0; i < regexPatterns.length; i++) {
      Pattern pattern = regexPatterns[i];
      Matcher m = pattern.matcher(f.getName());
      if (m.matches()) {
        return i;
      }
    }
    return -1;
  }

  private Pattern[] compilePatterns(String[] patterns)
  {
    Pattern[] result = new Pattern[patterns.length];
    for (int i = 0; i < patterns.length; i++) {
      result[i] = Pattern.compile(patterns[i], 2);
    }
    return result;
  }

  private File findFileByPriority(File[] files, Pattern[] regexPatterns) {
    SortedMap!(Integer, File) map = new TreeMap!(Integer, File)();
    foreach (File file ; files) {
      int index = fileMatches(file, regexPatterns);
      if (index > -1) {
        map.put(Integer.valueOf(index), file);
      }
    }
    return map.size() > 0 ? cast(File)map.get(map.firstKey()) : files[0];
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.CoverImageInFolderExtractor
 * JD-Core Version:    0.6.2
 */