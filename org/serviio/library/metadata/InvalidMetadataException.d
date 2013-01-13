module org.serviio.library.metadata.InvalidMetadataException;

public class InvalidMetadataException : Exception
{
  private static final long serialVersionUID = -4813485118718894106L;

  public this()
  {
  }

  public this(String message, Throwable cause)
  {
    super(message, cause);
  }

  public this(String message)
  {
    super(message);
  }

  public this(Throwable cause)
  {
    super(cause);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.metadata.InvalidMetadataException
 * JD-Core Version:    0.6.2
 */