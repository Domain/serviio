module org.serviio.library.local.metadata.extractor.embedded.MP4ExtractionStrategy;

import java.io.IOException;
import org.jaudiotagger.audio.AudioFile;
import org.jaudiotagger.audio.AudioHeader;
import org.jaudiotagger.tag.Tag;
import org.serviio.dlna.AudioContainer;
import org.serviio.library.local.metadata.AudioMetadata;
import org.serviio.library.local.metadata.extractor.InvalidMediaFormatException;

public class MP4ExtractionStrategy : AudioExtractionStrategy
{
  public void extractMetadata(AudioMetadata metadata, AudioFile f, AudioHeader header, Tag tag)
  {
    if ((f.getAudioHeader() !is null) && 
      (!f.getAudioHeader().getEncodingType().equalsIgnoreCase("AAC")))
    {
      throw new InvalidMediaFormatException(String.format("MP4 file '%s' has unsupported codec (%s)", cast(Object[])[ f.getFile(), f.getAudioHeader().getEncodingType() ]));
    }

    super.extractMetadata(metadata, f, header, tag);
  }

  protected AudioContainer getContainer()
  {
    return AudioContainer.MP4;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.MP4ExtractionStrategy
 * JD-Core Version:    0.6.2
 */