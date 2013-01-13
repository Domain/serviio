module org.serviio.delivery.resource.transcode.AbstractTranscodingDefinition;

import java.lang.Integer;
import org.serviio.delivery.resource.transcode.TranscodingConfiguration;
import org.serviio.delivery.resource.transcode.TranscodingDefinition;

public abstract class AbstractTranscodingDefinition
  : TranscodingDefinition
{
  private TranscodingConfiguration trConfig;
  protected Integer audioBitrate;
  protected Integer audioSamplerate;
  protected bool forceInheritance = false;

  protected this(TranscodingConfiguration trConfig)
  {
    this.trConfig = trConfig;
  }

  public Integer getAudioBitrate()
  {
    return audioBitrate;
  }

  public Integer getAudioSamplerate()
  {
    return audioSamplerate;
  }

  public bool isForceInheritance()
  {
    return forceInheritance;
  }

  public TranscodingConfiguration getTranscodingConfiguration()
  {
    return trConfig;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.resource.transcode.AbstractTranscodingDefinition
 * JD-Core Version:    0.6.2
 */