module org.serviio.library.local.metadata.extractor.AbstractLocalFileExtractor;

import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import java.util.Date;
import java.util.regex.Pattern;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.entities.MetadataDescriptor;
import org.serviio.library.local.metadata.LocalItemMetadata;
import org.serviio.util.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class AbstractLocalFileExtractor : MetadataExtractor
{
  protected final Logger log = LoggerFactory.getLogger(getClass());

  public bool isMetadataUpdated(File mediaFile, MediaItem mediaItem, MetadataDescriptor metadataDescriptor)
  {
    if (metadataDescriptor !is null)
    {
      File metadataFile = new File(mediaFile.getParentFile(), metadataDescriptor.getIdentifier());
      if ((metadataFile !is null) && (metadataFile.exists())) {
        Date imageFileDate = FileUtils.getLastModifiedDate(metadataFile);

        if (imageFileDate.after(metadataDescriptor.getDateUpdated())) {
          return true;
        }
        return false;
      }

      return true;
    }

    try
    {
      return getMetadataFile(mediaFile, mediaItem.getFileType(), null) !is null; } catch (IOException e) {
    }
    return false;
  }

  protected void retrieveMetadata(MetadataFile metadataDescriptor, LocalItemMetadata metadata)
  {
    if (metadataDescriptor.getExtractorType() == getExtractorType())
    {
      File mediaFile = cast(File)metadataDescriptor.getExtractable();
      File metadataFile = new File(mediaFile.getParentFile(), metadataDescriptor.getIdentifier());
      if (metadataFile.exists())
        retrieveMetadata(metadata, metadataFile, mediaFile);
      else
        log.warn(String.format("Metadata file '%s' has not been found", cast(Object[])[ metadataFile.getPath() ]));
    }
  }

  protected abstract void retrieveMetadata(LocalItemMetadata paramLocalItemMetadata, File paramFile1, File paramFile2);

  protected File findFileInFolder(File folder, String fileName, final bool includeHidden)
  {
    final Pattern fileNamePattern = Pattern.compile(Pattern.quote(fileName), 2);
    File[] foundFiles = folder.listFiles(new class() FileFilter {
      public bool accept(File file) {
        if (((!includeHidden) && (!file.isHidden())) || (includeHidden)) {
          return fileNamePattern.matcher(file.getName()).matches();
        }
        return false;
      }
    });
    if ((foundFiles !is null) && (foundFiles.length > 0)) {
      return foundFiles[0];
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.AbstractLocalFileExtractor
 * JD-Core Version:    0.6.2
 */