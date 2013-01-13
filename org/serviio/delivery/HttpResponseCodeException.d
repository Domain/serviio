module org.serviio.delivery.HttpResponseCodeException;

public class HttpResponseCodeException : Exception
{
  private static const long serialVersionUID = -8008193408723387271L;
  int httpCode;

  public this(int httpCode)
  {
    this.httpCode = httpCode;
  }

  public int getHttpCode() {
    return httpCode;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.HttpResponseCodeException
 * JD-Core Version:    0.6.2
 */