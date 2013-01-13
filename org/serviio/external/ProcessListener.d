module org.serviio.external.ProcessListener;

import java.lang.String;
import org.serviio.external.ProcessExecutor;

public abstract class ProcessListener
{
  private ProcessExecutor processExecutor;
  protected bool finished = false;

  public abstract void processEnded(bool paramBoolean);

  public abstract void outputUpdated(String paramString);

  public abstract void releaseResources();

  public ProcessExecutor getExecutor()
  {
    return processExecutor;
  }

  public void setExecutor(ProcessExecutor executor) {
    processExecutor = executor;
  }

  public bool isFinished() {
    return finished;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.external.ProcessListener
 * JD-Core Version:    0.6.2
 */