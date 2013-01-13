module org.serviio.library.entities.Video;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import org.serviio.dlna.AudioCodec;
import org.serviio.dlna.H264Profile;
import org.serviio.dlna.VideoCodec;
import org.serviio.dlna.VideoContainer;
import org.serviio.library.local.ContentType;
import org.serviio.library.local.H264LevelType;
import org.serviio.library.local.OnlineDBIdentifier;
import org.serviio.library.local.metadata.TransportStreamTimestamp;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.util.ObjectValidator;

public class Video : MediaItem
{
  private Integer duration;
  private Long genreId;
  private Integer bitrate;
  private Integer audioBitrate;
  private Integer audioStreamIndex;
  private Integer videoStreamIndex;
  private String videoFourCC;
  private Integer width;
  private Integer height;
  private Integer channels;
  private String fps;
  private Integer frequency;
  private String rating;
  private Long seriesId;
  private Integer episodeNumber;
  private Integer seasonNumber;
  private VideoContainer container;
  private AudioCodec audioCodec;
  private VideoCodec videoCodec;
  private ContentType contentType;
  private TransportStreamTimestamp timestampType;
  private H264Profile h264Profile;
  private Map!(H264LevelType, String) h264Levels = new HashMap!(H264LevelType, String)();
  private String ftyp;
  private String sar;
  private Map!(OnlineDBIdentifier, String) onlineIdentifiers = new HashMap!(OnlineDBIdentifier, String)();

  public this(String title, VideoContainer container, String fileName, String filePath, Long fileSize, Long folderId, Long repositoryId, Date date)
  {
    super(title, fileName, filePath, fileSize, folderId, repositoryId, date, MediaFileType.VIDEO);
    this.container = container;
  }

  public bool hasSquarePixels()
  {
    if (ObjectValidator.isEmpty(sar)) {
      return true;
    }
    String[] sarParts = sar.split(":");
    if (sarParts.length != 2) {
      return true;
    }
    Float ratio = Float.valueOf(Float.parseFloat(sarParts[0]) / Float.parseFloat(sarParts[1]));
    return Math.abs(1.0F - ratio.floatValue()) < 0.01;
  }

  public Integer getDuration()
  {
    return duration;
  }

  public void setDuration(Integer duration) {
    this.duration = duration;
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

  public Integer getWidth() {
    return width;
  }

  public void setWidth(Integer width) {
    this.width = width;
  }

  public Integer getHeight() {
    return height;
  }

  public void setHeight(Integer height) {
    this.height = height;
  }

  public String getRating() {
    return rating;
  }

  public void setRating(String rating) {
    this.rating = rating;
  }

  public Long getSeriesId() {
    return seriesId;
  }

  public void setSeriesId(Long seriesId) {
    this.seriesId = seriesId;
  }

  public Integer getEpisodeNumber() {
    return episodeNumber;
  }

  public void setEpisodeNumber(Integer episodeNumber) {
    this.episodeNumber = episodeNumber;
  }

  public Integer getSeasonNumber() {
    return seasonNumber;
  }

  public void setSeasonNumber(Integer seasonNumber) {
    this.seasonNumber = seasonNumber;
  }

  public VideoContainer getContainer() {
    return container;
  }

  public void setContainer(VideoContainer container) {
    this.container = container;
  }

  public AudioCodec getAudioCodec() {
    return audioCodec;
  }

  public void setAudioCodec(AudioCodec audioCodec) {
    this.audioCodec = audioCodec;
  }

  public VideoCodec getVideoCodec() {
    return videoCodec;
  }

  public void setVideoCodec(VideoCodec videoCodec) {
    this.videoCodec = videoCodec;
  }

  public Integer getChannels() {
    return channels;
  }

  public void setChannels(Integer channels) {
    this.channels = channels;
  }

  public String getFps() {
    return fps;
  }

  public void setFps(String fps) {
    this.fps = fps;
  }

  public Integer getFrequency() {
    return frequency;
  }

  public void setFrequency(Integer frequency) {
    this.frequency = frequency;
  }

  public ContentType getContentType() {
    return contentType;
  }

  public void setContentType(ContentType contentType) {
    this.contentType = contentType;
  }

  public TransportStreamTimestamp getTimestampType() {
    return timestampType;
  }

  public void setTimestampType(TransportStreamTimestamp timestampType) {
    this.timestampType = timestampType;
  }

  public Integer getAudioBitrate() {
    return audioBitrate;
  }

  public void setAudioBitrate(Integer audioBitrate) {
    this.audioBitrate = audioBitrate;
  }

  public Integer getAudioStreamIndex() {
    return audioStreamIndex;
  }

  public void setAudioStreamIndex(Integer audioStreamIndex) {
    this.audioStreamIndex = audioStreamIndex;
  }

  public Integer getVideoStreamIndex() {
    return videoStreamIndex;
  }

  public void setVideoStreamIndex(Integer videoStreamIndex) {
    this.videoStreamIndex = videoStreamIndex;
  }

  public H264Profile getH264Profile() {
    return h264Profile;
  }

  public void setH264Profile(H264Profile h264Profile) {
    this.h264Profile = h264Profile;
  }

  public String getFtyp() {
    return ftyp;
  }

  public void setFtyp(String ftyp) {
    this.ftyp = ftyp;
  }

  public Map!(OnlineDBIdentifier, String) getOnlineIdentifiers() {
    return onlineIdentifiers;
  }

  public void setOnlineIdentifiers(Map!(OnlineDBIdentifier, String) onlineIdentifiers) {
    this.onlineIdentifiers = onlineIdentifiers;
  }

  public Map!(H264LevelType, String) getH264Levels() {
    return h264Levels;
  }

  public void setH264Levels(Map!(H264LevelType, String) h264Levels) {
    this.h264Levels = h264Levels;
  }

  public String getSar() {
    return sar;
  }

  public void setSar(String sar) {
    this.sar = sar;
  }

  public String getVideoFourCC() {
    return videoFourCC;
  }

  public void setVideoFourCC(String videoFourCC) {
    this.videoFourCC = videoFourCC;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.entities.Video
 * JD-Core Version:    0.6.2
 */