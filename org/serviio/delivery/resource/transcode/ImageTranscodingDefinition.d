module org.serviio.delivery.resource.transcode.ImageTranscodingDefinition;

import java.util.ArrayList;
import java.util.List;
import org.serviio.delivery.resource.transcode.AbstractTranscodingDefinition;

public class ImageTranscodingDefinition : AbstractTranscodingDefinition
{
  private List!(ImageTranscodingMatch) matches = new ArrayList!(ImageTranscodingMatch)();

  public this(TranscodingConfiguration parentConfig, bool forceInheritance)
  {
    super(parentConfig);
    this.forceInheritance = forceInheritance;
  }

  public List!(ImageTranscodingMatch) getMatches()
  {
    return matches;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.resource.transcode.ImageTranscodingDefinition
 * JD-Core Version:    0.6.2
 */