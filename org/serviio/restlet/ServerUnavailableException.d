module org.serviio.restlet.ServerUnavailableException;

import org.serviio.restlet.AbstractRestfulException;

public class ServerUnavailableException : AbstractRestfulException
{
	private static const long serialVersionUID = 780974277742855498L;

	public this()
	{
		super("Server is not available", 557);
	}
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.restlet.ServerUnavailableException
* JD-Core Version:    0.6.2
*/