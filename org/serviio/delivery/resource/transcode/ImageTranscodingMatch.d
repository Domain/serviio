module org.serviio.delivery.resource.transcode.ImageTranscodingMatch;

import org.serviio.dlna.ImageContainer;
import org.serviio.dlna.SamplingMode;

public class ImageTranscodingMatch
{
  private ImageContainer container;
  private SamplingMode chromaSubsampling;

  public this(ImageContainer container, SamplingMode samplingMode)
  {
    this.container = container;
    chromaSubsampling = samplingMode;
  }

  public bool matches(ImageContainer container, SamplingMode chromaSubsampling)
  {
    if ((container == this.container) && ((this.chromaSubsampling is null) || (chromaSubsampling == this.chromaSubsampling))) {
      return true;
    }
    return false;
  }

  public ImageContainer getContainer()
  {
    return container;
  }

  public SamplingMode getChromaSubsampling() {
    return chromaSubsampling;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.resource.transcode.ImageTranscodingMatch
 * JD-Core Version:    0.6.2
 */