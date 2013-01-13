module org.serviio.upnp.protocol.soap.ServiceInvocationException;

public class ServiceInvocationException : Exception
{
  private static final long serialVersionUID = -3055496533014695187L;

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
 * Qualified Name:     org.serviio.upnp.protocol.soap.ServiceInvocationException
 * JD-Core Version:    0.6.2
 */