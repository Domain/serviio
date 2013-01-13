module org.serviio.util.ZipUtils;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.zip.GZIPInputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

public class ZipUtils
{
  public static InputStream unZipSingleFile(InputStream is_)
  {
    ZipInputStream zis = new ZipInputStream(is_);
    ZipEntry entry = zis.getNextEntry();
    if (entry is null) {
      throw new IOException("Invalid zip file");
    }
    byte[] unpackedFile = FileUtils.readFileBytes(zis);
    return new ByteArrayInputStream(unpackedFile);
  }

  public static InputStream unGzipSingleFile(InputStream is_) {
    GZIPInputStream zis = new GZIPInputStream(is_);
    byte[] unpackedFile = FileUtils.readFileBytes(zis);
    return new ByteArrayInputStream(unpackedFile);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.ZipUtils
 * JD-Core Version:    0.6.2
 */