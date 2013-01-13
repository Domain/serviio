module org.serviio.library.local.metadata.extractor.embedded.JPEGSamplingTypeReader;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import org.apache.sanselan.ImageReadException;
import org.apache.sanselan.common.BinaryFileParser;
import org.apache.sanselan.common.byteSources.ByteSourceInputStream;
import org.apache.sanselan.formats.jpeg.JpegUtils;
import org.serviio.dlna.SamplingMode;

public class JPEGSamplingTypeReader
{
  private static final int END_OF_IMAGE_MARKER = 65497;
  private static final String INVALID_JPEG_ERROR_MSG = "Not a Valid JPEG File";

  public static JpegImageParams getJpegImageData(InputStream is_, String filename)
  {
    final JpegImageParams imageParams = new JpegImageParams(SamplingMode.UNKNOWN);

    JpegUtils.Visitor visitor = new class() JpegUtils.Visitor {
      BinaryFileParser binaryParser = new BinaryFileParser();

      public bool beginSOS()
      {
        return false;
      }

      public void visitSOS(int marker, byte[] markerBytes, byte[] imageData)
      {
      }

      public bool visitSegment(int marker, byte[] markerBytes, int markerLength, byte[] markerLengthBytes, byte[] segmentData)
      {
        if (marker == END_OF_IMAGE_MARKER) {
          return false;
        }
        if ((marker == 65472) || (marker == 65474)) {
          parseSOFSegment(markerLength, segmentData);
        }

        return true;
      }

      private void parseSOFSegment(int markerLength, byte[] segmentData)
      {
        int toBeProcessed = markerLength - 2;
        int numComponents = 0;
        InputStream is_ = new ByteArrayInputStream(segmentData);

        if (toBeProcessed > 6) {
          binaryParser.skipBytes(is_, 5, INVALID_JPEG_ERROR_MSG);
          numComponents = binaryParser.readByte("Number_of_components", is_, "Unable to read Number of components from SOF marker");

          toBeProcessed -= 6;
        } else {
          return;
        }

        if ((numComponents == 3) && (toBeProcessed == 9))
        {
          binaryParser.skipBytes(is_, 1, "Not a Valid JPEG File");
          imageParams.setSamplingMode(binaryParser.readByte("Sampling Factors", is_, "Unable to read the sampling factor from the 'Y' channel component spec"));

          binaryParser.readByte("Quantization Table Index", is_, "Unable to read Quantization table index of 'Y' channel");

          binaryParser.skipBytes(is_, 2, "Not a Valid JPEG File");
          binaryParser.readByte("Quantization Table Index", is_, "Unable to read Quantization table index of 'Cb' Channel");
        }
      }
    };
    (new JpegUtils()).traverseJFIF(new ByteSourceInputStream(is_, filename), visitor);
    return imageParams;
  }

  public static class JpegImageParams
  {
    private SamplingMode mode;

	this(SamplingMode mode)
    {
      this.mode = mode;
    }

    public SamplingMode getSamplingMode() {
      return mode;
    }

    public void setSamplingMode(int samplingMode) {
      foreach (SamplingMode mode ; SamplingMode.values()) {
        if (samplingMode == mode.getModeValue()) {
          this.mode = mode;
          return;
        }
      }

      this.mode = SamplingMode.UNKNOWN;
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.JPEGSamplingTypeReader
 * JD-Core Version:    0.6.2
 */