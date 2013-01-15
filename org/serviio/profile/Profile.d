module org.serviio.profile.Profile;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.serviio.delivery.resource.transcode.TranscodingConfiguration;
import org.serviio.dlna.MediaFormatProfile;
import org.serviio.upnp.DeviceDescription;
import org.serviio.upnp.protocol.http.transport.ResourceTransportProtocolHandler;
import org.serviio.upnp.service.contentdirectory.ProtocolInfo;
import org.serviio.upnp.service.contentdirectory.definition.ContentDirectoryDefinitionFilter;
import org.serviio.util.ObjectValidator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Profile
  : Comparable!(Profile)
{
  private static final Logger log = LoggerFactory.getLogger!(Profile)();
  public static final String DETECTION_FIELD_SERVER = "Server";
  public static final String DETECTION_FIELD_MODEL_NAME = "ModelName";
  public static final String DETECTION_FIELD_FRIENDLY_NAME = "FriendlyName";
  public static final String DETECTION_FIELD_MODEL_NUMBER = "ModelNumber";
  public static final String DETECTION_FIELD_PRODUCT_CODE = "ProductCode";
  public static final String DETECTION_FIELD_MANUFACTURER = "Manufacturer";
  private String id;
  private String name;
  private bool alwaysEnableTranscoding;
  private Class!(Object) contentDirectoryMessageBuilderClass;
  private List!(DetectionDefinition) detectionDefinitions;
  private Map!(MediaFormatProfile, ProtocolInfo) protocolInfo = new LinkedHashMap!(MediaFormatProfile, ProtocolInfo)();
  private DeviceDescription deviceDescription;
  private ResourceTransportProtocolHandler resourceTransportProtocolHandler;
  private String protocolInfoType;
  private ContentDirectoryDefinitionFilter cdDefinitionFilter;
  private DeliveryQuality defaultDeliveryQuality;
  private bool automaticImageRotation;
  private bool limitImageResolution;
  private String subtitlesMimeType;
  private List!(DeliveryQuality) deliveryQualities;
  private bool selectable;
  private H264LevelCheckType h264LevelCheck;

  public this(String id, String name, Class!(Object) contentDirectoryMessageBuilderClass, ResourceTransportProtocolHandler resourceTransportProtocolHandler, List!(DetectionDefinition) detectionDefinitions, Map!(MediaFormatProfile, ProtocolInfo) protocolInfo, String protocolInfoType, DeviceDescription deviceDescription, ContentDirectoryDefinitionFilter cdDefinitionFilter, TranscodingConfiguration transcodingConfiguration, TranscodingConfiguration onlineTranscodingConfiguration, bool automaticImageRotation, bool limitImageResolution, String subtitlesMimeType, bool alwaysEnableTranscoding, bool selectable, List!(DeliveryQuality) deliveryQualities, H264LevelCheckType h264LevelCheck)
  {
    this.id = id;
    this.name = name;
    this.contentDirectoryMessageBuilderClass = contentDirectoryMessageBuilderClass;
    this.resourceTransportProtocolHandler = resourceTransportProtocolHandler;
    this.detectionDefinitions = detectionDefinitions;
    this.protocolInfo = protocolInfo;
    this.deviceDescription = deviceDescription;
    this.protocolInfoType = protocolInfoType;
    this.cdDefinitionFilter = cdDefinitionFilter;
    defaultDeliveryQuality = new DeliveryQuality(DeliveryQuality.QualityType.ORIGINAL, transcodingConfiguration, onlineTranscodingConfiguration);
    this.automaticImageRotation = automaticImageRotation;
    this.limitImageResolution = limitImageResolution;
    this.subtitlesMimeType = subtitlesMimeType;
    this.alwaysEnableTranscoding = alwaysEnableTranscoding;
    this.deliveryQualities = deliveryQualities;
    this.selectable = selectable;
    this.h264LevelCheck = h264LevelCheck;
  }

  public this(String id, String name)
  {
    this.id = id;
    this.name = name;
  }

  public ProtocolInfo getResourceProtocolInfo(MediaFormatProfile mediaFormatProfile)
  {
    if (protocolInfo.containsKey(mediaFormatProfile)) {
      return cast(ProtocolInfo)protocolInfo.get(mediaFormatProfile);
    }
    log.warn("Unregistered media format profile requesed, returning null");
    return null;
  }

  public String getMimeType(MediaFormatProfile profile)
  {
    if (protocolInfo.containsKey(profile)) {
      ProtocolInfo pi = cast(ProtocolInfo)protocolInfo.get(profile);
      return pi.getMimeType();
    }
    log.warn("Unregistered media format profile's mime-type requesed, returning null");
    return null;
  }

  public bool hasAnyTranscodingDefinitions()
  {
    bool hasDef = getDefaultDeliveryQuality().getTranscodingConfiguration() !is null;
    if (!hasDef) {
      foreach (DeliveryQuality quality ; getAlternativeDeliveryQualities()) {
        if (quality.getTranscodingConfiguration() !is null) {
          return true;
        }
      }
    }
    return hasDef;
  }

  public bool hasAnyOnlineTranscodingDefinitions()
  {
    bool hasDef = getDefaultDeliveryQuality().getOnlineTranscodingConfiguration() !is null;
    if (!hasDef) {
      foreach (DeliveryQuality quality ; getAlternativeDeliveryQualities()) {
        if (quality.getOnlineTranscodingConfiguration() !is null) {
          return true;
        }
      }
    }
    return hasDef;
  }

  public String getId()
  {
    return id;
  }

  public String getName() {
    return name;
  }

  public List!(DetectionDefinition) getDetectionDefinitions() {
    return detectionDefinitions;
  }

  public DeviceDescription getDeviceDescription() {
    return deviceDescription;
  }

  public Class!(Object) getContentDirectoryMessageBuilder() {
    return contentDirectoryMessageBuilderClass;
  }

  public ResourceTransportProtocolHandler getResourceTransportProtocolHandler() {
    return resourceTransportProtocolHandler;
  }

  public String getProtocolInfoType() {
    return protocolInfoType;
  }

  public Map!(MediaFormatProfile, ProtocolInfo) getProtocolInfo() {
    return protocolInfo;
  }

  public ContentDirectoryDefinitionFilter getContentDirectoryDefinitionFilter() {
    return cdDefinitionFilter;
  }

  public DeliveryQuality getDefaultDeliveryQuality() {
    return defaultDeliveryQuality;
  }

  public bool isAutomaticImageRotation() {
    return automaticImageRotation;
  }

  public bool isLimitImageResolution() {
    return limitImageResolution;
  }

  public bool isSubtitlesEnabled() {
    return ObjectValidator.isNotEmpty(subtitlesMimeType);
  }

  public String getSubtitlesMimeType() {
    return subtitlesMimeType;
  }

  public bool isAlwaysEnableTranscoding() {
    return alwaysEnableTranscoding;
  }

  public List!(DeliveryQuality) getAlternativeDeliveryQualities() {
    return Collections.unmodifiableList(deliveryQualities);
  }

  public bool isSelectable() {
    return selectable;
  }

  public H264LevelCheckType getH264LevelCheck() {
    return h264LevelCheck;
  }

  public override hash_t toHash()
  {
    int prime = 31;
    int result = 1;
    result = prime * result + (id is null ? super.hashCode() : id.hashCode());
    return result;
  }

  public override equals_t opEquals(Object obj)
  {
    if (this == obj)
      return true;
    if (obj is null)
      return false;
    if (getClass() != obj.getClass())
      return false;
    Profile other = cast(Profile)obj;
    if (id is null) {
      if (other.id !is null)
        return false;
    } else if (!id.equals(other.id))
      return false;
    return true;
  }

  public String toString()
  {
    return name;
  }

  public int compareTo(Profile o)
  {
    if (o !is null) {
      if (getId().equals(o.getId())) {
        return 0;
      }
      if (o.getId().equals("1")) {
        return 1;
      }
      return getName().compareTo(o.getName());
    }

    return -1;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.profile.Profile
 * JD-Core Version:    0.6.2
 */