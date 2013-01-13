module org.serviio.upnp.service.contentdirectory.classes.Resource;

import java.lang.String;
import java.lang.Long;
import java.lang.Integer;
import java.net.MalformedURLException;
import java.net.URL;
import org.serviio.dlna.MediaFormatProfile;
import org.serviio.profile.DeliveryQuality;
import org.serviio.upnp.service.contentdirectory.HostInfo;

public class Resource
{
  public static const String RESOURCE_SEPARATOR = "-";
  private Long resourceId;
  private ResourceType resourceType;
  private MediaFormatProfile ver;
  private Long size;
  private Integer duration;
  private Integer bitrate;
  private Integer sampleFrequency;
  private Integer bitsPerSample;
  private Integer nrAudioChannels;
  private String resolution;
  private Integer colorDepth;
  private String protocolInfo;
  private String protection;
  private Integer protocolInfoIndex = Integer.valueOf(0);
  private DeliveryQuality.QualityType quality;
  private Boolean transcoded;

  public this(ResourceType resourceType, Long resourceId, MediaFormatProfile ver, Integer protocolInfoIndex, DeliveryQuality.QualityType quality, Boolean transcoded)
  {
    this.resourceId = resourceId;
    this.resourceType = resourceType;
    this.ver = ver;
    this.protocolInfoIndex = protocolInfoIndex;
    this.quality = quality;
    this.transcoded = transcoded;
  }

  public String getGeneratedURL(HostInfo hostInfo)
  {
    validate();
    StringBuffer file = new StringBuffer();
    file.append(hostInfo.getContext()).append("/").append(resourceId.toString());
    file.append("/").append(resourceType.toString());
    if (resourceType == ResourceType.MEDIA_ITEM) {
      file.append("/").append(ver.toString());
      file.append("-").append(protocolInfoIndex);
      file.append("/").append(quality.toString());
    }
    if (ResourceType.SUBTITLE == resourceType)
    {
      file.append(".srt");
    }
    if (hostInfo.getHost() !is null) {
      try {
        return (new URL("http", hostInfo.getHost(), hostInfo.getPort().intValue(), file.toString())).toString();
      } catch (MalformedURLException e) {
        throw new RuntimeException("Cannot resolve Resource URL address.");
      }
    }
    return file.toString();
  }

  private void validate()
  {
    if ((resourceId is null) || (resourceType is null) || ((resourceType == ResourceType.MEDIA_ITEM) && ((ver is null) || (quality is null) || (protocolInfoIndex is null))))
      throw new InvalidResourceException("Resource is not valid.");
  }

  public Long getSize()
  {
    return size;
  }

  public void setSize(Long size) {
    this.size = size;
  }

  public Integer getDuration() {
    return duration;
  }

  public void setDuration(Integer duration) {
    this.duration = duration;
  }

  public String getDurationFormatted() {
    if (duration !is null) {
      int hours = duration.intValue() / 3600;
      int minutes = hours > 0 ? duration.intValue() % (hours * 3600) / 60 : duration.intValue() / 60;
      int seconds = duration.intValue() - (hours * 3600 + minutes * 60);
      return String.format("%d:%02d:%02d.000", cast(Object[])[ Integer.valueOf(hours), Integer.valueOf(minutes), Integer.valueOf(seconds) ]);
    }
    return null;
  }

  public Integer getBitrate()
  {
    return bitrate;
  }

  public void setBitrate(Integer bitrate) {
    this.bitrate = bitrate;
  }

  public Integer getSampleFrequency() {
    return sampleFrequency;
  }

  public void setSampleFrequency(Integer sampleFrequency) {
    this.sampleFrequency = sampleFrequency;
  }

  public Integer getBitsPerSample() {
    return bitsPerSample;
  }

  public void setBitsPerSample(Integer bitsPerSample) {
    this.bitsPerSample = bitsPerSample;
  }

  public Integer getNrAudioChannels() {
    return nrAudioChannels;
  }

  public void setNrAudioChannels(Integer nrAudioChannels) {
    this.nrAudioChannels = nrAudioChannels;
  }

  public String getResolution() {
    return resolution;
  }

  public void setResolution(String resolution) {
    this.resolution = resolution;
  }

  public Integer getColorDepth() {
    return colorDepth;
  }

  public void setColorDepth(Integer colorDepth) {
    this.colorDepth = colorDepth;
  }

  public String getProtocolInfo() {
    return protocolInfo;
  }

  public void setProtocolInfo(String protocolInfo) {
    this.protocolInfo = protocolInfo;
  }

  public String getProtection() {
    return protection;
  }

  public void setProtection(String protection) {
    this.protection = protection;
  }

  public ResourceType getResourceType() {
    return resourceType;
  }

  public Integer getProtocolInfoIndex() {
    return protocolInfoIndex;
  }

  public DeliveryQuality.QualityType getQuality() {
    return quality;
  }

  public Boolean isTranscoded() {
    return transcoded;
  }

  public static enum ResourceType
  {
    MEDIA_ITEM, COVER_IMAGE, SUBTITLE
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.Resource
 * JD-Core Version:    0.6.2
 */