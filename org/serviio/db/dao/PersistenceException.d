module org.serviio.db.dao.PersistenceException;

import java.lang.RuntimeException;
import java.lang.String;

public class PersistenceException : RuntimeException
{
    private static const long serialVersionUID = 5322751026922794882L;

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
* Qualified Name:     org.serviio.db.dao.PersistenceException
* JD-Core Version:    0.6.2
*/