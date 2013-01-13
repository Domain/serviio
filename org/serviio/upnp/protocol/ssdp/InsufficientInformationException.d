module org.serviio.upnp.protocol.ssdp.InsufficientInformationException;

public class InsufficientInformationException : RuntimeException
{
  private static final long serialVersionUID = 2611838684813754915L;

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
 * Qualified Name:     org.serviio.upnp.protocol.ssdp.InsufficientInformationException
 * JD-Core Version:    0.6.2
 */