module org.serviio.library.entities.CoverImage;

import java.lang.String;
import java.io.Serializable;
import org.serviio.db.entities.PersistedEntity;

public class CoverImage : PersistedEntity
  , Serializable
{
  private static const long serialVersionUID = 4659420820184102835L;
  private byte[] imageBytes;
  private String mimeType;
  private int width;
  private int height;

  public this(byte[] imageBytes, String mimeType, int width, int height)
  {
    this.imageBytes = imageBytes;
    this.mimeType = mimeType;
    this.width = width;
    this.height = height;
  }

  public byte[] getImageBytes()
  {
    return imageBytes;
  }

  public String getMimeType() {
    return mimeType;
  }

  public int getWidth() {
    return width;
  }

  public int getHeight() {
    return height;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.entities.CoverImage
 * JD-Core Version:    0.6.2
 */