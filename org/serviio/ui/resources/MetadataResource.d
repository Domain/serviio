module org.serviio.ui.resources.MetadataResource;

import org.restlet.resource.Get;
import org.restlet.resource.Put;
import org.serviio.restlet.ResultRepresentation;
import org.serviio.ui.representation.MetadataRepresentation;

public abstract interface MetadataResource
{
  @Get("xml|json")
  public abstract MetadataRepresentation load();

  @Put("xml|json")
  public abstract ResultRepresentation save(MetadataRepresentation paramMetadataRepresentation);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.resources.MetadataResource
 * JD-Core Version:    0.6.2
 */