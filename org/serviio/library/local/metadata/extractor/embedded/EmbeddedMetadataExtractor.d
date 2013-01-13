module org.serviio.library.local.metadata.extractor.embedded.EmbeddedMetadataExtractor;

import java.io.File;
import java.io.IOException;
import java.util.Date;
import org.jaudiotagger.audio.AudioFile;
import org.jaudiotagger.audio.AudioFileIO;
import org.jaudiotagger.audio.AudioHeader;
import org.jaudiotagger.audio.exceptions.CannotReadException;
import org.jaudiotagger.audio.exceptions.InvalidAudioFrameException;
import org.jaudiotagger.audio.exceptions.ReadOnlyFileException;
import org.jaudiotagger.audio.mp3.MP3File;
import org.jaudiotagger.audio.mp4.Mp4AudioHeader;
import org.jaudiotagger.tag.Tag;
import org.jaudiotagger.tag.TagException;
import org.jaudiotagger.tag.flac.FlacTag;
import org.jaudiotagger.tag.vorbiscomment.VorbisCommentTag;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.entities.MetadataDescriptor;
import org.serviio.library.entities.Repository;
import org.serviio.library.local.ContentType;
import org.serviio.library.local.metadata.AudioMetadata;
import org.serviio.library.local.metadata.ImageMetadata;
import org.serviio.library.local.metadata.LocalItemMetadata;
import org.serviio.library.local.metadata.VideoMetadata;
import org.serviio.library.local.metadata.extractor.ExtractorType;
import org.serviio.library.local.metadata.extractor.InvalidMediaFormatException;
import org.serviio.library.local.metadata.extractor.MetadataExtractor;
import org.serviio.library.local.metadata.extractor.MetadataFile;
import org.serviio.library.metadata.ImageMetadataRetriever;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.util.FileUtils;
import org.serviio.util.ObjectValidator;

public class EmbeddedMetadataExtractor : MetadataExtractor
{
  public ExtractorType getExtractorType()
  {
    return ExtractorType.EMBEDDED;
  }

  public bool isMetadataUpdated(File mediaFile, MediaItem mediaItem, MetadataDescriptor metadataDescriptor)
  {
    if ((mediaFile !is null) && (mediaFile.exists()) && (metadataDescriptor !is null)) {
      Date mediaFileDate = FileUtils.getLastModifiedDate(mediaFile);

      if ((metadataDescriptor.getDateUpdated() is null) || (mediaFileDate.after(metadataDescriptor.getDateUpdated())))
      {
        return true;
      }
      return false;
    }

    return false;
  }

  protected MetadataFile getMetadataFile(File mediaFile, MediaFileType fileType, Repository repository)
  {
    if ((mediaFile.exists()) && (mediaFile.canRead())) {
      return new MetadataFile(getExtractorType(), FileUtils.getLastModifiedDate(mediaFile), null, mediaFile);
    }
    throw new IOException(String.format("File %s cannot be read to extract metadata", cast(Object[])[ mediaFile.getAbsolutePath() ]));
  }

  protected void retrieveMetadata(MetadataFile metadataDescriptor, LocalItemMetadata metadata)
  {
    File mediaFile = cast(File)metadataDescriptor.getExtractable();
    if (( cast(AudioMetadata)metadata !is null ))
      retrieveAudioMetadata(mediaFile, metadata);
    else if (( cast(ImageMetadata)metadata !is null )) {
      retrieveImageMetadata(mediaFile, metadata);
    }
    else {
      retrieveVideoMetadata(mediaFile, metadata);
    }

    if (ObjectValidator.isEmpty(metadata.getTitle()))
    {
      metadata.setTitle(FileUtils.getFileNameWithoutExtension(mediaFile));
    }

    if (metadata.getDate() is null)
    {
      metadata.setDate(FileUtils.getLastModifiedDate(mediaFile));
    }

    metadata.setFileSize(mediaFile.length());
    metadata.setFilePath(FileUtils.getProperFilePath(mediaFile));
  }

  protected void retrieveAudioMetadata(File mediaFile, LocalItemMetadata metadata)
  {
    try
    {
      AudioFile audioFile = AudioFileIO.read(mediaFile);
      Tag tag = audioFile.getTag();
      AudioHeader header = audioFile.getAudioHeader();

      AudioExtractionStrategy strategy = null;

      if (( cast(MP3File)audioFile !is null ))
      {
        strategy = new MP3ExtractionStrategy();
      } else if (header.getFormat().startsWith("ASF"))
      {
        strategy = new WMAExtractionStrategy();
      } else if (( cast(Mp4AudioHeader)header !is null ))
      {
        strategy = new MP4ExtractionStrategy();
      } else if (( cast(FlacTag)tag !is null ))
      {
        strategy = new FLACExtractionStrategy();
      } else if (( cast(VorbisCommentTag)tag !is null ))
      {
        strategy = new OGGExtractionStrategy();
      }
      else throw new InvalidMediaFormatException(String.format("File %s has unsupported audio format", cast(Object[])[ mediaFile.getName() ]));

      strategy.extractMetadata(cast(AudioMetadata)metadata, audioFile, header, tag);
    } catch (CannotReadException e) {
      throw new IOException(e);
    } catch (TagException e) {
      throw new InvalidMediaFormatException(e);
    } catch (ReadOnlyFileException e) {
    }
    catch (InvalidAudioFrameException e) {
      throw new InvalidMediaFormatException(e);
    }
  }

  protected void retrieveImageMetadata(File mediaFile, LocalItemMetadata metadata)
  {
    ImageMetadataRetriever.retrieveImageMetadata(cast(ImageMetadata)metadata, FileUtils.getProperFilePath(mediaFile), true);
  }

  protected void retrieveVideoMetadata(File mediaFile, LocalItemMetadata metadata)
  {
    VideoExtractionStrategy strategy = new VideoExtractionStrategy();

    strategy.extractMetadata(cast(VideoMetadata)metadata, mediaFile);

    (cast(VideoMetadata)metadata).setContentType(ContentType.UNKNOWN);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.EmbeddedMetadataExtractor
 * JD-Core Version:    0.6.2
 */