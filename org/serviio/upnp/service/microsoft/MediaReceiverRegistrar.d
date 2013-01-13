module org.serviio.upnp.service.microsoft.MediaReceiverRegistrar;

import org.serviio.upnp.protocol.soap.OperationResult;
import org.serviio.upnp.protocol.soap.SOAPParameter;
import org.serviio.upnp.service.Service;

public class MediaReceiverRegistrar : Service
{
  protected void setupService()
  {
    serviceId = "urn:microsoft.com:serviceId:X_MS_MediaReceiverRegistrar";
    serviceType = "urn:microsoft.com:service:X_MS_MediaReceiverRegistrar:1";
  }

  public OperationResult IsAuthorized(/*@SOAPParameter("DeviceID")*/ String deviceId)
  {
    OperationResult result = new OperationResult();
    result.addOutputParameter("Result", new Integer(1));
    return result;
  }

  public OperationResult IsValidated(/*@SOAPParameter("DeviceID")*/ String deviceId)
  {
    OperationResult result = new OperationResult();
    result.addOutputParameter("Result", new Integer(1));
    return result;
  }

  public OperationResult RegisterDevice(/*@SOAPParameter("RegistrationReqMsg")*/ String message)
  {
    OperationResult result = new OperationResult();
    result.addOutputParameter("RegistrationRespMsg", "");
    return result;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.microsoft.MediaReceiverRegistrar
 * JD-Core Version:    0.6.2
 */