module org.serviio.upnp.service.contentdirectory.command.CommandExecutionException;

public class CommandExecutionException : Exception
{
  private static final long serialVersionUID = -3387973648932886031L;

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
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.CommandExecutionException
 * JD-Core Version:    0.6.2
 */