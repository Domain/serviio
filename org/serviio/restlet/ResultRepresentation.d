module org.serviio.restlet.ResultRepresentation;

import com.google.gson.annotations.SerializedName;
import com.thoughtworks.xstream.annotations.XStreamImplicit;
import java.util.List;

public class ResultRepresentation
{
  private Integer errorCode = Integer.valueOf(0);

  deprecated
  private int httpCode;

  @XStreamImplicit(itemFieldName="parameter")
  @SerializedName("parameter")
  private List!(String) parameters;

  public this()
  {
  }

  public this(Integer errorCode, int httpCode, List!(String) parameters)
  {
    this.errorCode = errorCode;
    this.httpCode = httpCode;
    this.parameters = parameters;
  }

  public Integer getErrorCode()
  {
    return errorCode;
  }

  public void setErrorCode(Integer errorCode) {
    this.errorCode = errorCode;
  }

  public int getHttpCode() {
    return httpCode;
  }

  public void setHttpCode(int httpCode) {
    this.httpCode = httpCode;
  }

  public List!(String) getParameters() {
    return parameters;
  }

  public void setParameters(List!(String) parameters) {
    this.parameters = parameters;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.restlet.ResultRepresentation
 * JD-Core Version:    0.6.2
 */