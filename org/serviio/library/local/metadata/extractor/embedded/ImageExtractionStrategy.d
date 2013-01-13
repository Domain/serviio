module org.serviio.library.local.metadata.extractor.embedded.ImageExtractionStrategy;

import java.io.IOException;
import org.apache.sanselan.ImageInfo;
import org.apache.sanselan.ImageReadException;
import org.apache.sanselan.Sanselan;
import org.apache.sanselan.common.byteSources.ByteSource;
import org.serviio.dlna.ImageContainer;
import org.serviio.library.local.metadata.ImageMetadata;
import org.serviio.library.local.metadata.extractor.InvalidMediaFormatException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class ImageExtractionStrategy
{
  private static final Logger log = LoggerFactory.getLogger!(ImageExtractionStrategy);

  public void extractMetadata(ImageMetadata metadata, ByteSource f)
  {
    log.debug_(String.format("Extracting metadata of image file: %s", cast(Object[])[ f.getFilename() ]));
    try
    {
      ImageInfo imageInfo = Sanselan.getImageInfo(f.getInputStream(), f.getFilename());

      if (imageInfo !is null) {
        metadata.setWidth(Integer.valueOf(imageInfo.getWidth()));
        metadata.setHeight(Integer.valueOf(imageInfo.getHeight()));
        metadata.setColorDepth(Integer.valueOf(imageInfo.getBitsPerPixel()));
      }

      metadata.setContainer(getContainer());
    } catch (ImageReadException e) {
      throw new IOException(String.format("Cannot read file %s for metadata extraction: %s", cast(Object[])[ f.getFilename(), e.getMessage() ]), e);
    }
    catch (OutOfMemoryError e)
    {
      throw new IOException(String.format("Cannot read file %s for metadata extraction because of out-of-memory error", cast(Object[])[ f.getFilename() ]), e);
    }
  }

  protected abstract ImageContainer getContainer();
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.ImageExtractionStrategy
 * JD-Core Version:    0.6.2
 */