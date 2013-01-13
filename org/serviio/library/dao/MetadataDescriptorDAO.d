module org.serviio.library.dao.MetadataDescriptorDAO;

import org.serviio.db.dao.GenericDAO;
import org.serviio.library.entities.MetadataDescriptor;
import org.serviio.library.local.metadata.extractor.ExtractorType;

public abstract interface MetadataDescriptorDAO : GenericDAO!(MetadataDescriptor)
{
  public abstract void removeMetadataDescriptorsForMedia(Long paramLong);

  public abstract MetadataDescriptor retrieveMetadataDescriptorForMedia(Long paramLong, ExtractorType paramExtractorType);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.MetadataDescriptorDAO
 * JD-Core Version:    0.6.2
 */