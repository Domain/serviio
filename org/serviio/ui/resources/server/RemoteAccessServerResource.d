module org.serviio.ui.resources.server.RemoteAccessServerResource;

import java.util.Collections;
import java.util.List;
import org.restlet.data.Method;
import org.serviio.config.Configuration;
import org.serviio.restlet.AbstractProEditionServerResource;
import org.serviio.restlet.ResultRepresentation;
import org.serviio.restlet.ValidationException;
import org.serviio.ui.representation.RemoteAccessRepresentation;
import org.serviio.ui.resources.RemoteAccessResource;
import org.serviio.util.ObjectValidator;

public class RemoteAccessServerResource : AbstractProEditionServerResource
  , RemoteAccessResource
{
  public ResultRepresentation save(RemoteAccessRepresentation representation)
  {
    bool cleanCache = false;

    if (ObjectValidator.isEmpty(representation.getRemoteUserPassword())) {
      throw new ValidationException(504);
    }
    Configuration.setWebPassword(representation.getRemoteUserPassword());

    if (Configuration.getRemotePreferredDeliveryQuality() != representation.getPreferredRemoteDeliveryQuality()) {
      Configuration.setRemotePreferredDeliveryQuality(representation.getPreferredRemoteDeliveryQuality());
      cleanCache = true;
    }

    if (cleanCache) {
      getCDS().incrementUpdateID();
    }

    return responseOk();
  }

  public RemoteAccessRepresentation load()
  {
    RemoteAccessRepresentation rar = new RemoteAccessRepresentation();
    rar.setRemoteUserPassword(Configuration.getWebPassword());
    rar.setPreferredRemoteDeliveryQuality(Configuration.getRemotePreferredDeliveryQuality());
    return rar;
  }

  protected List!(Method) getRestrictedMethods()
  {
    return Collections.singletonList(Method.PUT);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.resources.server.RemoteAccessServerResource
 * JD-Core Version:    0.6.2
 */