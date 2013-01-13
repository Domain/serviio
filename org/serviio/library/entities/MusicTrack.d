module org.serviio.library.entities.MusicTrack;

import java.util.Date;
import org.serviio.dlna.AudioContainer;
import org.serviio.library.metadata.MediaFileType;

public class MusicTrack : MediaItem
{
  private AudioContainer container;
  private Integer duration;
  private Long albumId;
  private Integer trackNumber;
  private Long genreId;
  private Integer releaseYear;
  private Integer bitrate;
  private Integer channels;
  private Integer sampleFrequency;

  public this(String title, AudioContainer container, String fileName, String filePath, Long fileSize, Long folderId, Long repositoryId, Date date)
  {
    super(title, fileName, filePath, fileSize, folderId, repositoryId, date, MediaFileType.AUDIO);
    this.container = container;
  }

  public Integer getDuration()
  {
    return duration;
  }

  public void setDuration(Integer duration) {
    this.duration = duration;
  }
  public Long getAlbumId() {
    return albumId;
  }
  public void setAlbumId(Long albumId) {
    this.albumId = albumId;
  }
  public Integer getTrackNumber() {
    return trackNumber;
  }
  public void setTrackNumber(Integer trackNumber) {
    this.trackNumber = trackNumber;
  }
  public Integer getReleaseYear() {
    return releaseYear;
  }
  public void setReleaseYear(Integer year) {
    releaseYear = year;
  }

  public Long getGenreId() {
    return genreId;
  }

  public void setGenreId(Long genreId) {
    this.genreId = genreId;
  }

  public Integer getBitrate() {
    return bitrate;
  }

  public void setBitrate(Integer bitrate) {
    this.bitrate = bitrate;
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
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.entities.MusicTrack
 * JD-Core Version:    0.6.2
 */