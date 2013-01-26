module org.serviio.restlet.OperationException;

import java.lang.String;
import org.serviio.restlet.AbstractRestfulException;

public class OperationException : AbstractRestfulException
{
    private static const long serialVersionUID = -5442046228119470637L;

    public this(int errorCode)
    {
        super(errorCode);
    }

    public this(String message, int errorCode) {
        super(message, errorCode);
    }

    public this(String message, Throwable cause, int errorCode) {
        super(message, cause, errorCode);
    }

    public this(Throwable cause, int errorCode) {
        super(cause, errorCode);
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.restlet.OperationException
* JD-Core Version:    0.6.2
*/