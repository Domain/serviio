module org.serviio.upnp.protocol.soap.InvocationError;

import java.lang.String;

public class InvocationError
{
	enum InvocationErrorEnum
	{
		INVALID_ACTION = 401, 
		INVALID_ARGS = 402, 
		INVALID_VAR = 404, 
		ACTION_FAILED = 501, 
		CON_MAN_INVALID_CONNECTION_REFERENCE = 706, 
		CON_MAN_NO_SUCH_OBJECT = 701, 
		CON_MAN_NO_SUCH_CONTAINER = 710,
	}

	InvocationErrorEnum invocationError;
	alias invocationError this;

  public int getCode()
  {
	  return cast(int)invocationError;
  }

  public String getDescription()
  {
	  switch (invocationError)
	  {
		  case INVALID_ACTION:
			  return "Invalid Action"; 

		  case INVALID_ARGS:
			  return "Invalid Args"; 

		  case INVALID_VAR:
			  return "Invalid Var"; 

		  case ACTION_FAILED:
			  return "Action Failed"; 

		  case CON_MAN_INVALID_CONNECTION_REFERENCE:
			  return "Invalid connection reference"; 

		  case CON_MAN_NO_SUCH_OBJECT:
			  return "No such object"; 

		  case CON_MAN_NO_SUCH_CONTAINER:
			  return "No such container";
	  }
	  return "";
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.soap.InvocationError
 * JD-Core Version:    0.6.2
 */