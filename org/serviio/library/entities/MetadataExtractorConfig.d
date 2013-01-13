module org.serviio.library.entities.MetadataExtractorConfig;

import org.serviio.db.entities.PersistedEntity;
import org.serviio.library.local.metadata.extractor.ExtractorType;
import org.serviio.library.metadata.MediaFileType;

public class MetadataExtractorConfig : PersistedEntity
{
  private MediaFileType fileType;
  private ExtractorType extractorType;
  private int orderNumber;

  public this(MediaFileType fileType, ExtractorType extractorType, int orderNumber)
  {
    this.fileType = fileType;
    this.extractorType = extractorType;
    this.orderNumber = orderNumber;
  }

  public MediaFileType getFileType()
  {
    return fileType;
  }

  public void setFileType(MediaFileType fileType)
  {
    this.fileType = fileType;
  }

  public ExtractorType getExtractorType() {
    return extractorType;
  }

  public void setExtractorType(ExtractorType extractorType) {
    this.extractorType = extractorType;
  }

  public int getOrderNumber() {
    return orderNumber;
  }

  public void setOrderNumber(int orderNumber) {
    this.orderNumber = orderNumber;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.entities.MetadataExtractorConfig
 * JD-Core Version:    0.6.2
 */