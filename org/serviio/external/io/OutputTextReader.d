module org.serviio.external.io.OutputTextReader;

import java.lang.String;
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;
import org.serviio.external.ProcessExecutor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class OutputTextReader : OutputReader
{
  private static immutable Logger log = LoggerFactory.getLogger!(OutputTextReader);

  private List!(String) lines = new ArrayList!(String)();
  private Object linesLock;
  private ProcessExecutor executor;

  public this(ProcessExecutor executor, InputStream inputStream)
  {
    super(inputStream);
    linesLock = new Object();
    this.executor = executor;
  }

  protected void processOutput()
  {
    BufferedReader br = null;
    try {
      br = new BufferedReader(new InputStreamReader(inputStream, Charset.defaultCharset()));
      String line = null;
      while ((line = br.readLine()) !is null)
        if (line.length() > 0) {
          addLine(line);

          executor.notifyListenersOutputUpdated(line);

          log.trace(line);
        }
    }
    catch (IOException e) {
      log.warn(String.format("Error reading output of an external command:" + e.getMessage(), new Object[0]));
    } finally {
      if (br !is null)
        try {
          br.close(); } catch (Exception e) {
        }
    }
  }

  public ByteArrayOutputStream getOutputStream() {
    return null;
  }

  public List!(String) getResults() {
    List!(String) clonedResults = new ArrayList!(String)();
    synchronized (linesLock) {
      clonedResults.addAll(lines);
    }
    return clonedResults;
  }

  private void addLine(String line)
  {
    synchronized (linesLock) {
      lines.add(line);
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.external.io.OutputTextReader
 * JD-Core Version:    0.6.2
 */