module org.serviio.library.metadata.SanselanMetadataRetriever;

import java.io.File;
import java.io.IOException;
import org.apache.sanselan.ImageFormat;
import org.apache.sanselan.ImageReadException;
import org.apache.sanselan.Sanselan;
import org.apache.sanselan.common.byteSources.ByteSource;
import org.apache.sanselan.common.byteSources.ByteSourceFile;
import org.apache.sanselan.common.byteSources.ByteSourceInputStream;
import org.serviio.library.local.metadata.ImageMetadata;
import org.serviio.library.local.metadata.extractor.InvalidMediaFormatException;
import org.serviio.library.local.metadata.extractor.embedded.EmbeddedMetadataExtractor;
import org.serviio.library.local.metadata.extractor.embedded.GIFExtractionStrategy;
import org.serviio.library.local.metadata.extractor.embedded.ImageExtractionStrategy;
import org.serviio.library.local.metadata.extractor.embedded.JPEGExtractionStrategy;
import org.serviio.library.local.metadata.extractor.embedded.PNGExtractionStrategy;
import org.serviio.util.HttpClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SanselanMetadataRetriever
{
  private static final Logger log = LoggerFactory.getLogger!(EmbeddedMetadataExtractor)();

  public static void retrieveImageMetadata(ImageMetadata md, String imageLocation, bool local)
  {
    ByteSource byteSource = null;
    if (local)
      byteSource = new ByteSourceFile(new File(imageLocation));
    else
      byteSource = new ByteSourceInputStream(HttpClient.retrieveBinaryStreamFromURL(imageLocation), imageLocation);
    try
    {
      ImageExtractionStrategy strategy = null;

      ImageFormat imageFormat = Sanselan.guessFormat(byteSource);
      if (imageFormat == ImageFormat.IMAGE_FORMAT_JPEG)
        strategy = new JPEGExtractionStrategy();
      else if (imageFormat == ImageFormat.IMAGE_FORMAT_PNG)
        strategy = new PNGExtractionStrategy();
      else if (imageFormat == ImageFormat.IMAGE_FORMAT_GIF)
        strategy = new GIFExtractionStrategy();
      else {
        throw new InvalidMediaFormatException(String.format("File %s has unsupported image format", cast(Object[])[ byteSource.getFilename() ]));
      }

      strategy.extractMetadata(md, byteSource);
    } catch (ImageReadException e) {
      log.warn(String.format("Cannot read image file %s", cast(Object[])[ imageLocation ]));
      throw new InvalidMediaFormatException(e.getMessage(), e);
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.metadata.SanselanMetadataRetriever
 * JD-Core Version:    0.6.2
 */