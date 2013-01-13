module org.serviio.restlet.ServiioXstreamConverter;

import org.restlet.data.MediaType;
import org.restlet.ext.xstream.XstreamConverter;
import org.restlet.ext.xstream.XstreamRepresentation;
import org.restlet.representation.Representation;

public class ServiioXstreamConverter : XstreamConverter
{
  protected XstreamRepresentation!(T) create(T)(MediaType mediaType, T source)
  {
    return new ServiioXstreamRepresentation!(T)(mediaType, source);
  }

  protected XstreamRepresentation!(T) create(T)(Representation source)
  {
    return new ServiioXstreamRepresentation!(T)(source);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.restlet.ServiioXstreamConverter
 * JD-Core Version:    0.6.2
 */