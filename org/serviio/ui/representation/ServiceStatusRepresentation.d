module org.serviio.ui.representation.ServiceStatusRepresentation;

import org.serviio.MediaServer;

public class ServiceStatusRepresentation
{
  private bool serviceStarted = !MediaServer.isServiceInitializationInProcess();

  public bool isServiceStarted()
  {
    return serviceStarted;
  }

  public void setServiceStarted(bool serviceStarted) {
    this.serviceStarted = serviceStarted;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.representation.ServiceStatusRepresentation
 * JD-Core Version:    0.6.2
 */