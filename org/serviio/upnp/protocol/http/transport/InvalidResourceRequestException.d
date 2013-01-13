module org.serviio.upnp.protocol.http.transport.InvalidResourceRequestException;

import java.lang.String;

public class InvalidResourceRequestException : Exception
{
  private static const long serialVersionUID = 3044601649780819077L;

  public this()
  {
  }

  public this(String message, Throwable cause)
  {
    super(message, cause);
  }

  public this(String message) {
    super(message);
  }

  public this(Throwable cause) {
    super(cause);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.http.transport.InvalidResourceRequestException
 * JD-Core Version:    0.6.2
 */