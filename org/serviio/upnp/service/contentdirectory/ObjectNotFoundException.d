module org.serviio.upnp.service.contentdirectory.ObjectNotFoundException;

public class ObjectNotFoundException : RuntimeException
{
  private static final long serialVersionUID = 3274235432180112874L;

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
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.ObjectNotFoundException
 * JD-Core Version:    0.6.2
 */