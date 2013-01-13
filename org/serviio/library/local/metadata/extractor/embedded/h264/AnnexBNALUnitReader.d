module org.serviio.library.local.metadata.extractor.embedded.h264.AnnexBNALUnitReader;

import java.io.IOException;
import java.util.Arrays;

public class AnnexBNALUnitReader
  : NALUnitReader
{
  private final BufferWrapper src;

  public this(BufferWrapper src)
  {
    this.src = src;
  }

  public BufferWrapper nextNALUnit() {
    if (src.remaining() < 5L) {
      return null;
    }

    long start = -1L;
    do {
      byte[] marker = new byte[4];
      if (src.remaining() >= 4L) {
        src.read(marker);
        if (Arrays.equals(cast(byte[])[ 0, 0, 0, 1 ], marker)) {
          if (start == -1L) {
            start = src.position();
          } else {
            src.position(src.position() - 4L);
            return src.getSegment(start, src.position() - start);
          }
        }
        else src.position(src.position() - 3L);
      }
      else
      {
        return src.getSegment(start, src.size() - start);
      }
    }
    while (src.remaining() > 0L);
    return src.getSegment(start, src.position());
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.h264.AnnexBNALUnitReader
 * JD-Core Version:    0.6.2
 */