module org.serviio.delivery.resource.transcode.AudioTranscodingDefinition;

import java.lang.String;
import java.lang.Integer;
import java.util.ArrayList;
import java.util.List;
import org.serviio.dlna.AudioContainer;
import org.serviio.delivery.resource.transcode.AbstractTranscodingDefinition;
import org.serviio.delivery.resource.transcode.AudioTranscodingMatch;
import org.serviio.delivery.resource.transcode.TranscodingConfiguration;

public class AudioTranscodingDefinition : AbstractTranscodingDefinition
{
  private AudioContainer targetContainer;
  private List!(AudioTranscodingMatch) matches = new ArrayList!(AudioTranscodingMatch)();

  public this(TranscodingConfiguration parentConfig, AudioContainer targetContainer, Integer audioBitrate, Integer audioSamplerate, bool forceInheritance)
  {
    super(parentConfig);
    this.targetContainer = targetContainer;
    this.audioBitrate = audioBitrate;
    this.audioSamplerate = audioSamplerate;
    this.forceInheritance = forceInheritance;
  }

  public AudioContainer getTargetContainer()
  {
    return targetContainer;
  }

  public List!(AudioTranscodingMatch) getMatches() {
    return matches;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.resource.transcode.AudioTranscodingDefinition
 * JD-Core Version:    0.6.2
 */