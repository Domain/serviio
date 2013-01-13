module org.serviio.profile.ProfilesDefinitionParser;

import java.io.IOException;
import java.io.InputStream;
import java.net.InetAddress;
import java.net.URL;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map : Entry;
import javax.xml.xpath.XPathExpressionException;
import org.serviio.MediaServer;
import org.serviio.delivery.resource.transcode.AudioTranscodingDefinition;
import org.serviio.delivery.resource.transcode.AudioTranscodingMatch;
import org.serviio.delivery.resource.transcode.ImageTranscodingDefinition;
import org.serviio.delivery.resource.transcode.ImageTranscodingMatch;
import org.serviio.delivery.resource.transcode.TranscodingConfiguration;
import org.serviio.delivery.resource.transcode.TranscodingDefinition;
import org.serviio.delivery.resource.transcode.VideoTranscodingDefinition;
import org.serviio.delivery.resource.transcode.VideoTranscodingMatch;
import org.serviio.dlna.AudioCodec;
import org.serviio.dlna.AudioContainer;
import org.serviio.dlna.DisplayAspectRatio;
import org.serviio.dlna.H264Profile;
import org.serviio.dlna.ImageContainer;
import org.serviio.dlna.MediaFormatProfile;
import org.serviio.dlna.SamplingMode;
import org.serviio.dlna.VideoCodec;
import org.serviio.dlna.VideoContainer;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.upnp.DeviceDescription;
import org.serviio.upnp.protocol.http.transport.ResourceTransportProtocolHandler;
import org.serviio.upnp.service.contentdirectory.ContentDirectoryMessageBuilder;
import org.serviio.upnp.service.contentdirectory.DLNAProtocolAdditionalInfo;
import org.serviio.upnp.service.contentdirectory.ProtocolAdditionalInfo;
import org.serviio.upnp.service.contentdirectory.ProtocolInfo;
import org.serviio.upnp.service.contentdirectory.SimpleProtocolInfo;
import org.serviio.upnp.service.contentdirectory.definition.ContentDirectoryDefinitionFilter;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;
import org.serviio.util.XPathUtil;
import org.serviio.util.XmlUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class ProfilesDefinitionParser
{
  private static final Logger log = LoggerFactory.getLogger!(ProfilesDefinitionParser);
  private static final String PROFILES_XSD = "Profiles.xsd";
  private static final String TAG_PROFILES = "Profiles";
  private static final String TAG_PROFILE = "Profile";
  private static final String TAG_CONTENT_DIRECTORY_MESSAGE_BUILDER = "ContentDirectoryMessageBuilder";
  private static final String TAG_RESOURCE_TRANSPORT_PROTOCOL_HANDLER = "ResourceTransportProtocolHandler";
  private static final String TAG_CONTENT_DIRECTORY_DEFINITION_FILTER = "ContentDirectoryDefinitionFilter";
  private static final String TAG_DETECTION = "Detection";
  private static final String TAG_PROTOCOL_INFO = "ProtocolInfo";
  private static final String TAG_MEDIA_PROFILES = "MediaFormatProfiles";
  private static final String TAG_MEDIA_PROFILE = "MediaFormatProfile";
  private static final String TAG_DEVICE_DESCRIPTION = "DeviceDescription";
  private static final String TAG_UPNP_SEARCH = "UPnPSearch";
  private static final String TAG_HTTP_HEADERS = "HttpHeaders";
  private static final String TAG_FRIENDLY_NAME = "FriendlyName";
  private static final String TAG_MODEL_NAME = "ModelName";
  private static final String TAG_MODEL_NUMBER = "ModelNumber";
  private static final String TAG_MANUFACTURER = "Manufacturer";
  private static final String TAG_EXTRA_ELEMENTS = "ExtraElements";
  private static final String TAG_TRANSCODING = "Transcoding";
  private static final String TAG_ONLINE_TRANSCODING = "OnlineTranscoding";
  private static final String TAG_ALTERNATIVE_QUALITIES = "AlternativeQualities";
  private static final String TAG_QUALITY = "Quality";
  private static final String TAG_TRANSCODING_VIDEO = "Video";
  private static final String TAG_TRANSCODING_AUDIO = "Audio";
  private static final String TAG_TRANSCODING_IMAGE = "Image";
  private static final String TAG_TRANSCODING_MATCHES = "Matches";
  private static final String TAG_AUTOMATIC_IMAGE_ROTATION = "AutomaticImageRotation";
  private static final String TAG_LIMIT_IMAGE_RESOLUTION = "LimitImageResolution";
  private static final String TAG_SUBTITLES_MIME_TYPE = "SubtitlesMimeType";
  private static final String TAG_H264_LEVEL_CHECK = "H264LevelCheck";
  private static final String PROTOCOL_INFO_SIMPLE = "simple";
  private static final String PROTOCOL_INFO_DLNA = "DLNA";
  private static final String COMP_NAME_VARIABLE = "\\{computerName\\}";
  private static String COMP_NAME;

  public static List!(Profile) parseDefinition(InputStream definitionStream, List!(Profile) currentProfiles)
  {
    if (definitionStream is null)
      throw new ProfilesDefinitionException("Profiles definition is not present.");
    try
    {
      String xml = StringUtils.readStreamAsString(definitionStream, "UTF-8");

      validateXML(xml);

      Node definitionRoot = XPathUtil.getRootNode(xml);

      Node profilesNode = XPathUtil.getNode(definitionRoot, TAG_PROFILES);
      if (profilesNode is null) {
        throw new ProfilesDefinitionException("Profiles definition doesn't contain a root Profiles node.");
      }

      log.info("Parsing Profiles definition");

      List!(Profile) profiles = new ArrayList!(Profile)(currentProfiles);
      NodeList profileNodes = XPathUtil.getNodeSet(profilesNode, TAG_PROFILE);
      for (int i = 0; i < profileNodes.getLength(); i++) {
        Profile profile = processProfileNode(profileNodes.item(i), profiles);
        profiles.add(profile);
      }
      return profiles;
    } catch (IOException e) {
      throw new ProfilesDefinitionException(String.format("Cannot read Profiles XML. Reason: %s", cast(Object[])[ e.getMessage() ])); } catch (XPathExpressionException e) {
    }
    throw new ProfilesDefinitionException("Cannot read Profiles XML. The file is corrupted.");
  }

  private static Profile processProfileNode(Node profileNode, List!(Profile) profiles)
  {
    String id = XPathUtil.getNodeValue(profileNode, "@id");
    if (ObjectValidator.isNotEmpty(id)) {
      log.debug_(String.format("Parsing profile definition for profile %s", cast(Object[])[ id ]));
      if (getProfileById(profiles, id) !is null) {
        throw new ProfilesDefinitionException(String.format("Duplicate profile id %s", cast(Object[])[ id ]));
      }
      Profile parentProfile = null;
      String extendsProfileId = XPathUtil.getNodeValue(profileNode, "@extendsProfileId");
      if (ObjectValidator.isNotEmpty(extendsProfileId)) {
        parentProfile = getProfileById(profiles, extendsProfileId);
        if (parentProfile is null) {
          throw new ProfilesDefinitionException(String.format("Profile %s cannot find profile with id %s to extend from. The parent profile must be defined before this profile.", cast(Object[])[ id, extendsProfileId ]));
        }
      }
      String h264LevelCheckTypeValue = XPathUtil.getNodeValue(profileNode, TAG_H264_LEVEL_CHECK);
      H264LevelCheckType h264LevelCheckType = null;
      if (ObjectValidator.isNotEmpty(h264LevelCheckTypeValue)) {
        h264LevelCheckType = H264LevelCheckType.valueOf(h264LevelCheckTypeValue);
      }
      h264LevelCheckType = (h264LevelCheckType is null) && (parentProfile !is null) ? parentProfile.getH264LevelCheck() : h264LevelCheckType;
      String name = XPathUtil.getNodeValue(profileNode, "@name");
      List!(DetectionDefinition) detectionDefinitions = getDetectionDefinitions(id, profileNode);
      Class!(Object) cdMessageBuilderClass = getContentDirectoryMessageBuilderClass(id, profileNode);
      ResourceTransportProtocolHandler resourceTrasportProtocolHandler = getResourceTransportProtocolHandler(id, profileNode);
      ContentDirectoryDefinitionFilter contentDirectoryDefinitionFilter = getContentDirectoryDefinitionFilter(id, profileNode);
      TranscodingConfiguration onlineTranscodeConfig = getTranscodingConfiguration(id, XPathUtil.getNode(profileNode, TAG_ONLINE_TRANSCODING), parentProfile !is null ? parentProfile.getDefaultDeliveryQuality().getOnlineTranscodingConfiguration() : null, h264LevelCheckType, true);

      TranscodingConfiguration transcodeConfig = getTranscodingConfiguration(id, XPathUtil.getNode(profileNode, TAG_TRANSCODING), parentProfile !is null ? parentProfile.getDefaultDeliveryQuality().getTranscodingConfiguration() : null, h264LevelCheckType, false);

      DeviceDescription deviceDescription = getDeviceDescription(id, profileNode, parentProfile);
      String protocolInfoType = XPathUtil.getNodeValue(profileNode, TAG_PROTOCOL_INFO);
      String automaticImageRotation = XPathUtil.getNodeValue(profileNode, TAG_AUTOMATIC_IMAGE_ROTATION);
      String limitImageResolution = XPathUtil.getNodeValue(profileNode, TAG_LIMIT_IMAGE_RESOLUTION);
      String subtitlesMimeType = XPathUtil.getNodeValue(profileNode, TAG_SUBTITLES_MIME_TYPE);
      String alwaysEnableTranscoding = XPathUtil.getNodeValue(profileNode, "@alwaysEnableTranscoding");
      String selectable = XPathUtil.getNodeValue(profileNode, "@selectable");
      if (ObjectValidator.isEmpty(protocolInfoType)) {
        protocolInfoType = null;
      }
      protocolInfoType = (protocolInfoType is null) && (parentProfile !is null) ? parentProfile.getProtocolInfoType() : protocolInfoType;
      Map!(MediaFormatProfile, ProtocolInfo) protocolInfos = getProtocolInfoMap(id, profileNode, protocolInfoType, parentProfile);
      Profile profile = new Profile(id, name, (cdMessageBuilderClass is null) && (parentProfile !is null) ? parentProfile.getContentDirectoryMessageBuilder() : cdMessageBuilderClass, (resourceTrasportProtocolHandler is null) && (parentProfile !is null) ? parentProfile.getResourceTransportProtocolHandler() : resourceTrasportProtocolHandler, detectionDefinitions, protocolInfos, protocolInfoType, deviceDescription, (contentDirectoryDefinitionFilter is null) && (parentProfile !is null) ? parentProfile.getContentDirectoryDefinitionFilter() : contentDirectoryDefinitionFilter, transcodeConfig, onlineTranscodeConfig, (ObjectValidator.isEmpty(automaticImageRotation)) && (parentProfile !is null) ? parentProfile.isAutomaticImageRotation() : Boolean.parseBoolean(automaticImageRotation), (ObjectValidator.isEmpty(limitImageResolution)) && (parentProfile !is null) ? parentProfile.isLimitImageResolution() : Boolean.parseBoolean(limitImageResolution), (subtitlesMimeType is null) && (parentProfile !is null) ? parentProfile.getSubtitlesMimeType() : subtitlesMimeType, Boolean.parseBoolean(alwaysEnableTranscoding), selectable !is null ? Boolean.parseBoolean(selectable) : true, getAlternativeDeliveryQualities(id, profileNode, h264LevelCheckType), h264LevelCheckType);

      if (validateProfile(profile)) {
        log.info(String.format("Added profile '%s' (id=%s)", cast(Object[])[ name, id ]));
        return profile;
      }
      throw new ProfilesDefinitionException("Profile validation failed. Check the log.");
    }

    throw new ProfilesDefinitionException("Invalid profiles definition. A profile is missing id attribute.");
  }

  private static Class!(Object) getContentDirectoryMessageBuilderClass(String profileId, Node profileNode)
  {
    String className = XPathUtil.getNodeValue(profileNode, TAG_CONTENT_DIRECTORY_MESSAGE_BUILDER);
    if (ObjectValidator.isNotEmpty(className)) {
      try {
        Class!(Object) clazz = Class.forName(className.trim());
        if (!ContentDirectoryMessageBuilder.class_.isAssignableFrom(clazz))
        {
          throw new ProfilesDefinitionException(String.format("Class %s defining ContentDirectoryMessageBuilder for profile %s is not of a proper type", cast(Object[])[ className, profileId ]));
        }
        return clazz;
      } catch (ClassNotFoundException e) {
        throw new ProfilesDefinitionException(String.format("Class %s defining ContentDirectoryMessageBuilder of profile %s does not exist", cast(Object[])[ className, profileId ]));
      }
    }
    return null;
  }

  private static ResourceTransportProtocolHandler getResourceTransportProtocolHandler(String profileId, Node profileNode)
  {
    String className = XPathUtil.getNodeValue(profileNode, TAG_RESOURCE_TRANSPORT_PROTOCOL_HANDLER);
    if (ObjectValidator.isNotEmpty(className)) {
      try {
        Class!(Object) clazz = Class.forName(className);
        if (!ResourceTransportProtocolHandler.class_.isAssignableFrom(clazz))
        {
          throw new ProfilesDefinitionException(String.format("Class %s defining ResourceTransportProtocolHandler for profile %s is not of a proper type", cast(Object[])[ className, profileId ]));
        }
        return cast(ResourceTransportProtocolHandler)clazz.newInstance();
      } catch (ClassNotFoundException e) {
        throw new ProfilesDefinitionException(String.format("Class %s defining ResourceTransportProtocolHandler of profile %s does not exist", cast(Object[])[ className, profileId ]));
      } catch (InstantiationException e) {
        throw new ProfilesDefinitionException(String.format("Cannot instantiate ResourceTransportProtocolHandler of profile %s", cast(Object[])[ profileId ]));
      } catch (IllegalAccessException e) {
        throw new ProfilesDefinitionException(String.format("Cannot instantiate ResourceTransportProtocolHandler of profile %s", cast(Object[])[ profileId ]));
      }
    }
    return null;
  }

  private static ContentDirectoryDefinitionFilter getContentDirectoryDefinitionFilter(String profileId, Node profileNode)
  {
    String className = XPathUtil.getNodeValue(profileNode, TAG_CONTENT_DIRECTORY_DEFINITION_FILTER);
    if (ObjectValidator.isNotEmpty(className)) {
      try {
        Class!(Object) clazz = Class.forName(className);
        if (!ContentDirectoryDefinitionFilter.class_.isAssignableFrom(clazz))
        {
          throw new ProfilesDefinitionException(String.format("Class %s defining ContentDirectoryDefinitionFilter for profile %s is not of a proper type", cast(Object[])[ className, profileId ]));
        }
        return cast(ContentDirectoryDefinitionFilter)clazz.newInstance();
      } catch (ClassNotFoundException e) {
        throw new ProfilesDefinitionException(String.format("Class %s defining ContentDirectoryDefinitionFilter of profile %s does not exist", cast(Object[])[ className, profileId ]));
      } catch (InstantiationException e) {
        throw new ProfilesDefinitionException(String.format("Cannot instantiate ContentDirectoryDefinitionFilter of profile %s", cast(Object[])[ profileId ]));
      } catch (IllegalAccessException e) {
        throw new ProfilesDefinitionException(String.format("Cannot instantiate ContentDirectoryDefinitionFilter of profile %s", cast(Object[])[ profileId ]));
      }
    }
    return null;
  }

  private static DeviceDescription getDeviceDescription(String profileId, Node profileNode, Profile parentProfile)
  {
    Node ddNode = XPathUtil.getNode(profileNode, TAG_DEVICE_DESCRIPTION);
    if (ddNode !is null) {
      String friendlyName = XPathUtil.getNodeValue(ddNode, TAG_FRIENDLY_NAME);
      if (friendlyName !is null)
      {
        friendlyName = friendlyName.replaceFirst(COMP_NAME_VARIABLE, COMP_NAME);
      }
      else friendlyName = parentProfile !is null ? parentProfile.getDeviceDescription().getFriendlyName() : null;

      String modelName = XPathUtil.getNodeValue(ddNode, TAG_MODEL_NAME);
      if (modelName is null) {
        modelName = parentProfile !is null ? parentProfile.getDeviceDescription().getModelName() : null;
      }

      String modelNumber = XPathUtil.getNodeValue(ddNode, TAG_MODEL_NUMBER);
      if (modelNumber is null) {
        modelNumber = parentProfile !is null ? parentProfile.getDeviceDescription().getModelNumber() : null;
      }

      String manufacturer = XPathUtil.getNodeValue(ddNode, TAG_MANUFACTURER);
      if (manufacturer is null) {
        manufacturer = parentProfile !is null ? parentProfile.getDeviceDescription().getManufacturer() : null;
      }

      String extraElements = XPathUtil.getNodeValue(ddNode, TAG_EXTRA_ELEMENTS);
      if (extraElements is null)
        extraElements = parentProfile !is null ? parentProfile.getDeviceDescription().getExtraElements() : null;
      else {
        extraElements = XmlUtils.decodeXml(extraElements.trim());
      }
      if ((ObjectValidator.isNotEmpty(friendlyName)) && (ObjectValidator.isNotEmpty(modelName)) && (ObjectValidator.isNotEmpty(manufacturer))) {
        String number = ObjectValidator.isEmpty(modelNumber) ? MediaServer.VERSION : modelNumber;
        return new DeviceDescription(friendlyName, modelName, number, manufacturer, extraElements);
      }
      throw new ProfilesDefinitionException(String.format("Profile %s has incomplete device description", cast(Object[])[ profileId ]));
    }

    return parentProfile.getDeviceDescription();
  }

  private static List!(DetectionDefinition) getDetectionDefinitions(String profileId, Node profileNode) {
    Node ddNode = XPathUtil.getNode(profileNode, TAG_DETECTION);

    if (ddNode !is null) {
      List!(DetectionDefinition) result = new ArrayList!(DetectionDefinition)();
      Node upnpSearchNode = XPathUtil.getNode(ddNode, TAG_UPNP_SEARCH);
      Node httpHeadersNode = XPathUtil.getNode(ddNode, TAG_HTTP_HEADERS);
      if (upnpSearchNode !is null) {
        DetectionDefinition dd = new DetectionDefinition(DetectionDefinition.DetectionType.UPNP_SEARCH);
        dd.getFieldValues().putAll(getAllDetectionFields(upnpSearchNode));
        result.add(dd);
      }
      if (httpHeadersNode !is null) {
        DetectionDefinition dd = new DetectionDefinition(DetectionDefinition.DetectionType.HTTP_HEADERS);
        dd.getFieldValues().putAll(getAllDetectionFields(httpHeadersNode));
        result.add(dd);
      }
      return result;
    }
    return null;
  }

  private static Map!(String, String) getAllDetectionFields(Node parentNode) {
    NodeList headerNodes = XPathUtil.getNodeSet(parentNode, "*");
    Map!(String, String) headers = new HashMap!(String, String)();
    for (int i = 0; i < headerNodes.getLength(); i++) {
      Node headerNode = headerNodes.item(i);
      headers.put(headerNode.getNodeName(), headerNode.getTextContent());
    }
    return headers;
  }

  private static TranscodingConfiguration getTranscodingConfiguration(String profileId, Node trNode, TranscodingConfiguration parentTranscodingConfig, H264LevelCheckType h264LevelCheck, bool inherits)
  {
    if ((trNode is null) && (inherits))
      return parentTranscodingConfig;
    if ((trNode !is null) || (transcodingConfigIncludesForcedItems(parentTranscodingConfig))) {
      TranscodingConfiguration trConfig = new TranscodingConfiguration();

      bool keepStreamOpen = (parentTranscodingConfig !is null) && (trNode is null) ? parentTranscodingConfig.isKeepStreamOpen() : true;
      if (trNode !is null) {
        String keepStreamOpenValue = XPathUtil.getNodeValue(trNode, "@keepStreamOpen");
        if (ObjectValidator.isNotEmpty(keepStreamOpenValue)) {
          keepStreamOpen = Boolean.valueOf(keepStreamOpenValue).boolValue();
        }
      }
      trConfig.setKeepStreamOpen(keepStreamOpen);

      getVideoTranscodingConfiguration(profileId, trNode, trConfig, parentTranscodingConfig, h264LevelCheck);
      getAudioTranscodingConfiguration(profileId, trNode, trConfig, parentTranscodingConfig);
      getImageTranscodingConfiguration(profileId, trNode, trConfig, parentTranscodingConfig);
      return trConfig;
    }
    return null;
  }

  private static void getVideoTranscodingConfiguration(String profileId, Node trNode, TranscodingConfiguration trConfig, TranscodingConfiguration parentTrConfig, H264LevelCheckType h264LevelCheck)
  {
    if (trNode !is null) {
      NodeList videoNodes = XPathUtil.getNodeSet(trNode, TAG_TRANSCODING_VIDEO);
      for (int i = 0; i < videoNodes.getLength(); i++) {
        Node videoNode = videoNodes.item(i);

        VideoContainer targetContainer = VideoContainer.getByFFmpegValue(XPathUtil.getNodeValue(videoNode, "@targetContainer"), null);
        if (targetContainer is null) {
          throw new ProfilesDefinitionException(String.format("Profile %s has unsupported target container in video transcoding definition", cast(Object[])[ profileId ]));
        }
        String vCodecName = XPathUtil.getNodeValue(videoNode, "@targetVCodec");
        String aCodecName = XPathUtil.getNodeValue(videoNode, "@targetACodec");
        String maxVideoBitrateValue = XPathUtil.getNodeValue(videoNode, "@maxVBitrate");
        String maxHeightValue = XPathUtil.getNodeValue(videoNode, "@maxHeight");
        String audioBitrateValue = XPathUtil.getNodeValue(videoNode, "@aBitrate");
        String audioSampleRateValue = XPathUtil.getNodeValue(videoNode, "@aSamplerate");
        String forceVTranscodingValue = XPathUtil.getNodeValue(videoNode, "@forceVTranscoding");
        String forceStereoValue = XPathUtil.getNodeValue(videoNode, "@forceStereo");
        String forceInheritanceValue = XPathUtil.getNodeValue(videoNode, "@forceInheritance");
        String darName = XPathUtil.getNodeValue(videoNode, "@DAR");
        VideoCodec targetVCodec = null;
        AudioCodec targetACodec = null;
        Integer maxVideoBitrate = null;
        Integer maxHeight = null;
        Integer audioBitrate = null;
        Integer audioSamplerate = null;
        Boolean forceVTranscoding = Boolean.FALSE;
        Boolean forceStereo = Boolean.FALSE;
        Boolean forceInheritance = Boolean.FALSE;
        DisplayAspectRatio dar = null;
        if (ObjectValidator.isNotEmpty(vCodecName)) {
          targetVCodec = VideoCodec.getByFFmpegValue(vCodecName);
          if (targetVCodec is null) {
            throw new ProfilesDefinitionException(String.format("Profile %s has unsupported target video codec '%s' in transcoding definition", cast(Object[])[ profileId, vCodecName ]));
          }
        }
        if (ObjectValidator.isNotEmpty(aCodecName)) {
          targetACodec = AudioCodec.getByFFmpegDecoderName(aCodecName);
          if (targetACodec is null) {
            throw new ProfilesDefinitionException(String.format("Profile %s has unsupported target audio codec '%s' in transcoding definition", cast(Object[])[ profileId, aCodecName ]));
          }
        }
        if (ObjectValidator.isNotEmpty(maxVideoBitrateValue)) {
          maxVideoBitrate = Integer.valueOf(maxVideoBitrateValue);
        }
        if (ObjectValidator.isNotEmpty(maxHeightValue)) {
          maxHeight = Integer.valueOf(maxHeightValue);
        }
        if (ObjectValidator.isNotEmpty(audioBitrateValue)) {
          audioBitrate = Integer.valueOf(audioBitrateValue);
        }
        if (ObjectValidator.isNotEmpty(audioSampleRateValue)) {
          audioSamplerate = Integer.valueOf(audioSampleRateValue);
        }
        if (ObjectValidator.isNotEmpty(forceVTranscodingValue)) {
          forceVTranscoding = Boolean.valueOf(forceVTranscodingValue);
        }
        if (ObjectValidator.isNotEmpty(forceStereoValue)) {
          forceStereo = Boolean.valueOf(forceStereoValue);
        }
        if (ObjectValidator.isNotEmpty(forceInheritanceValue)) {
          forceInheritance = Boolean.valueOf(forceInheritanceValue);
        }
        if (ObjectValidator.isNotEmpty(darName)) {
          dar = DisplayAspectRatio.fromString(darName);
        }
        VideoTranscodingDefinition td = new VideoTranscodingDefinition(trConfig, targetContainer, targetVCodec, targetACodec, maxVideoBitrate, maxHeight, audioBitrate, audioSamplerate, forceVTranscoding.boolValue(), forceStereo.boolValue(), forceInheritance.boolValue(), dar);

        NodeList matcherNodes = XPathUtil.getNodeSet(videoNode, TAG_TRANSCODING_MATCHES);
        for (int j = 0; j < matcherNodes.getLength(); j++) {
          Node matcherNode = matcherNodes.item(j);

          VideoContainer container = VideoContainer.getByFFmpegValue(XPathUtil.getNodeValue(matcherNode, "@container"), null);
          if (container is null) {
            throw new ProfilesDefinitionException(String.format("Profile %s has unsupported matcher video container in transcoding definition", cast(Object[])[ profileId ]));
          }
          String vcName = XPathUtil.getNodeValue(matcherNode, "@vCodec");
          String acName = XPathUtil.getNodeValue(matcherNode, "@aCodec");
          String h264ProfileName = XPathUtil.getNodeValue(matcherNode, "@profile");
          String h264LevelGTValue = XPathUtil.getNodeValue(matcherNode, "@levelGreaterThan");
          String ftypNotInValue = XPathUtil.getNodeValue(matcherNode, "@ftypNotIn");
          String vFourCCValue = XPathUtil.getNodeValue(matcherNode, "@vFourCC");
          //String mkvHeaderCompressedValue = XPathUtil.getNodeValue(matcherNode, "@mkvHeaderCompressed");
          String squarePixelsValue = XPathUtil.getNodeValue(matcherNode, "@squarePixels");
          String onlineContentTypeValue = XPathUtil.getNodeValue(matcherNode, "@contentType");
          H264Profile h264Profile = null;
          Float h264LevelGT = null;
          VideoCodec vCodec = null;
          AudioCodec aCodec = null;
          Boolean squarePixels = null;
          OnlineContentType onlineContentType = OnlineContentType.ANY;
          if (ObjectValidator.isNotEmpty(vcName)) {
            vCodec = VideoCodec.getByFFmpegValue(vcName);
            if (vCodec is null) {
              throw new ProfilesDefinitionException(String.format("Profile %s has unsupported video codec '%s' in transcoding definition", cast(Object[])[ profileId, vcName ]));
            }
          }
          if (ObjectValidator.isNotEmpty(acName)) {
            aCodec = AudioCodec.getByFFmpegDecoderName(acName);
            if (aCodec is null) {
              throw new ProfilesDefinitionException(String.format("Profile %s has unsupported audio codec '%s' in transcoding definition", cast(Object[])[ profileId, acName ]));
            }
          }
          if (ObjectValidator.isNotEmpty(h264ProfileName)) {
            h264Profile = H264Profile.valueOf(StringUtils.localeSafeToUppercase(h264ProfileName));
          }
          if (ObjectValidator.isNotEmpty(h264LevelGTValue)) {
            h264LevelGT = new Float(h264LevelGTValue);
          }
          if (ObjectValidator.isNotEmpty(onlineContentTypeValue)) {
            onlineContentType = OnlineContentType.valueOf(StringUtils.localeSafeToUppercase(onlineContentTypeValue));
          }
          if (ObjectValidator.isNotEmpty(squarePixelsValue)) {
            squarePixels = new Boolean(squarePixelsValue);
          }
          td.getMatches().add(new VideoTranscodingMatch(container, vCodec, aCodec, h264Profile, h264LevelGT, ftypNotInValue, onlineContentType, squarePixels, vFourCCValue, h264LevelCheck));
        }
        trConfig.addDefinition(MediaFileType.VIDEO, td);
      }
    }
    addInheritedTranscodingConfigs(MediaFileType.VIDEO, trConfig, parentTrConfig);
  }

  private static void getAudioTranscodingConfiguration(String profileId, Node trNode, TranscodingConfiguration trConfig, TranscodingConfiguration parentTrConfig)
  {
    if (trNode !is null) {
      NodeList audioNodes = XPathUtil.getNodeSet(trNode, TAG_TRANSCODING_AUDIO);
      for (int i = 0; i < audioNodes.getLength(); i++) {
        Node audioNode = audioNodes.item(i);

        AudioContainer targetContainer = AudioContainer.getByName(XPathUtil.getNodeValue(audioNode, "@targetContainer"));
        if (targetContainer is null) {
          throw new ProfilesDefinitionException(String.format("Profile %s has unsupported target container in audio transcoding definition", cast(Object[])[ profileId ]));
        }
        String audioBitrateValue = XPathUtil.getNodeValue(audioNode, "@aBitrate");
        String audioSampleRateValue = XPathUtil.getNodeValue(audioNode, "@aSamplerate");
        String forceInheritanceValue = XPathUtil.getNodeValue(audioNode, "@forceInheritance");
        Integer audioBitrate = null;
        Integer audioSamplerate = null;
        Boolean forceInheritance = Boolean.FALSE;
        if (ObjectValidator.isNotEmpty(audioBitrateValue)) {
          audioBitrate = Integer.valueOf(audioBitrateValue);
        }
        if (ObjectValidator.isNotEmpty(audioSampleRateValue)) {
          audioSamplerate = Integer.valueOf(audioSampleRateValue);
        }
        if (ObjectValidator.isNotEmpty(forceInheritanceValue)) {
          forceInheritance = Boolean.valueOf(forceInheritanceValue);
        }
        AudioTranscodingDefinition td = new AudioTranscodingDefinition(trConfig, targetContainer, audioBitrate, audioSamplerate, forceInheritance.boolValue());

        NodeList matcherNodes = XPathUtil.getNodeSet(audioNode, TAG_TRANSCODING_MATCHES);
        for (int j = 0; j < matcherNodes.getLength(); j++) {
          Node matcherNode = matcherNodes.item(j);

          AudioContainer container = AudioContainer.getByName(XPathUtil.getNodeValue(matcherNode, "@container"));
          if (container is null) {
            throw new ProfilesDefinitionException(String.format("Profile %s has unsupported matcher audio container in transcoding definition", cast(Object[])[ profileId ]));
          }
          String onlineContentTypeValue = XPathUtil.getNodeValue(matcherNode, "@contentType");
          OnlineContentType onlineContentType = OnlineContentType.ANY;
          if (ObjectValidator.isNotEmpty(onlineContentTypeValue)) {
            onlineContentType = OnlineContentType.valueOf(StringUtils.localeSafeToUppercase(onlineContentTypeValue));
          }
          td.getMatches().add(new AudioTranscodingMatch(container, onlineContentType));
        }
        trConfig.addDefinition(MediaFileType.AUDIO, td);
      }
    }
    addInheritedTranscodingConfigs(MediaFileType.AUDIO, trConfig, parentTrConfig);
  }

  private static void getImageTranscodingConfiguration(String profileId, Node trNode, TranscodingConfiguration trConfig, TranscodingConfiguration parentTrConfig)
  {
    if (trNode !is null) {
      NodeList imageNodes = XPathUtil.getNodeSet(trNode, TAG_TRANSCODING_IMAGE);
      for (int i = 0; i < imageNodes.getLength(); i++) {
        Node imageNode = imageNodes.item(i);
        String forceInheritanceValue = XPathUtil.getNodeValue(imageNode, "@forceInheritance");
        Boolean forceInheritance = Boolean.FALSE;
        if (ObjectValidator.isNotEmpty(forceInheritanceValue)) {
          forceInheritance = Boolean.valueOf(forceInheritanceValue);
        }
        ImageTranscodingDefinition td = new ImageTranscodingDefinition(trConfig, forceInheritance.boolValue());

        NodeList matcherNodes = XPathUtil.getNodeSet(imageNode, TAG_TRANSCODING_MATCHES);
        for (int j = 0; j < matcherNodes.getLength(); j++) {
          Node matcherNode = matcherNodes.item(j);

          ImageContainer container = ImageContainer.getByName(XPathUtil.getNodeValue(matcherNode, "@container"));
          if (container is null) {
            throw new ProfilesDefinitionException(String.format("Profile %s has unsupported matcher image container in transcoding definition", cast(Object[])[ profileId ]));
          }
          String subsamplingValue = XPathUtil.getNodeValue(matcherNode, "@subsampling");
          SamplingMode samplingMode = null;
          if (ObjectValidator.isNotEmpty(subsamplingValue)) {
            samplingMode = SamplingMode.valueOf(subsamplingValue);
          }
          td.getMatches().add(new ImageTranscodingMatch(container, samplingMode));
        }
        trConfig.addDefinition(MediaFileType.IMAGE, td);
      }
    }
    addInheritedTranscodingConfigs(MediaFileType.IMAGE, trConfig, parentTrConfig);
  }

  private static void addInheritedTranscodingConfigs(MediaFileType type, TranscodingConfiguration trConfig, TranscodingConfiguration parentTrConfig)
  {
    if (parentTrConfig !is null)
      foreach (TranscodingDefinition td ; parentTrConfig.getDefinitions(type))
        if (td.isForceInheritance())
          trConfig.addDefinition(type, td);
  }

  private static bool transcodingConfigIncludesForcedItems(TranscodingConfiguration trConfig)
  {
    if (trConfig !is null) {
      foreach (TranscodingDefinition def ; trConfig.getDefinitions()) {
        if (def.isForceInheritance()) {
          return true;
        }
      }
    }
    return false;
  }

  private static Map!(MediaFormatProfile, ProtocolInfo) getProtocolInfoMap(String profileId, Node profileNode, String protocolInfoType, Profile parentProfile)
  {
    Map!(MediaFormatProfile, ProtocolInfo) protocolInfos = new LinkedHashMap!(MediaFormatProfile, ProtocolInfo)();
    if ((parentProfile !is null) && (ObjectValidator.isEmpty(protocolInfoType)))
    {
      protocolInfoType = parentProfile.getProtocolInfoType();
    }
    if (ObjectValidator.isNotEmpty(protocolInfoType)) {
      Node formatsNode = XPathUtil.getNode(profileNode, TAG_MEDIA_PROFILES);
      if (formatsNode !is null) {
        NodeList formatNodes = XPathUtil.getNodeSet(formatsNode, TAG_MEDIA_PROFILE);
        for (int i = 0; i < formatNodes.getLength(); i++) {
          Node formatNode = formatNodes.item(i);
          String mimeType = XPathUtil.getNodeValue(formatNode, "@mime-type");
          String formatName = XPathUtil.getNodeValue(formatNode, ".");
          if (ObjectValidator.isEmpty(mimeType)) {
            throw new ProfilesDefinitionException(String.format("Profile %s has invalid (missing mime-type) media format profile", cast(Object[])[ profileId ]));
          }
          if (ObjectValidator.isEmpty(formatName))
            throw new ProfilesDefinitionException(String.format("Profile %s has invalid (missing value) media format profile", cast(Object[])[ profileId ]));
          try
          {
            MediaFormatProfile formatProfile = MediaFormatProfile.valueOf(formatName);
            String profileFormatNames = XPathUtil.getNodeValue(formatNode, "@name");
            List/*!(? : ProtocolAdditionalInfo)*/ protocolAdditionalInfos = createProtocolInfos(profileId, protocolInfoType, formatProfile, profileFormatNames);

            protocolInfos.put(formatProfile, new ProtocolInfo(mimeType, protocolAdditionalInfos));
          }
          catch (IllegalArgumentException e) {
            throw new ProfilesDefinitionException(String.format("Profile %s has invalid media format profile %s", cast(Object[])[ profileId, formatName ]));
          }
        }

      }

      if (parentProfile !is null) {
        foreach (Entry!(MediaFormatProfile, ProtocolInfo) parentPI ; parentProfile.getProtocolInfo().entrySet()) {
          if (!protocolInfos.containsKey(parentPI.getKey()))
          {
            if (parentProfile.getProtocolInfoType().equals(protocolInfoType))
            {
              protocolInfos.put(parentPI.getKey(), parentPI.getValue());
            }
            else {
              List/*!(? : ProtocolAdditionalInfo)*/ protocolAdditionalInfos = createProtocolInfos(profileId, protocolInfoType, cast(MediaFormatProfile)parentPI.getKey(), null);

              protocolInfos.put(parentPI.getKey(), new ProtocolInfo((cast(ProtocolInfo)parentPI.getValue()).getMimeType(), protocolAdditionalInfos));
            }
          }
        }
      }
    }
    return protocolInfos;
  }

  private static List/*!(? : ProtocolAdditionalInfo)*/ createProtocolInfos(String profileId, String protocolInfoType, MediaFormatProfile formatProfile, String profileFormatNames)
  {
    if (protocolInfoType.equals(PROTOCOL_INFO_SIMPLE))
      return Collections.singletonList(new SimpleProtocolInfo());
    if (protocolInfoType.equals(PROTOCOL_INFO_DLNA)) {
      if (ObjectValidator.isEmpty(profileFormatNames))
      {
        String profileFormatName = profileFormatNames !is null ? null : formatProfile.toString();

        return Collections.singletonList(new DLNAProtocolAdditionalInfo(profileFormatName));
      }

      List!(DLNAProtocolAdditionalInfo) protocolAdditionalInfos = new ArrayList!(DLNAProtocolAdditionalInfo)();
      String[] names = profileFormatNames.split(",");
      foreach (String name ; names) {
        protocolAdditionalInfos.add(new DLNAProtocolAdditionalInfo(name.trim()));
      }
      return protocolAdditionalInfos;
    }

    throw new ProfilesDefinitionException(String.format("Profile %s has invalid (%s) type of ProtocolInfo", cast(Object[])[ profileId ]));
  }

  private static Profile getProfileById(List!(Profile) profiles, String profileId)
  {
    foreach (Profile profile ; profiles) {
      if (profile.getId().equals(profileId)) {
        return profile;
      }
    }
    return null;
  }

  private static List!(DeliveryQuality) getAlternativeDeliveryQualities(String profileId, Node profileNode, H264LevelCheckType h264LevelCheck)
  {
    Node qualitiesNode = XPathUtil.getNode(profileNode, TAG_ALTERNATIVE_QUALITIES);
    List!(DeliveryQuality) qualities = new ArrayList!(DeliveryQuality)();
    if (qualitiesNode !is null) {
      NodeList qualityNodes = XPathUtil.getNodeSet(qualitiesNode, TAG_QUALITY);
      foreach (Node qualityNode ; XPathUtil.getListOfNodes(qualityNodes)) {
        TranscodingConfiguration onlineTranscodeConfig = getTranscodingConfiguration(profileId, XPathUtil.getNode(qualityNode, TAG_ONLINE_TRANSCODING), null, h264LevelCheck, false);
        TranscodingConfiguration transcodeConfig = getTranscodingConfiguration(profileId, XPathUtil.getNode(qualityNode, TAG_TRANSCODING), null, h264LevelCheck, false);
        DeliveryQuality.QualityType type = DeliveryQuality.QualityType.valueOf(XPathUtil.getNodeValue(qualityNode, "@type"));
        qualities.add(new DeliveryQuality(type, transcodeConfig, onlineTranscodeConfig));
      }
    }

    return qualities;
  }

  private static bool validateProfile(Profile profile)
  {
    if (ObjectValidator.isEmpty(profile.getId())) {
      log.error("Profile validation failed: id missing");
      return false;
    }
    if (profile.getContentDirectoryMessageBuilder() is null) {
      log.error("Profile validation failed: ContentDirectoryMessageBuilder missing");
      return false;
    }
    if ((profile.getDeviceDescription() is null) || (ObjectValidator.isEmpty(profile.getDeviceDescription().getFriendlyName())) || (ObjectValidator.isEmpty(profile.getDeviceDescription().getModelName())))
    {
      log.error("Profile validation failed: DeviceDescription missing");
      return false;
    }
    if (ObjectValidator.isEmpty(profile.getName())) {
      log.error("Profile validation failed: name missing");
      return false;
    }
    if (ObjectValidator.isEmpty(profile.getProtocolInfoType())) {
      log.error("Profile validation failed: ProtocolInfo missing");
      return false;
    }
    return true;
  }

  private static void validateXML(String profilesXML)
  {
    URL schemaURL = ProfilesDefinitionParser.class_.getResource(PROFILES_XSD);
    bool valid = XmlUtils.validateXML(PROFILES_XSD, schemaURL, profilesXML);
    if (!valid)
      throw new ProfilesDefinitionException("Profiles XML file is not valid (according to the schema). Check the log.");
  }

  static this()
  {
    try
    {
      COMP_NAME = InetAddress.getLocalHost().getHostName();
    } catch (UnknownHostException e) {
      log.warn(String.format("Cannot get name of the local computer: %s", cast(Object[])[ e.getMessage() ]));
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.profile.ProfilesDefinitionParser
 * JD-Core Version:    0.6.2
 */