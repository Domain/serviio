module org.serviio.delivery.resource.transcode.TranscodingConfiguration;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.delivery.resource.transcode.TranscodingDefinition;

public class TranscodingConfiguration
{
  private bool keepStreamOpen = true;

  private Map!(MediaFileType, List!(TranscodingDefinition)) config = new HashMap!(MediaFileType, List!(TranscodingDefinition))();

  public List!(TranscodingDefinition) getDefinitions(MediaFileType fileType)
  {
    List!(TranscodingDefinition) result = cast(List!(TranscodingDefinition))config.get(fileType);
    if (result !is null) {
      return Collections.unmodifiableList(cast(List!(TranscodingDefinition))config.get(fileType));
    }
    return Collections.emptyList();
  }

  public List!(TranscodingDefinition) getDefinitions()
  {
    List!(TranscodingDefinition) result = new ArrayList!(TranscodingDefinition)();
    foreach (List!(TranscodingDefinition) configs ; config.values()) {
      result.addAll(configs);
    }
    return Collections.unmodifiableList(result);
  }

  public void addDefinition(MediaFileType fileType, TranscodingDefinition definition) {
    if (!config.containsKey(fileType)) {
      config.put(fileType, new ArrayList!(TranscodingDefinition)());
    }
    List!(TranscodingDefinition) defs = cast(List!(TranscodingDefinition))config.get(fileType);
    defs.add(definition);
  }

  public bool isKeepStreamOpen() {
    return keepStreamOpen;
  }

  public void setKeepStreamOpen(bool keepStreamOpen) {
    this.keepStreamOpen = keepStreamOpen;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.resource.transcode.TranscodingConfiguration
 * JD-Core Version:    0.6.2
 */