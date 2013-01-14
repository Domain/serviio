module org.serviio.library.local.metadata.ImageMetadata;

import java.lang.Integer;
import java.lang.String;
import org.serviio.dlna.ImageContainer;
import org.serviio.dlna.SamplingMode;
import org.serviio.library.metadata.InvalidMetadataException;
import org.serviio.library.local.metadata.LocalItemMetadata;

public class ImageMetadata : LocalItemMetadata
{
  private ImageContainer container;
  private Integer width;
  private Integer height;
  private Integer colorDepth;
  private Integer exifRotation;
  private SamplingMode chromaSubsampling;

  override public void merge(LocalItemMetadata additionalMetadata)
  {
    if (( cast(ImageMetadata)additionalMetadata !is null )) {
      ImageMetadata additionalImageMetadata = cast(ImageMetadata)additionalMetadata;

      super.merge(additionalImageMetadata);

      if (container is null) {
        setContainer(additionalImageMetadata.getContainer());
      }

      if (width is null) {
        setWidth(additionalImageMetadata.getWidth());
      }
      if (height is null) {
        setHeight(additionalImageMetadata.getHeight());
      }
      if (colorDepth is null) {
        setColorDepth(additionalImageMetadata.getColorDepth());
      }
      if (exifRotation is null) {
        setExifRotation(additionalImageMetadata.getExifRotation());
      }
      if (chromaSubsampling is null)
        setChromaSubsampling(additionalImageMetadata.getChromaSubsampling());
    }
  }

  override public void fillInUnknownEntries()
  {
    super.fillInUnknownEntries();
  }

  override public void validateMetadata()
  {
    super.validateMetadata();

    if (container is null) {
      throw new InvalidMetadataException("Unknown image file type.");
    }

    if (width is null) {
      throw new InvalidMetadataException("Unknown image width.");
    }

    if (height is null)
      throw new InvalidMetadataException("Unknown image height.");
  }

  public Integer getColorDepth()
  {
    return colorDepth;
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

  public void setColorDepth(Integer colorDepth) {
    this.colorDepth = colorDepth;
  }

  public ImageContainer getContainer() {
    return container;
  }

  public void setContainer(ImageContainer container) {
    this.container = container;
  }

  public Integer getExifRotation() {
    return exifRotation;
  }

  public void setExifRotation(Integer exifRotation) {
    this.exifRotation = exifRotation;
  }

  public SamplingMode getChromaSubsampling() {
    return chromaSubsampling;
  }

  public void setChromaSubsampling(SamplingMode chromaSubsampling) {
    this.chromaSubsampling = chromaSubsampling;
  }

  override public String toString()
  {
    return String.format("ImageMetadata [title=%s, date=%s, filePath=%s, fileSize=%s, container=%s, width=%s, height=%s, colorDepth=%s, sampling=%s]", cast(Object[])[ title, date, filePath, Long.valueOf(fileSize), container, width, height, colorDepth, chromaSubsampling ]);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.ImageMetadata
 * JD-Core Version:    0.6.2
 */