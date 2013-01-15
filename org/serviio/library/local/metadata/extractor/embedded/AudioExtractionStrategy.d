module org.serviio.library.local.metadata.extractor.embedded.AudioExtractionStrategy;

import java.io.IOException;
import java.util.List;
import org.apache.sanselan.ImageFormat;
import org.apache.sanselan.Sanselan;
import org.jaudiotagger.audio.AudioFile;
import org.jaudiotagger.audio.AudioHeader;
import org.jaudiotagger.tag.FieldKey;
import org.jaudiotagger.tag.Tag;
import org.jaudiotagger.tag.datatype.Artwork;
import org.serviio.dlna.AudioContainer;
import org.serviio.library.local.metadata.AudioMetadata;
import org.serviio.library.local.metadata.ImageDescriptor;
import org.serviio.library.local.metadata.extractor.InvalidMediaFormatException;
import org.serviio.util.NumberUtils;
import org.serviio.util.ObjectValidator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class AudioExtractionStrategy
{
  private static final Logger log = LoggerFactory.getLogger!(AudioExtractionStrategy)();

  public void extractMetadata(AudioMetadata metadata, AudioFile f, AudioHeader header, Tag tag)
  {
    log.debug_(String.format("Extracting metadata of audio file: %s", cast(Object[])[ f.getFile().getAbsolutePath() ]));

    if (tag !is null) {
      metadata.setAlbum(getKey(tag, FieldKey.ALBUM));
      metadata.setAuthor(getKey(tag, FieldKey.COMPOSER));
      metadata.setArtist(getKey(tag, FieldKey.ARTIST));
      metadata.setReleaseYear(NumberUtils.stringToInt(tag.getFirst(FieldKey.YEAR)));
      metadata.setTitle(getKey(tag, FieldKey.TITLE));
      metadata.setTrackNumber(fixTrackNumber(getKey(tag, FieldKey.TRACK)));
      metadata.setAlbumArtist(getKey(tag, FieldKey.ALBUM_ARTIST));
      metadata.setDescription(getKey(tag, FieldKey.COMMENT));
      metadata.setGenre(getKey(tag, FieldKey.GENRE));

      metadata.setCoverImage(findAlbumArt(tag));
    }
    if (header !is null) {
      metadata.setDuration(Integer.valueOf(header.getTrackLength()));
      long bitrate = header.getBitRateAsNumber();
      try {
        metadata.setBitrate(Integer.valueOf(Integer.parseInt(Long.toString(bitrate))));
      } catch (NumberFormatException e) {
        log.debug_(String.format("Invalid bitrate: %s", cast(Object[])[ Long.valueOf(bitrate) ]));
      }
      metadata.setChannels(getNumberOfChannels(header));
      metadata.setSampleFrequency(Integer.valueOf(header.getSampleRateAsNumber()));
    }

    metadata.setContainer(getContainer());
  }

  private String getKey(Tag tag, FieldKey key) {
    try {
      return ObjectValidator.isNotEmpty(tag.getFirst(key)) ? tag.getFirst(key) : null; } catch (Exception e) {
    }
    return null;
  }

  protected ImageDescriptor findAlbumArt(Tag tag)
  {
    List!(Artwork) albumArtList = tag.getArtworkList();
    if ((albumArtList !is null) && (!albumArtList.isEmpty())) {
      foreach (Artwork albumArt ; albumArtList) {
        if (ObjectValidator.isEmpty(albumArt.getImageUrl())) {
          byte[] imageBuffer = albumArt.getBinaryData();
          if (isSupportedImageFormat(imageBuffer))
          {
            ImageDescriptor imageDesc = new ImageDescriptor(imageBuffer, albumArt.getMimeType());
            return imageDesc;
          }
        }
      }
    }
    return null;
  }

  protected Integer fixTrackNumber(String trackNumber) {
    try {
      if (trackNumber !is null) {
        int slashPos = trackNumber.indexOf("/");
        if (slashPos > -1)
        {
          trackNumber = trackNumber.substring(0, slashPos);
        }
      }
      return NumberUtils.stringToInt(trackNumber); } catch (Exception e) {
    }
    return null;
  }

  protected abstract AudioContainer getContainer();

  protected Integer getNumberOfChannels(AudioHeader header)
  {
    String channels = header.getChannels();
    if (channels !is null) {
      if ((channels.equals("1")) || (channels.equalsIgnoreCase("Mono")))
        return Integer.valueOf(1);
      if ((channels.equals("2")) || (channels.equalsIgnoreCase("Stereo")) || (channels.equalsIgnoreCase("Joint Stereo")))
      {
        return Integer.valueOf(2);
      }
      return Integer.valueOf(0);
    }

    return null;
  }

  protected bool isSupportedImageFormat(byte[] imageBytes)
  {
    ImageFormat imageFormat = getImageFormat(imageBytes);
    return isSupportedImageFormat(imageFormat);
  }

  protected ImageFormat getImageFormat(byte[] imageBytes) {
    try {
      return Sanselan.guessFormat(imageBytes);
    }
    catch (Exception e)
    {
      log.debug_("Cannot get image format: " + e.getMessage(), e);
    }return null;
  }

  protected bool isSupportedImageFormat(ImageFormat imageFormat) {
    if ((imageFormat is null) || (imageFormat.equals(ImageFormat.IMAGE_FORMAT_UNKNOWN)))
    {
      return false;
    }
    return true;
  }

  protected String getMimeType(ImageFormat imageFormat)
  {
    if (imageFormat == ImageFormat.IMAGE_FORMAT_GIF)
      return "image/gif";
    if (imageFormat == ImageFormat.IMAGE_FORMAT_JPEG)
      return "image/jpeg";
    if (imageFormat == ImageFormat.IMAGE_FORMAT_PNG) {
      return "image/png";
    }
    log.debug_("Cannot guess mime type of image format: " + imageFormat.toString());
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.AudioExtractionStrategy
 * JD-Core Version:    0.6.2
 */