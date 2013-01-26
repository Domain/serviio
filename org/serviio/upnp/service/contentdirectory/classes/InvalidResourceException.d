module org.serviio.upnp.service.contentdirectory.classes.InvalidResourceException;

import java.lang.String;

public class InvalidResourceException : Exception
{
    private static const long serialVersionUID = 4657419096469829296L;

    public this(String message)
    {
        super(message);
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.InvalidResourceException
* JD-Core Version:    0.6.2
*/