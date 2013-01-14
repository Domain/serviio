module org.serviio.library.entities.MetadataDescriptor;

import java.lang.Long;
import java.lang.String;
import java.util.Date;
import org.serviio.db.entities.PersistedEntity;
import org.serviio.library.local.metadata.extractor.ExtractorType;

public class MetadataDescriptor : PersistedEntity
{
  private Date dateUpdated;
  private ExtractorType extractorType;
  private Long mediaItemId;
  private String identifier;

  public this(ExtractorType extractorType, Long mediaItemId, Date dateUpdated, String identifier)
  {
    this.extractorType = extractorType;
    this.mediaItemId = mediaItemId;
    this.dateUpdated = dateUpdated;
    this.identifier = identifier;
  }

  public Date getDateUpdated()
  {
    return dateUpdated;
  }

  public void setDateUpdated(Date dateUpdated) {
    this.dateUpdated = dateUpdated;
  }

  public ExtractorType getExtractorType() {
    return extractorType;
  }

  public void setExtractorType(ExtractorType extractorType) {
    this.extractorType = extractorType;
  }

  public Long getMediaItemId() {
    return mediaItemId;
  }

  public void setMediaItemId(Long mediaItemId) {
    this.mediaItemId = mediaItemId;
  }

  public String getIdentifier() {
    return identifier;
  }

  public void setIdentifier(String identifier) {
    this.identifier = identifier;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.entities.MetadataDescriptor
 * JD-Core Version:    0.6.2
 */