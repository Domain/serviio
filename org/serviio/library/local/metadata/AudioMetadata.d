module org.serviio.library.local.metadata.AudioMetadata;

import org.serviio.dlna.AudioContainer;
import org.serviio.library.metadata.InvalidMetadataException;
import org.serviio.util.ObjectValidator;

public class AudioMetadata : LocalItemMetadata
{
  private AudioContainer container;
  private String genre;
  private Integer releaseYear;
  private String album;
  private Integer trackNumber;
  private Integer duration;
  private String albumArtist;
  private String artist;
  private Integer bitrate;
  private Integer channels;
  private Integer sampleFrequency;
  private ImageDescriptor coverImage;

  public void merge(LocalItemMetadata additionalMetadata)
  {
    if (( cast(AudioMetadata)additionalMetadata !is null )) {
      AudioMetadata additionalAudioMetadata = cast(AudioMetadata)additionalMetadata;

      super.merge(additionalAudioMetadata);

      if (container is null) {
        setContainer(additionalAudioMetadata.getContainer());
      }
      if (ObjectValidator.isEmpty(genre)) {
        setGenre(additionalAudioMetadata.getGenre());
      }
      if (releaseYear is null) {
        setReleaseYear(additionalAudioMetadata.getReleaseYear());
      }
      if (ObjectValidator.isEmpty(album)) {
        setAlbum(additionalAudioMetadata.getAlbum());
      }
      if (trackNumber is null) {
        setTrackNumber(additionalAudioMetadata.getTrackNumber());
      }
      if (duration is null) {
        setDuration(additionalAudioMetadata.getDuration());
      }
      if (ObjectValidator.isEmpty(albumArtist)) {
        setAlbumArtist(additionalAudioMetadata.getAlbumArtist());
      }
      if (ObjectValidator.isEmpty(artist)) {
        setArtist(additionalAudioMetadata.getArtist());
      }
      if (bitrate is null) {
        setBitrate(additionalAudioMetadata.getBitrate());
      }
      if (channels is null) {
        setChannels(additionalAudioMetadata.getChannels());
      }
      if (sampleFrequency is null) {
        setSampleFrequency(additionalAudioMetadata.getSampleFrequency());
      }
      if (coverImage is null)
        setCoverImage(additionalAudioMetadata.getCoverImage());
    }
  }

  public void fillInUnknownEntries()
  {
    super.fillInUnknownEntries();

    if (ObjectValidator.isEmpty(genre)) {
      setGenre("Unknown");
    }
    if (ObjectValidator.isEmpty(album)) {
      setAlbum("Unknown");
    }
    if (ObjectValidator.isEmpty(albumArtist)) {
      setAlbumArtist("Unknown");
    }
    if (ObjectValidator.isEmpty(artist))
      setAlbumArtist("Unknown");
  }

  public void validateMetadata()
  {
    super.validateMetadata();

    if (container is null) {
      throw new InvalidMetadataException("Unknown audio file type.");
    }
    if (bitrate is null)
      throw new InvalidMetadataException("Unknown bit rate.");
  }

  public String getGenre()
  {
    return genre;
  }

  public void setGenre(String genre) {
    this.genre = genre;
  }

  public Integer getReleaseYear() {
    return releaseYear;
  }

  public void setReleaseYear(Integer year) {
    releaseYear = year;
  }

  public String getAlbum() {
    return album;
  }

  public void setAlbum(String album) {
    this.album = album;
  }

  public Integer getTrackNumber() {
    return trackNumber;
  }

  public void setTrackNumber(Integer trackNumber) {
    this.trackNumber = trackNumber;
  }

  public Integer getDuration() {
    return duration;
  }

  public void setDuration(Integer duration) {
    this.duration = duration;
  }

  public String getAlbumArtist() {
    return albumArtist;
  }

  public void setAlbumArtist(String albumArtist) {
    this.albumArtist = albumArtist;
  }

  public Integer getBitrate() {
    return bitrate;
  }

  public void setBitrate(Integer bitrate) {
    this.bitrate = bitrate;
  }

  public ImageDescriptor getCoverImage() {
    return coverImage;
  }

  public void setCoverImage(ImageDescriptor coverImage) {
    this.coverImage = coverImage;
  }

  public Integer getChannels() {
    return channels;
  }

  public void setChannels(Integer channels) {
    this.channels = channels;
  }

  public Integer getSampleFrequency() {
    return sampleFrequency;
  }

  public void setSampleFrequency(Integer sampleFrequency) {
    this.sampleFrequency = sampleFrequency;
  }

  public AudioContainer getContainer() {
    return container;
  }

  public void setContainer(AudioContainer container) {
    this.container = container;
  }

  public String getArtist() {
    return artist;
  }

  public void setArtist(String artist) {
    this.artist = artist;
  }

  public String toString()
  {
    StringBuilder builder = new StringBuilder();
    builder.append("AudioMetadata [album=").append(album).append(", title=").append(title).append(", albumArtist=").append(albumArtist).append(", artist=").append(artist).append(", genre=").append(genre).append(", releaseYear=").append(releaseYear).append(", trackNumber=").append(trackNumber).append(", container=").append(container).append(", duration=").append(duration).append(", bitrate=").append(bitrate).append(", channels=").append(channels).append(", sampleFrequency=").append(sampleFrequency).append("]");

    return builder.toString();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.AudioMetadata
 * JD-Core Version:    0.6.2
 */