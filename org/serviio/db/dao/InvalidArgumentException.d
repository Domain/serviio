module org.serviio.db.dao.InvalidArgumentException;

import java.lang.RuntimeException;
import java.lang.String;

public class InvalidArgumentException : RuntimeException
{
    private static const long serialVersionUID = 969956618129304694L;

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
* Qualified Name:     org.serviio.db.dao.InvalidArgumentException
* JD-Core Version:    0.6.2
*/