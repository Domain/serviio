module org.serviio.restlet.HttpCodeException;

import java.lang.RuntimeException;
import java.lang.String;

public class HttpCodeException : RuntimeException
{
    private static const long serialVersionUID = -4813502921424204318L;
    int httpCode;

    public this(int httpCode)
    {
        this.httpCode = httpCode;
    }

    public this(int httpCode, String message, Throwable cause) {
        super(message, cause);
        this.httpCode = httpCode;
    }

    public this(int httpCode, String message) {
        super(message);
        this.httpCode = httpCode;
    }

    public this(int httpCode, Throwable cause) {
        super(cause);
        this.httpCode = httpCode;
    }

    public int getHttpCode() {
        return httpCode;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.restlet.HttpCodeException
* JD-Core Version:    0.6.2
*/