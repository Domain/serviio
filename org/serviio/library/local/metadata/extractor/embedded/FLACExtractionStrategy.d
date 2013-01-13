module org.serviio.library.local.metadata.extractor.embedded.FLACExtractionStrategy;

import java.io.IOException;
import org.jaudiotagger.audio.AudioFile;
import org.jaudiotagger.audio.AudioHeader;
import org.jaudiotagger.tag.Tag;
import org.serviio.dlna.AudioContainer;
import org.serviio.library.local.metadata.AudioMetadata;
import org.serviio.library.local.metadata.extractor.InvalidMediaFormatException;

public class FLACExtractionStrategy : AudioExtractionStrategy
{
  public void extractMetadata(AudioMetadata metadata, AudioFile f, AudioHeader header, Tag tag)
  {
    super.extractMetadata(metadata, f, header, tag);
  }

  protected AudioContainer getContainer()
  {
    return AudioContainer.FLAC;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.FLACExtractionStrategy
 * JD-Core Version:    0.6.2
 */