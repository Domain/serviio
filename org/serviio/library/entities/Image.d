module org.serviio.library.entities.Image;

import java.lang.Integer;
import java.lang.Long;
import java.lang.String;
import java.util.Date;
import org.serviio.dlna.ImageContainer;
import org.serviio.dlna.SamplingMode;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.library.entities.MediaItem;

public class Image : MediaItem
{
  private Integer width;
  private Integer height;
  private Integer colorDepth;
  private ImageContainer container;
  private Integer rotation;
  private SamplingMode chromaSubsampling;

  public this(String title, ImageContainer container, String fileName, String filePath, Long fileSize, Long folderId, Long repositoryId, Date date)
  {
    super(title, fileName, filePath, fileSize, folderId, repositoryId, date, MediaFileType.IMAGE);
    this.container = container;
  }

  public Integer getWidth()
  {
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

  public Integer getColorDepth() {
    return colorDepth;
  }

  public void setColorDepth(Integer colorDepth) {
    this.colorDepth = colorDepth;
  }

  public ImageContainer getContainer() {
    return container;
  }

  public void setContainer(ImageContainer container) {
    this.container = container;
  }

  public Integer getRotation() {
    return rotation;
  }

  public void setRotation(Integer rotation) {
    this.rotation = rotation;
  }

  public SamplingMode getChromaSubsampling() {
    return chromaSubsampling;
  }

  public void setChromaSubsampling(SamplingMode chromaSubsampling) {
    this.chromaSubsampling = chromaSubsampling;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.entities.Image
 * JD-Core Version:    0.6.2
 */