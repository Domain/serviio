module org.serviio.restlet.ServiioStatusService;

import java.io.FileNotFoundException;
import java.util.List;
import org.restlet.Request;
import org.restlet.Response;
import org.restlet.data.MediaType;
import org.restlet.data.Preference;
import org.restlet.data.Status;
import org.restlet.ext.gson.GsonRepresentation;
import org.restlet.representation.Representation;
import org.restlet.resource.ResourceException;
import org.restlet.service.StatusService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ServiioStatusService : StatusService
{
  private static final Logger log = LoggerFactory.getLogger!(ServiioStatusService)();

  public Representation getRepresentation(Status status, Request request, Response response)
  {
    if (status.getThrowable() !is null) {
      log.warn(String.format("%s occured. Returning error code %s to the REST layer. Message: %s", cast(Object[])[ status.getThrowable().getClass().getSimpleName(), Integer.valueOf(status.getCode()), status.getThrowable().getMessage() ]));

      log.debug_("Detailed exception: ", status.getThrowable());
    } else {
      log.warn(String.format("Returning error code to the REST layer: %s", cast(Object[])[ status.toString() ]));
    }
    response.setStatus(status);
    if ((status.getThrowable() !is null) && (( cast(AbstractRestfulException)status.getThrowable() !is null ))) {
      int errorCode = (cast(AbstractRestfulException)status.getThrowable()).getErrorCode();
      List!(String) parameters = (cast(AbstractRestfulException)status.getThrowable()).getParameters();
      ResultRepresentation r = responseError(Integer.valueOf(errorCode), status.getCode(), parameters);
      return buildResultRepresentation(request, r);
    }
    ResultRepresentation r = responseError(null, status.getCode(), null);
    return buildResultRepresentation(request, r);
  }

  public Status getStatus(Throwable throwable, Request request, Response response)
  {
    if (( cast(ResourceException)throwable !is null )) {
      ResourceException re = cast(ResourceException)throwable;
      return re.getStatus();
    }if (( cast(ValidationException)throwable !is null ))
      return new Status(Status.CLIENT_ERROR_BAD_REQUEST, throwable);
    if (( cast(HttpCodeException)throwable !is null ))
      return new Status((cast(HttpCodeException)throwable).getHttpCode(), throwable);
    if (( cast(AuthenticationException)throwable !is null ))
      return new Status(Status.CLIENT_ERROR_UNAUTHORIZED, throwable);
    if (( cast(FileNotFoundException)throwable !is null ))
      return new Status(Status.CLIENT_ERROR_NOT_FOUND, throwable);
    if (( cast(ServerUnavailableException)throwable !is null )) {
      return new Status(Status.SERVER_ERROR_SERVICE_UNAVAILABLE, throwable);
    }
    return new Status(Status.SERVER_ERROR_INTERNAL, throwable);
  }

  private ResultRepresentation responseError(Integer errorCode, int httpCode, List!(String) parameters)
  {
    return new ResultRepresentation(errorCode, httpCode, parameters);
  }

  private Representation buildResultRepresentation(Request request, ResultRepresentation r) {
    MediaType mt = null;

    List!(Preference!(MediaType)) acceptedMediaTypes = request.getClientInfo().getAcceptedMediaTypes();
    if ((acceptedMediaTypes !is null) && (acceptedMediaTypes.size() > 0)) {
      mt = cast(MediaType)(cast(Preference!(MediaType))acceptedMediaTypes.get(0)).getMetadata();
    }

    if ((mt !is null) && (mt.getName().startsWith(MediaType.APPLICATION_JSON.getName())))
    {
      return new GsonRepresentation!(ResultRepresentation)(r);
    }
    return new ServiioXstreamRepresentation!(ResultRepresentation)(mt, r);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.restlet.ServiioStatusService
 * JD-Core Version:    0.6.2
 */