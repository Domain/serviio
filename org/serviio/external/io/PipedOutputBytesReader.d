module org.serviio.external.io.PipedOutputBytesReader;

import java.lang.String;
import java.io.IOException;
import java.io.InputStream;
import java.io.PipedOutputStream;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.serviio.external.io.OutputReader;

public class PipedOutputBytesReader : OutputReader
{
  private static immutable Logger log = LoggerFactory.getLogger!(PipedOutputBytesReader);
  private PipedOutputStream outputStream;

  public this(InputStream inputStream)
  {
    super(inputStream);
    outputStream = new PipedOutputStream();
  }

  protected void processOutput()
  {
    try
    {
      byte[] buf = new byte[500000];
      int n = 0;
      while ((n = inputStream.read(buf)) > 0)
        try {
          outputStream.write(buf, 0, n);
        } catch (IOException e) {
          log.trace(String.format("Error writing bytes to piped output stream: %s", cast(Object[])[ e.getMessage() ]));
        }
    }
    catch (IOException e) {
      log.warn(String.format("Error reading bytes stream from external process: %s", cast(Object[])[ e.getMessage() ]));
    }
  }

  public PipedOutputStream getOutputStream() {
    return outputStream;
  }

  public List!(String) getResults() {
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.external.io.PipedOutputBytesReader
 * JD-Core Version:    0.6.2
 */