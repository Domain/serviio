module org.serviio.licensing.InvalidLicenseException;

import java.lang.String;

public class InvalidLicenseException : Exception
{
    private static const long serialVersionUID = 4647228477001777038L;

    public this(String message, Throwable cause)
    {
        super(message, cause);
    }

    public this(String message) {
        super(message);
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.licensing.InvalidLicenseException
* JD-Core Version:    0.6.2
*/