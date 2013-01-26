module org.serviio.restlet.AbstractRestfulException;

import java.lang.RuntimeException;
import java.lang.String;
import java.util.List;

public class AbstractRestfulException : RuntimeException
{
    private static const long serialVersionUID = 7485159781915824536L;
    private int errorCode;
    private List!(String) parameters;

    public this(int errorCode)
    {
        this.errorCode = errorCode;
    }

    public this(int errorCode, List!(String) parameters) {
        this(errorCode);
        this.parameters = parameters;
    }

    public this(String message, Throwable cause, int errorCode) {
        super(message, cause);
        this.errorCode = errorCode;
    }

    public this(String message, int errorCode)
    {
        super(message);
        this.errorCode = errorCode;
    }

    public this(Throwable cause, int errorCode) {
        super(cause);
        this.errorCode = errorCode;
    }

    public int getErrorCode() {
        return errorCode;
    }

    public List!(String) getParameters() {
        return parameters;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.restlet.AbstractRestfulException
* JD-Core Version:    0.6.2
*/