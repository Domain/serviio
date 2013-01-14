module org.serviio.library.local.metadata.extractor.InvalidMediaFormatException;

import java.lang.String;

public class InvalidMediaFormatException : Exception
{
  private static const long serialVersionUID = -313705664295140245L;

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
 * Qualified Name:     org.serviio.library.local.metadata.extractor.InvalidMediaFormatException
 * JD-Core Version:    0.6.2
 */