module org.serviio.ui.representation.DataValue;

public class DataValue
{
  private String name;
  private String value;

  public this()
  {
  }

  public this(String name, String value)
  {
    this.name = name;
    this.value = value;
  }

  public String getName()
  {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getValue() {
    return value;
  }

  public void setValue(String value) {
    this.value = value;
  }

  public String toString()
  {
    return value;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.representation.DataValue
 * JD-Core Version:    0.6.2
 */