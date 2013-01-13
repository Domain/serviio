module org.serviio.delivery.RangeNotSupportedException;

import java.lang.String;

public class RangeNotSupportedException : Exception
{
  private static const long serialVersionUID = -1350679542734185819L;

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
 * Qualified Name:     org.serviio.delivery.RangeNotSupportedException
 * JD-Core Version:    0.6.2
 */