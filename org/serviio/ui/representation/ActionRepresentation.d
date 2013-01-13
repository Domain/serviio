module org.serviio.ui.representation.ActionRepresentation;

import com.google.gson.annotations.SerializedName;
import com.thoughtworks.xstream.annotations.XStreamImplicit;
import java.util.ArrayList;
import java.util.List;

public class ActionRepresentation
{
  private String name;

  @XStreamImplicit(itemFieldName="parameter")
  @SerializedName("parameter")
  private final List!(String) parameters = new ArrayList!(String)();

  public String getName()
  {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public List!(String) getParameters() {
    return parameters;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.representation.ActionRepresentation
 * JD-Core Version:    0.6.2
 */