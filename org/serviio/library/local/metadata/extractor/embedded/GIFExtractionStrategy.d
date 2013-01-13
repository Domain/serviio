module org.serviio.library.local.metadata.extractor.embedded.GIFExtractionStrategy;

import java.io.IOException;
import org.apache.sanselan.common.byteSources.ByteSource;
import org.serviio.dlna.ImageContainer;
import org.serviio.library.local.metadata.ImageMetadata;
import org.serviio.library.local.metadata.extractor.InvalidMediaFormatException;

public class GIFExtractionStrategy : ImageExtractionStrategy
{
  public void extractMetadata(ImageMetadata metadata, ByteSource f)
  {
    super.extractMetadata(metadata, f);
  }

  protected ImageContainer getContainer()
  {
    return ImageContainer.GIF;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.GIFExtractionStrategy
 * JD-Core Version:    0.6.2
 */