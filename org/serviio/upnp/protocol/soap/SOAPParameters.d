module org.serviio.upnp.protocol.soap.SOAPParameters;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import org.serviio.upnp.protocol.soap.SOAPParameter;

/// FIXME:
//@Retention(RetentionPolicy.RUNTIME)
//@Target({java.lang.annotation.ElementType.PARAMETER})
public /*@*/interface SOAPParameters
{
  /*public abstract*/ SOAPParameter[] value();
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.soap.SOAPParameters
 * JD-Core Version:    0.6.2
 */