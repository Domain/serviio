module org.serviio.library.online.CannotRetrieveThumbnailException;

public class CannotRetrieveThumbnailException : Exception
{
  private static final long serialVersionUID = 3818361224060004057L;

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
 * Qualified Name:     org.serviio.library.online.CannotRetrieveThumbnailException
 * JD-Core Version:    0.6.2
 */