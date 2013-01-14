module org.serviio.delivery.resource.transcode.VideoTranscodingDefinition;

import java.lang.Integer;
import java.util.ArrayList;
import java.util.List;
import org.serviio.dlna.AudioCodec;
import org.serviio.dlna.DisplayAspectRatio;
import org.serviio.dlna.VideoCodec;
import org.serviio.dlna.VideoContainer;
import org.serviio.delivery.resource.transcode.AbstractTranscodingDefinition;
import org.serviio.delivery.resource.transcode.VideoTranscodingMatch;
import org.serviio.delivery.resource.transcode.TranscodingConfiguration;

public class VideoTranscodingDefinition : AbstractTranscodingDefinition
{
  private VideoContainer targetContainer;
  private VideoCodec targetVideoCodec;
  private AudioCodec targetAudioCodec;
  private Integer maxVideoBitrate;
  private Integer maxHeight;
  private bool forceVTranscoding;
  private bool forceStereo;
  private DisplayAspectRatio dar;
  private List!(VideoTranscodingMatch) matches = new ArrayList!(VideoTranscodingMatch)();

  public this(TranscodingConfiguration parentConfig, VideoContainer targetContainer, VideoCodec targetVideoCodec, AudioCodec targetAudioCodec, Integer maxVideoBitrate, Integer maxHeight, Integer audioBitrate, Integer audioSamplerate, bool forceVTranscoding, bool forceStereo, bool forceInheritance, DisplayAspectRatio dar)
  {
    super(parentConfig);
    this.targetContainer = targetContainer;
    this.targetVideoCodec = targetVideoCodec;
    this.targetAudioCodec = targetAudioCodec;
    this.maxVideoBitrate = maxVideoBitrate;
    this.audioBitrate = audioBitrate;
    this.audioSamplerate = audioSamplerate;
    this.forceVTranscoding = forceVTranscoding;
    this.forceStereo = forceStereo;
    this.forceInheritance = forceInheritance;
    this.maxHeight = maxHeight;
    this.dar = dar;
  }

  public VideoContainer getTargetContainer()
  {
    return targetContainer;
  }

  public VideoCodec getTargetVideoCodec() {
    return targetVideoCodec;
  }

  public AudioCodec getTargetAudioCodec() {
    return targetAudioCodec;
  }

  public Integer getMaxVideoBitrate() {
    return maxVideoBitrate;
  }

  public List!(VideoTranscodingMatch) getMatches() {
    return matches;
  }

  public bool isForceVTranscoding() {
    return forceVTranscoding;
  }

  public bool isForceStereo() {
    return forceStereo;
  }

  public Integer getMaxHeight() {
    return maxHeight;
  }

  public DisplayAspectRatio getDar() {
    return dar;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.resource.transcode.VideoTranscodingDefinition
 * JD-Core Version:    0.6.2
 */