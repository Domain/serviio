module org.serviio.upnp.protocol.soap.OperationResult;

import java.lang.String;
import java.util.LinkedHashMap;
import java.util.Map;
import org.serviio.upnp.protocol.soap.InvocationError;

public class OperationResult
{
  private Map!(String, Object) outputParameters = new LinkedHashMap!(String, Object)();
  private InvocationError error;

  public this()
  {
  }

  public this(InvocationError error)
  {
    this.error = error;
  }

  public void addOutputParameter(String name, Object value)
  {
    outputParameters.put(name, value);
  }

  public Map!(String, Object) getOutputParameters()
  {
    return outputParameters;
  }

  public InvocationError getError() {
    return error;
  }

  public void setError(InvocationError error) {
    this.error = error;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.soap.OperationResult
 * JD-Core Version:    0.6.2
 */