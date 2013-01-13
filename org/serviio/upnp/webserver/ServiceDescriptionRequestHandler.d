module org.serviio.upnp.webserver.ServiceDescriptionRequestHandler;

import java.io.IOException;
import org.apache.http.HttpException;
import org.apache.http.HttpRequest;
import org.apache.http.HttpResponse;
import org.apache.http.entity.StringEntity;
import org.apache.http.protocol.HttpContext;
import org.serviio.upnp.Device;
import org.serviio.upnp.protocol.TemplateApplicator;
import org.serviio.upnp.service.Service;

public class ServiceDescriptionRequestHandler : AbstractDescriptionRequestHandler
{
  protected void handleRequest(HttpRequest request, HttpResponse response, HttpContext context)
  {
    String[] requestFields = getRequestPathFields(getRequestUri(request), "/serviceDescription", null);
    String serviceShortName = requestFields[0];

    if (serviceShortName !is null) {
      log.debug_(String.format("ServiceDescription request received for service %s", cast(Object[])[ serviceShortName ]));

      Device device = Device.getInstance();
      Service service = device.getServiceByShortName(serviceShortName);
      if (service !is null)
      {
        String message = null;
        if (service.getServiceType().equals("urn:schemas-upnp-org:service:ConnectionManager:1"))
          message = TemplateApplicator.applyTemplate("org/serviio/upnp/protocol/templates/serviceDescription-ConnectionManager.ftl", null);
        else if (service.getServiceType().equals("urn:schemas-upnp-org:service:ContentDirectory:1"))
          message = TemplateApplicator.applyTemplate("org/serviio/upnp/protocol/templates/serviceDescription-ContentDirectory.ftl", null);
        else if (service.getServiceType().equals("urn:microsoft.com:service:X_MS_MediaReceiverRegistrar:1")) {
          message = TemplateApplicator.applyTemplate("org/serviio/upnp/protocol/templates/serviceDescription-MediaReceiverRegistrar.ftl", null);
        }
        if (message !is null)
        {
          prepareSuccessfulHttpResponse(request, response);

          StringEntity body_ = new StringEntity(message, "UTF-8");
          body_.setContentType("text/xml");

          response.setEntity(body_);
          log.debug_("Sending ServiceDescription XML back");
        }
        else {
          response.setStatusCode(404);
          log.debug_(String.format("Service with name %s is not supported, sending back 404 error", cast(Object[])[ serviceShortName ]));
        }
      }
      else {
        response.setStatusCode(404);
        log.debug_(String.format("Service with name %s doesn't exist in the root device, sending back 404 error", cast(Object[])[ serviceShortName ]));
      }
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.webserver.ServiceDescriptionRequestHandler
 * JD-Core Version:    0.6.2
 */