module org.serviio.util.UnicodeReader;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PushbackInputStream;
import java.io.Reader;

public class UnicodeReader : Reader
{
  private static final int BOM_SIZE = 4;
  private final InputStreamReader reader;

  public this(InputStream in_, String defaultEncoding)
  {
    byte[] bom = new byte[BOM_SIZE];

    PushbackInputStream pushbackStream = new PushbackInputStream(in_, BOM_SIZE);
    int n = pushbackStream.read(bom, 0, bom.length);
    int unread;
    String encoding;
    if ((bom[0] == -17) && (bom[1] == -69) && (bom[2] == -65)) {
      encoding = "UTF-8";
      unread = n - 3;
    }
    else
    {
      if ((bom[0] == -2) && (bom[1] == -1)) {
        encoding = "UTF-16BE";
        unread = n - 2;
      }
      else
      {
        if ((bom[0] == -1) && (bom[1] == -2)) {
          encoding = "UTF-16LE";
          unread = n - 2;
        }
        else
        {
          if ((bom[0] == 0) && (bom[1] == 0) && (bom[2] == -2) && (bom[3] == -1)) {
            encoding = "UTF-32BE";
            unread = n - 4;
          }
          else
          {
            if ((bom[0] == -1) && (bom[1] == -2) && (bom[2] == 0) && (bom[3] == 0)) {
              encoding = "UTF-32LE";
              unread = n - 4;
            } else {
              encoding = defaultEncoding;
              unread = n;
            }
          }
        }
      }
    }
    if (unread > 0)
      pushbackStream.unread(bom, n - unread, unread);
    else if (unread < -1) {
      pushbackStream.unread(bom, 0, 0);
    }

    if (encoding is null)
      reader = new InputStreamReader(pushbackStream);
    else
      reader = new InputStreamReader(pushbackStream, encoding);
  }

  public String getEncoding()
  {
    return reader.getEncoding();
  }

  public int read(char[] cbuf, int off, int len) {
    return reader.read(cbuf, off, len);
  }

  public void close() {
    reader.close();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.UnicodeReader
 * JD-Core Version:    0.6.2
 */