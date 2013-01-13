module org.serviio.external.io.OutputBytesReader;

import java.lang.String;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.serviio.external.io.OutputReader;

public class OutputBytesReader : OutputReader
{
  private static immutable Logger log = LoggerFactory.getLogger!(OutputBytesReader);
  private ByteArrayOutputStream outputStream;

  public this(InputStream inputStream)
  {
    super(inputStream);
    outputStream = new ByteArrayOutputStream();
  }

  protected void processOutput()
  {
    try
    {
      byte[] buf = new byte[500000];
      int n = 0;
      while ((n = inputStream.read(buf)) > 0)
        outputStream.write(buf, 0, n);
    }
    catch (IOException e) {
      log.warn(String.format("Error reading bytes stream from external process: %s" + e.getMessage(), new Object[0]));
    }
  }

  public ByteArrayOutputStream getOutputStream() {
    return outputStream;
  }

  public List!(String) getResults() {
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.external.io.OutputBytesReader
 * JD-Core Version:    0.6.2
 */