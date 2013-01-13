module org.serviio.library.local.metadata.extractor.embedded.JPEGExtractionStrategy;

import java.io.IOException;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import org.apache.sanselan.ImageReadException;
import org.apache.sanselan.Sanselan;
import org.apache.sanselan.common.IImageMetadata;
import org.apache.sanselan.common.byteSources.ByteSource;
import org.apache.sanselan.formats.jpeg.JpegImageMetadata;
import org.apache.sanselan.formats.tiff.TiffField;
import org.apache.sanselan.formats.tiff.constants.TiffConstants;
import org.serviio.dlna.ImageContainer;
import org.serviio.dlna.SamplingMode;
import org.serviio.library.local.metadata.ImageMetadata;
import org.serviio.library.local.metadata.extractor.InvalidMediaFormatException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class JPEGExtractionStrategy : ImageExtractionStrategy
{
  private static DateFormat exifDF = new SimpleDateFormat("''yyyy:MM:dd HH:mm:ss''");

  private static final Logger log = LoggerFactory.getLogger!(JPEGExtractionStrategy);

  public void extractMetadata(ImageMetadata metadata, ByteSource f)
  {
    super.extractMetadata(metadata, f);
    try
    {
      IImageMetadata imageMetadata = Sanselan.getMetadata(f.getInputStream(), f.getFilename());

      if ((imageMetadata !is null) && (( cast(JpegImageMetadata)imageMetadata !is null ))) {
        JpegImageMetadata jpegMetadata = cast(JpegImageMetadata)imageMetadata;

        TiffField dateField = jpegMetadata.findEXIFValue(TiffConstants.EXIF_TAG_DATE_TIME_ORIGINAL);
        if (dateField is null) {
          dateField = jpegMetadata.findEXIFValue(TiffConstants.EXIF_TAG_MODIFY_DATE);
        }
        Date createdDate = dateField !is null ? exifDF.parse(dateField.getValueDescription()) : null;
        metadata.setDate(createdDate);
        metadata.setExifRotation(getRotation(jpegMetadata));
      }
      try
      {
        JPEGSamplingTypeReader.JpegImageParams params = JPEGSamplingTypeReader.getJpegImageData(f.getInputStream(), f.getFilename());
        metadata.setChromaSubsampling(params.getSamplingMode());
      }
      catch (Exception e) {
        metadata.setChromaSubsampling(SamplingMode.UNKNOWN);
      }
    } catch (ImageReadException e) {
      log.debug_(String.format("Cannot read file %s for metadata extraction. Message: %s", cast(Object[])[ f.getFilename(), e.getMessage() ]));
    } catch (ParseException e) {
    }
    catch (OutOfMemoryError e) {
      log.debug_(String.format("Cannot get metadata of file %s because of OutOfMemory error. The file is dodgy, but will still be added to the library.", cast(Object[])[ f.getFilename() ]));
    } catch (IOException e) {
      log.debug_(String.format("Cannot read EXIF metadata for file %s. Message: %s", cast(Object[])[ f.getFilename(), e.getMessage() ]));
    }
  }

  protected ImageContainer getContainer()
  {
    return ImageContainer.JPEG;
  }

  protected Integer getRotation(JpegImageMetadata jpegMetadata)
  {
    TiffField rotation = jpegMetadata.findEXIFValue(TiffConstants.EXIF_TAG_ORIENTATION);
    if (rotation !is null) {
      if (rotation.getIntValue() == 3)
        return Integer.valueOf(180);
      if (rotation.getIntValue() == 8)
        return Integer.valueOf(270);
      if (rotation.getIntValue() == 6) {
        return Integer.valueOf(90);
      }
      return Integer.valueOf(0);
    }

    return Integer.valueOf(0);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.JPEGExtractionStrategy
 * JD-Core Version:    0.6.2
 */