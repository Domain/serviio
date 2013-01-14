module org.serviio.library.local.metadata.MetadataFactory;

import org.serviio.library.metadata.MediaFileType;
import org.serviio.library.local.metadata.LocalItemMetadata;

public class MetadataFactory
{
  public static LocalItemMetadata getMetadataInstance(MediaFileType fileType)
  {
    if (fileType == MediaFileType.AUDIO)
      return new AudioMetadata();
    if (fileType == MediaFileType.VIDEO) {
      return new VideoMetadata();
    }
    return new ImageMetadata();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.MetadataFactory
 * JD-Core Version:    0.6.2
 */