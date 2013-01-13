module org.serviio.library.local.metadata.ImageDescriptor;

import java.net.URL;

public class ImageDescriptor
{
  private byte[] imageData;
  private URL imageUrl;
  private String mimeType;
  private Integer width;
  private Integer height;

  public this(byte[] imageData, String mimeType)
  {
    this.imageData = imageData;
    this.mimeType = mimeType;
  }

  public this(Integer width, Integer height, byte[] imageData)
  {
    this.width = width;
    this.height = height;
    this.imageData = imageData;
  }

  public this(URL imageUrl)
  {
    this.imageUrl = imageUrl;
  }

  public byte[] getImageData() {
    return imageData;
  }

  public String getMimeType() {
    return mimeType;
  }

  public Integer getWidth() {
    return width;
  }

  public void setWidth(Integer width) {
    this.width = width;
  }

  public Integer getHeight() {
    return height;
  }

  public void setHeight(Integer height) {
    this.height = height;
  }

  public URL getImageUrl() {
    return imageUrl;
  }

  public void setImageData(byte[] imageData) {
    this.imageData = imageData;
  }

  public void setMimeType(String mimeType) {
    this.mimeType = mimeType;
  }

  public void setImageUrl(URL imageUrl) {
    this.imageUrl = imageUrl;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.ImageDescriptor
 * JD-Core Version:    0.6.2
 */