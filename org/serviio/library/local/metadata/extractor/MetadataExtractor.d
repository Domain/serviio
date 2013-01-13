module org.serviio.library.local.metadata.extractor.MetadataExtractor;

import java.io.File;
import java.io.IOException;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.entities.MetadataDescriptor;
import org.serviio.library.entities.Repository;
import org.serviio.library.local.metadata.LocalItemMetadata;
import org.serviio.library.local.metadata.MetadataFactory;
import org.serviio.library.metadata.MediaFileType;

public abstract class MetadataExtractor
{
  public LocalItemMetadata extract(File mediaFile, MediaFileType fileType, Repository repository)
  {
    LocalItemMetadata metadata = MetadataFactory.getMetadataInstance(fileType);
    MetadataFile metadataFile = getMetadataFile(mediaFile, fileType, repository);
    if (metadataFile !is null) {
      metadata.getMetadataFiles().add(metadataFile);
      retrieveMetadata(metadataFile, metadata);

      metadataFile = null;
      return metadata;
    }
    return null;
  }

  public abstract ExtractorType getExtractorType();

  public abstract bool isMetadataUpdated(File paramFile, MediaItem paramMediaItem, MetadataDescriptor paramMetadataDescriptor);

  protected abstract MetadataFile getMetadataFile(File paramFile, MediaFileType paramMediaFileType, Repository paramRepository);

  protected abstract void retrieveMetadata(MetadataFile paramMetadataFile, LocalItemMetadata paramLocalItemMetadata);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.MetadataExtractor
 * JD-Core Version:    0.6.2
 */