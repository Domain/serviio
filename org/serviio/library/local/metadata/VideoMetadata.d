module org.serviio.library.local.metadata.VideoMetadata;

import java.lang.Integer;
import java.lang.String;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.serviio.dlna.AudioCodec;
import org.serviio.dlna.H264Profile;
import org.serviio.dlna.VideoCodec;
import org.serviio.dlna.VideoContainer;
import org.serviio.library.local.ContentType;
import org.serviio.library.local.H264LevelType;
import org.serviio.library.local.OnlineDBIdentifier;
import org.serviio.library.metadata.InvalidMetadataException;
import org.serviio.util.ObjectValidator;
import org.serviio.library.local.metadata.LocalItemMetadata;
import org.serviio.library.local.metadata.TransportStreamTimestamp;

public class VideoMetadata : LocalItemMetadata
{
  private VideoContainer container;
  private Integer width;
  private Integer height;
  private Integer duration;
  private Integer channels;
  private String fps;
  private String genre;
  private Integer frequency;
  private AudioCodec audioCodec;
  private VideoCodec videoCodec;
  private String videoFourCC;
  private Integer videoStreamIndex;
  private Integer audioStreamIndex;
  private Integer bitrate;
  private Integer videoBitrate;
  private Integer audioBitrate;
  private TransportStreamTimestamp timestampType;
  private H264Profile h264Profile;
  private HashMap!(H264LevelType, String) h264Levels = new HashMap!(H264LevelType, String)();
  private String ftyp;
  private String sar;
  private String rating;
  private List!(String) actors = new ArrayList!(String)();

  private List!(String) directors = new ArrayList!(String)();

  private List!(String) producers = new ArrayList!(String)();
  private String seriesName;
  private Integer seasonNumber;
  private Integer episodeNumber;
  private ContentType contentType;
  private Map!(OnlineDBIdentifier, String) onlineIdentifiers = new HashMap!(OnlineDBIdentifier, String)();

  override public void merge(LocalItemMetadata additionalMetadata)
  {
    if (( cast(VideoMetadata)additionalMetadata !is null )) {
      VideoMetadata additionalVideoMetadata = cast(VideoMetadata)additionalMetadata;

      super.merge(additionalVideoMetadata);

      if (container is null) {
        setContainer(additionalVideoMetadata.getContainer());
      }

      if (contentType is null) {
        setContentType(additionalVideoMetadata.getContentType());
      }

      if (ObjectValidator.isEmpty(genre)) {
        setGenre(additionalVideoMetadata.getGenre());
      }
      if (ObjectValidator.isEmpty(rating)) {
        setRating(additionalVideoMetadata.getRating());
      }
      if (audioCodec is null) {
        setAudioCodec(additionalVideoMetadata.getAudioCodec());
      }
      if (videoCodec is null) {
        setVideoCodec(additionalVideoMetadata.getVideoCodec());
      }
      if (videoFourCC is null) {
        setVideoFourCC(additionalVideoMetadata.getVideoFourCC());
      }
      if (videoStreamIndex is null) {
        setVideoStreamIndex(additionalVideoMetadata.getVideoStreamIndex());
      }
      if (audioStreamIndex is null) {
        setAudioStreamIndex(additionalVideoMetadata.getAudioStreamIndex());
      }
      if (duration is null) {
        setDuration(additionalVideoMetadata.getDuration());
      }
      if (bitrate is null) {
        setBitrate(additionalVideoMetadata.getBitrate());
      }
      if (audioBitrate is null) {
        setAudioBitrate(additionalVideoMetadata.getAudioBitrate());
      }
      if (videoBitrate is null) {
        setVideoBitrate(additionalVideoMetadata.getVideoBitrate());
      }
      if (timestampType is null) {
        setTimestampType(additionalVideoMetadata.getTimestampType());
      }
      if ((h264Levels is null) || (h264Levels.size() == 0)) {
        h264Levels.putAll(additionalVideoMetadata.getH264Levels());
      }
      if (h264Profile is null) {
        setH264Profile(additionalVideoMetadata.getH264Profile());
      }
      if (ftyp is null) {
        setFtyp(additionalVideoMetadata.getFtyp());
      }
      if (sar is null) {
        setSar(additionalVideoMetadata.getSar());
      }
      if (width is null) {
        setWidth(additionalVideoMetadata.getWidth());
      }
      if (height is null) {
        setHeight(additionalVideoMetadata.getHeight());
      }
      if (channels is null) {
        setChannels(additionalVideoMetadata.getChannels());
      }
      if (fps is null) {
        setFps(additionalVideoMetadata.getFps());
      }
      if (frequency is null) {
        setFrequency(additionalVideoMetadata.getFrequency());
      }
      if ((actors is null) || (actors.size() == 0)) {
        setActors(additionalVideoMetadata.getActors());
      }
      if ((directors is null) || (directors.size() == 0)) {
        setDirectors(additionalVideoMetadata.getDirectors());
      }
      if ((producers is null) || (producers.size() == 0)) {
        setProducers(additionalVideoMetadata.getProducers());
      }
      if (ObjectValidator.isEmpty(seriesName)) {
        setSeriesName(additionalVideoMetadata.getSeriesName());
      }
      if (seasonNumber is null) {
        setSeasonNumber(additionalVideoMetadata.getSeasonNumber());
      }
      if (episodeNumber is null) {
        setEpisodeNumber(additionalVideoMetadata.getEpisodeNumber());
      }
      if ((onlineIdentifiers is null) || (onlineIdentifiers.size() == 0))
        onlineIdentifiers.putAll(additionalVideoMetadata.getOnlineIdentifiers());
    }
  }

  override public void fillInUnknownEntries()
  {
    super.fillInUnknownEntries();

    if (ObjectValidator.isEmpty(genre)) {
      setGenre("Unknown");
    }
    if (ObjectValidator.isEmpty(rating)) {
      setRating("Unknown");
    }
    if ((directors is null) || (directors.size() == 0)) {
      setDirectors(Arrays.asList(cast(String[])[ "Unknown" ]));
    }
    if ((producers is null) || (producers.size() == 0)) {
      setProducers(Arrays.asList(cast(String[])[ "Unknown" ]));
    }
    if ((actors is null) || (actors.size() == 0))
      setActors(Arrays.asList(cast(String[])[ "Unknown" ]));
  }

  override public void validateMetadata()
  {
    super.validateMetadata();
    if (contentType is null)
      throw new InvalidMetadataException("Content type missing");
  }

  public Integer getDuration()
  {
    return duration;
  }

  public void setDuration(Integer duration) {
    this.duration = duration;
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

  public String getGenre() {
    return genre;
  }

  public void setGenre(String genre) {
    this.genre = genre;
  }

  public Integer getBitrate() {
    return bitrate;
  }

  public void setBitrate(Integer bitrate) {
    this.bitrate = bitrate;
  }

  public String getRating() {
    return rating;
  }

  public void setRating(String rating) {
    this.rating = rating;
  }

  public List!(String) getActors() {
    return actors;
  }

  public void setActors(List!(String) actors) {
    this.actors = actors;
  }

  public List!(String) getDirectors() {
    return directors;
  }

  public void setDirectors(List!(String) directors) {
    this.directors = directors;
  }

  public List!(String) getProducers() {
    return producers;
  }

  public void setProducers(List!(String) producers) {
    this.producers = producers;
  }

  public String getSeriesName() {
    return seriesName;
  }

  public void setSeriesName(String seriesName) {
    this.seriesName = seriesName;
  }

  public Integer getSeasonNumber() {
    return seasonNumber;
  }

  public void setSeasonNumber(Integer seasonNumber) {
    this.seasonNumber = seasonNumber;
  }

  public Integer getEpisodeNumber() {
    return episodeNumber;
  }

  public void setEpisodeNumber(Integer episodeNumber) {
    this.episodeNumber = episodeNumber;
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

  public VideoContainer getContainer() {
    return container;
  }

  public void setContainer(VideoContainer container) {
    this.container = container;
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

  public Integer getVideoBitrate() {
    return videoBitrate;
  }

  public void setVideoBitrate(Integer videoBitrate) {
    this.videoBitrate = videoBitrate;
  }

  public Integer getAudioBitrate() {
    return audioBitrate;
  }

  public void setAudioBitrate(Integer audioBitrate) {
    this.audioBitrate = audioBitrate;
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

  public Integer getVideoStreamIndex() {
    return videoStreamIndex;
  }

  public void setVideoStreamIndex(Integer videoTrackIndex) {
    videoStreamIndex = videoTrackIndex;
  }

  public Integer getAudioStreamIndex() {
    return audioStreamIndex;
  }

  public void setAudioStreamIndex(Integer audioTrackIndex) {
    audioStreamIndex = audioTrackIndex;
  }

  public H264Profile getH264Profile() {
    return h264Profile;
  }

  public void setH264Profile(H264Profile h264Profile) {
    this.h264Profile = h264Profile;
  }

  public HashMap!(H264LevelType, String) getH264Levels() {
    return h264Levels;
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

  public String getSar() {
    return sar;
  }

  public void setSar(String sar) {
    this.sar = sar;
  }

  public String getVideoFourCC()
  {
    return videoFourCC;
  }

  public void setVideoFourCC(String videoFourCC) {
    this.videoFourCC = videoFourCC;
  }

  override public String toString()
  {
    StringBuilder builder = new StringBuilder();
    builder.append("VideoMetadata [title=").append(title).append(", filePath=").append(filePath).append(", fileSize=").append(fileSize).append(", audioBitrate=").append(audioBitrate).append(", audioCodec=").append(audioCodec).append(", audioStreamIndex=").append(audioStreamIndex).append(", bitrate=").append(bitrate).append(", channels=").append(channels).append(", container=").append(container).append(", contentType=").append(contentType).append(", duration=").append(duration).append(", episodeNumber=").append(episodeNumber).append(", fps=").append(fps).append(", frequency=").append(frequency).append(", h264Levels=").append(h264Levels).append(", h264Profile=").append(h264Profile).append(", ftyp=").append(ftyp).append(", height=").append(height).append(", seasonNumber=").append(seasonNumber).append(", seriesName=").append(seriesName).append(", timestampType=").append(timestampType).append(", videoBitrate=").append(videoBitrate).append(", videoCodec=").append(videoCodec).append(", videoFourCC=").append(videoFourCC).append(", videoStreamIndex=").append(videoStreamIndex).append(", width=").append(width).append("]");

    return builder.toString();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.VideoMetadata
 * JD-Core Version:    0.6.2
 */