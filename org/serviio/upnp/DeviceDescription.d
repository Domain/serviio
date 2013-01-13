module org.serviio.upnp.DeviceDescription;

import java.lang.String;

public class DeviceDescription
{
  private String friendlyName;
  private String modelName;
  private String modelNumber;
  private String manufacturer;
  private String extraElements;

  public this(String friendlyName, String modelName, String modelNumber, String manufacturer, String extraElements)
  {
    this.friendlyName = friendlyName;
    this.modelName = modelName;
    this.modelNumber = modelNumber;
    this.extraElements = extraElements;
    this.manufacturer = manufacturer;
  }

  public String getFriendlyName() {
    return friendlyName;
  }

  public String getModelName() {
    return modelName;
  }

  public String getModelNumber() {
    return modelNumber;
  }

  public String getExtraElements() {
    return extraElements;
  }

  public String getManufacturer() {
    return manufacturer;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.DeviceDescription
 * JD-Core Version:    0.6.2
 */