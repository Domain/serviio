module org.serviio.library.local.metadata.extractor.MetadataFile;

import java.lang.String;
import java.util.Date;
import org.serviio.library.local.metadata.extractor.ExtractorType;

public class MetadataFile
{
  private ExtractorType extractorType;
  private Date lastUpdatedDate;
  private String identifier;
  private Object extractable;

  public this(ExtractorType extractorType, Date lastUpdatedDate, String identifier, Object extractable)
  {
    this.extractorType = extractorType;
    this.lastUpdatedDate = lastUpdatedDate;
    this.identifier = identifier;
    this.extractable = extractable;
  }

  public ExtractorType getExtractorType() {
    return extractorType;
  }

  public Date getLastUpdatedDate() {
    return lastUpdatedDate;
  }

  public String getIdentifier() {
    return identifier;
  }

  public Object getExtractable() {
    return extractable;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.MetadataFile
 * JD-Core Version:    0.6.2
 */