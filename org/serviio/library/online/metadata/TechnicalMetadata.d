module org.serviio.library.online.metadata.TechnicalMetadata;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;
import org.serviio.dlna.AudioCodec;
import org.serviio.dlna.AudioContainer;
import org.serviio.dlna.H264Profile;
import org.serviio.dlna.ImageContainer;
import org.serviio.dlna.VideoCodec;
import org.serviio.dlna.VideoContainer;
import org.serviio.library.local.H264LevelType;

public class TechnicalMetadata
  : Serializable, Cloneable
{
  private static final long serialVersionUID = 3657481392836745888L;
  private ImageContainer imageContainer;
  private AudioContainer audioContainer;
  private VideoContainer videoContainer;
  private AudioCodec audioCodec;
  private VideoCodec videoCodec;
  private Integer channels;
  private String fps;
  private Integer videoStreamIndex;
  private Integer audioStreamIndex;
  private Integer videoBitrate;
  private Integer audioBitrate;
  private String ftyp;
  private H264Profile h264Profile;
  private HashMap!(H264LevelType, String) h264Levels = new HashMap!(H264LevelType, String)();
  private String sar;
  private Long fileSize;
  private Integer width;
  private Integer height;
  private Integer bitrate;
  private Long duration;
  private Integer samplingRate;

  public ImageContainer getImageContainer()
  {
    return imageContainer;
  }

  public void setImageContainer(ImageContainer imageContainer) {
    this.imageContainer = imageContainer;
  }

  public Long getFileSize() {
    return fileSize;
  }

  public void setFileSize(Long fileSize) {
    this.fileSize = fileSize;
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

  public Long getDuration() {
    return duration;
  }

  public void setDuration(Long duration) {
    this.duration = duration;
  }

  public Integer getSamplingRate() {
    return samplingRate;
  }

  public void setSamplingRate(Integer samplingRate) {
    this.samplingRate = samplingRate;
  }

  public AudioContainer getAudioContainer() {
    return audioContainer;
  }

  public void setAudioContainer(AudioContainer audioContainer) {
    this.audioContainer = audioContainer;
  }

  public VideoContainer getVideoContainer() {
    return videoContainer;
  }

  public void setVideoContainer(VideoContainer videoContainer) {
    this.videoContainer = videoContainer;
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

  public Map!(H264LevelType, String) getH264Levels() {
    return h264Levels;
  }

  public void setH264Levels(HashMap!(H264LevelType, String) h264Levels) {
    this.h264Levels = h264Levels;
  }

  public String getFps() {
    return fps;
  }

  public void setFps(String fps) {
    this.fps = fps;
  }

  public Integer getVideoStreamIndex() {
    return videoStreamIndex;
  }

  public void setVideoStreamIndex(Integer videoStreamIndex) {
    this.videoStreamIndex = videoStreamIndex;
  }

  public Integer getAudioStreamIndex() {
    return audioStreamIndex;
  }

  public void setAudioStreamIndex(Integer audioStreamIndex) {
    this.audioStreamIndex = audioStreamIndex;
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

  public Integer getBitrate() {
    return bitrate;
  }

  public void setBitrate(Integer bitrate) {
    this.bitrate = bitrate;
  }

  public String getFtyp() {
    return ftyp;
  }

  public void setFtyp(String ftyp) {
    this.ftyp = ftyp;
  }

  public H264Profile getH264Profile() {
    return h264Profile;
  }

  public void setH264Profile(H264Profile h264Profile) {
    this.h264Profile = h264Profile;
  }

  public String getSar() {
    return sar;
  }

  public void setSar(String sar) {
    this.sar = sar;
  }

  
protected TechnicalMetadata clone()
  {
    TechnicalMetadata copy = new TechnicalMetadata();
    copy.setAudioBitrate(audioBitrate !is null ? new Integer(audioBitrate.intValue()) : null);
    copy.setAudioCodec(audioCodec);
    copy.setAudioContainer(audioContainer);
    copy.setAudioStreamIndex(audioStreamIndex !is null ? new Integer(audioStreamIndex.intValue()) : null);
    copy.setBitrate(bitrate !is null ? new Integer(bitrate.intValue()) : null);
    copy.setChannels(channels !is null ? new Integer(channels.intValue()) : null);
    copy.setDuration(duration !is null ? new Long(duration.longValue()) : null);
    copy.setFileSize(fileSize !is null ? new Long(fileSize.longValue()) : null);
    copy.setFps(fps !is null ? new String(fps) : null);
    copy.setHeight(height !is null ? new Integer(height.intValue()) : null);
    copy.setImageContainer(imageContainer);
    copy.setSamplingRate(samplingRate !is null ? new Integer(samplingRate.intValue()) : null);
    copy.setVideoBitrate(videoBitrate !is null ? new Integer(videoBitrate.intValue()) : null);
    copy.setVideoCodec(videoCodec);
    copy.setVideoContainer(videoContainer);
    copy.setVideoStreamIndex(videoStreamIndex !is null ? new Integer(videoStreamIndex.intValue()) : null);
    copy.setWidth(width !is null ? new Integer(width.intValue()) : null);
    copy.setFtyp(ftyp);
    copy.setH264Levels(cast(HashMap!(H264LevelType, String))h264Levels.clone());
    copy.setH264Profile(h264Profile);
    copy.setSar(sar);
    return copy;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.metadata.TechnicalMetadata
 * JD-Core Version:    0.6.2
 */