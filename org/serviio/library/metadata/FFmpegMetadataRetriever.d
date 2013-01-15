module org.serviio.library.metadata.FFmpegMetadataRetriever;

import java.io.IOException;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map : Entry;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.serviio.delivery.DeliveryContext;
import org.serviio.dlna.AudioCodec;
import org.serviio.dlna.AudioContainer;
import org.serviio.dlna.VideoCodec;
import org.serviio.dlna.VideoContainer;
import org.serviio.external.FFMPEGWrapper;
import org.serviio.library.local.H264LevelType;
import org.serviio.library.local.metadata.AudioMetadata;
import org.serviio.library.local.metadata.VideoMetadata;
import org.serviio.library.local.metadata.extractor.InvalidMediaFormatException;
import org.serviio.library.local.metadata.extractor.embedded.AVCHeader;
import org.serviio.util.DateUtils;
import org.serviio.util.MediaUtils;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class FFmpegMetadataRetriever
{
  private static final Logger log = LoggerFactory.getLogger!(FFmpegMetadataRetriever)();

  private static final Pattern streamIndexPattern = Pattern.compile("#[\\d][\\.:]([\\d]{1,2})");
  private static final String CONTAINER = "container";
  private static final String DURATION = "duration";
  private static final String BITRATE = "bitrate";
  private static final String VIDEO_CODEC = "video_codec";
  private static final String VIDEO_FOURCC = "video_fourcc";
  private static final String VIDEO_STREAM_INDEX = "video_stream_index";
  private static final String WIDTH = "width";
  private static final String HEIGHT = "height";
  private static final String VIDEO_BITRATE = "video_bitrate";
  private static final String FPS = "fps";
  private static final String AUDIO_CODEC = "audio_codec";
  private static final String AUDIO_STREAM_INDEX = "audio_stream_index";
  private static final String CHANNELS = "channels";
  private static final String FREQUENCY = "frequency";
  private static final String AUDIO_BITRATE = "audio_bitrate";
  private static final String FTYP = "ftyp";
  private static final String SAR = "sar";
  private static final Map!(String, Integer) maxDpbMbs = new LinkedHashMap!(String, Integer)();

  public static void retrieveMetadata(VideoMetadata metadata, String filePath, DeliveryContext context)
  {
    List!(String) mediaDescription = FFMPEGWrapper.readMediaFileInformation(filePath, context);
    updateMetadata(metadata, mediaDescription, filePath);

    validateMandatoryMetadata(metadata);

    getProfileForH264(metadata, filePath, context);
  }

  public static void retrieveAudioMetadata(AudioMetadata metadata, String filePath, DeliveryContext context)
  {
    List!(String) mediaDescription = FFMPEGWrapper.readMediaFileInformation(filePath, context);
    updateMetadata(metadata, mediaDescription);

    validateCodecsFound(metadata);
  }

  public static void retrieveOnlineMetadata(ItemMetadata md, String contentUrl, DeliveryContext context)
  {
    if (( cast(VideoMetadata)md !is null ))
      retrieveMetadata(cast(VideoMetadata)md, contentUrl, context);
    else
      retrieveAudioMetadata(cast(AudioMetadata)md, contentUrl, context);
  }

  private static Map!(String, Object) getParametersMap(List!(String) ffmpegMediaDescription)
  {
    Map!(String, Object) parameters = new HashMap!(String, Object)();

    String container = null;

    foreach (String line ; ffmpegMediaDescription) {
      line = line.trim();
      int inputPos = line.indexOf("Input #0");
      if (inputPos > -1) {
        container = line.substring(inputPos + 10, line.indexOf(",", inputPos + 11)).trim();
      }
      if (container !is null)
      {
        parameters.put(CONTAINER, container);

        if (line.indexOf("major_brand") > -1) {
          String[] tokens = line.split(":");
          parameters.put(FTYP, tokens[1].trim());
        } else if (line.indexOf("Duration") > -1) {
          String[] tokens = line.split(",");
          foreach (String token ; tokens) {
            token = token.trim();
            if (token.startsWith("Duration: ")) {
              String duration = token.substring(10);
              if (duration.indexOf("N/A") == -1)
                parameters.put(DURATION, DateUtils.timeToSeconds(duration));
            }
            else if (token.startsWith("bitrate: ")) {
              String bitrateStr = token.substring(9);
              int spacepos = bitrateStr.indexOf(" ");
              if (spacepos > -1) {
                String value = bitrateStr.substring(0, spacepos);
                String unit = bitrateStr.substring(spacepos + 1);
                Integer bitrate = Integer.valueOf(Integer.parseInt(value));
                if (unit.equals("mb/s")) {
                  bitrate = Integer.valueOf(1024 * bitrate.intValue());
                }
                parameters.put(BITRATE, bitrate);
              }
            }
          }
        } else if ((line.indexOf("Video:") > -1) && (parameters.get(VIDEO_CODEC) is null)) {
          String[] tokens = line.split(",");
          foreach (String token ; tokens) {
            token = token.trim();
            if (token.startsWith("Stream")) {
              parameters.put(VIDEO_CODEC, getVideoCodec(token));
              parameters.put(VIDEO_STREAM_INDEX, getStreamIndex(token));
              parameters.put(VIDEO_FOURCC, getVideoFourCC(token));
            } else if (token.indexOf("x") > -1) {
              String resolution = token.trim();
              int aspectStart = resolution.indexOf(" [");
              if (aspectStart > -1)
              {
                String aspectDef = resolution.substring(aspectStart + 2, resolution.indexOf("]"));
                parameters.put(SAR, getSar(aspectDef));
                resolution = resolution.substring(0, aspectStart);
              }
              try {
                parameters.put(WIDTH, Integer.valueOf(Integer.parseInt(resolution.substring(0, resolution.indexOf("x")))));
                parameters.put(HEIGHT, Integer.valueOf(Integer.parseInt(resolution.substring(resolution.indexOf("x") + 1))));
              } catch (NumberFormatException nfe) {
              }
            } else if ((token.indexOf("SAR") > -1) || (token.indexOf("PAR") > -1))
            {
              parameters.put(SAR, getSar(token));
            } else if (token.indexOf("kb/s") > -1) {
              parameters.put(VIDEO_BITRATE, Integer.valueOf(Integer.parseInt(token.substring(0, token.indexOf("kb/s")).trim())));
            } else if (token.indexOf("mb/s") > -1) {
              parameters.put(VIDEO_BITRATE, Integer.valueOf(Integer.parseInt(token.substring(0, token.indexOf("mb/s")).trim()) * 1024));
            } else if ((token.indexOf("tbr") > -1) && (parameters.get(FPS) is null)) {
              String tbrValue = token.substring(0, token.indexOf("tbr")).trim();
              parameters.put(FPS, getFps(tbrValue));
            } else if ((token.indexOf(FPS) > -1) && (parameters.get(FPS) is null))
            {
              String fpsValue = token.substring(0, token.indexOf(FPS)).trim();
              parameters.put(FPS, getFps(fpsValue));
            }
          }
        } else if ((line.indexOf("Audio:") > -1) && (parameters.get(AUDIO_CODEC) is null)) {
          String[] tokens = line.split(",");
          foreach (String token ; tokens) {
            token = token.trim();
            if (token.startsWith("Stream")) {
              parameters.put(AUDIO_CODEC, getAudioCodec(token));
              parameters.put(AUDIO_STREAM_INDEX, getStreamIndex(token));
            } else if (token.indexOf(CHANNELS) > -1) {
              parameters.put(CHANNELS, Integer.valueOf(Integer.parseInt(token.substring(0, token.indexOf(CHANNELS)).trim())));
            } else if (token.indexOf("stereo") > -1) {
              parameters.put(CHANNELS, Integer.valueOf(2));
            } else if (token.indexOf("5.1") > -1) {
              parameters.put(CHANNELS, Integer.valueOf(6));
            } else if (token.indexOf("7.1") > -1) {
              parameters.put(CHANNELS, Integer.valueOf(8));
            } else if (token.indexOf("mono") > -1) {
              parameters.put(CHANNELS, Integer.valueOf(1));
            } else if (token.indexOf("Hz") > -1) {
              parameters.put(FREQUENCY, Integer.valueOf(Integer.parseInt(token.substring(0, token.indexOf("Hz")).trim())));
            } else if (token.indexOf("kb/s") > -1) {
              parameters.put(AUDIO_BITRATE, Integer.valueOf(Integer.parseInt(token.substring(0, token.indexOf("kb/s")).trim())));
            } else if (token.indexOf("mb/s") > -1) {
              parameters.put(AUDIO_BITRATE, Integer.valueOf(Integer.parseInt(token.substring(0, token.indexOf("mb/s")).trim()) * 1024));
            }
          }
        }
      }
    }
    return parameters;
  }

  protected static void updateMetadata(VideoMetadata metadata, List!(String) ffmpegMediaDescription, String filePath)
  {
    Map!(Object, Object) parameters = getParametersMap(ffmpegMediaDescription);
    metadata.setAudioBitrate(cast(Integer)parameters.get(AUDIO_BITRATE));
    metadata.setAudioCodec(AudioCodec.getByFFmpegDecoderName(cast(String)parameters.get(AUDIO_CODEC)));
    metadata.setAudioStreamIndex(cast(Integer)parameters.get(AUDIO_STREAM_INDEX));
    metadata.setBitrate(cast(Integer)parameters.get(BITRATE));
    metadata.setChannels(cast(Integer)parameters.get(CHANNELS));
    metadata.setContainer(VideoContainer.getByFFmpegValue(cast(String)parameters.get(CONTAINER), filePath));
    metadata.setDuration(cast(Integer)parameters.get(DURATION));
    metadata.setFps(cast(String)parameters.get(FPS));
    metadata.setFrequency(cast(Integer)parameters.get(FREQUENCY));
    metadata.setHeight(cast(Integer)parameters.get(HEIGHT));
    metadata.setVideoBitrate(cast(Integer)parameters.get(VIDEO_BITRATE));
    metadata.setVideoCodec(VideoCodec.getByFFmpegValue(cast(String)parameters.get(VIDEO_CODEC)));
    metadata.setVideoStreamIndex(cast(Integer)parameters.get(VIDEO_STREAM_INDEX));
    metadata.setVideoFourCC(cast(String)parameters.get(VIDEO_FOURCC));
    metadata.setWidth(cast(Integer)parameters.get(WIDTH));
    metadata.setFtyp(cast(String)parameters.get(FTYP));
    metadata.setSar(cast(String)parameters.get(SAR));
  }

  protected static void updateMetadata(AudioMetadata metadata, List!(String) ffmpegMediaDescription)
  {
    Map!(Object, Object) parameters = getParametersMap(ffmpegMediaDescription);
    metadata.setBitrate(cast(Integer)parameters.get(BITRATE));
    metadata.setChannels(cast(Integer)parameters.get(CHANNELS));
    metadata.setContainer(AudioContainer.getByName(cast(String)parameters.get(CONTAINER)));
    metadata.setDuration(cast(Integer)parameters.get(DURATION));
    metadata.setSampleFrequency(cast(Integer)parameters.get(FREQUENCY));
  }

  protected static String getFps(String fpsValue)
  {
    if (fpsValue.indexOf("k") > -1)
    {
      fpsValue = fpsValue.replaceFirst("k", "000");
    }
    return MediaUtils.getValidFps(fpsValue);
  }

  protected static String getSar(String aspectDef) {
    int sarIndex = aspectDef.indexOf("SAR");
    if (sarIndex < 0) {
      sarIndex = aspectDef.indexOf("PAR");
    }
    if (sarIndex > -1) {
      aspectDef = aspectDef.substring(sarIndex + 4);
      String sar = aspectDef.substring(0, aspectDef.indexOf(" "));
      return sar;
    }
    return null;
  }

  protected static String getVideoCodec(String token)
  {
    String codecValue = token.substring(token.indexOf("Video: ") + 7).split(" ")[0];
    if ((codecValue !is null) && (codecValue.startsWith("drm"))) {
      throw new InvalidMediaFormatException("File is DRM protected");
    }
    return codecValue;
  }

  protected static String getVideoFourCC(String token)
  {
    if (token.indexOf("(") > -1) {
      String fourCCBlock = token.substring(token.lastIndexOf("(") + 1, token.lastIndexOf(")"));
      if (fourCCBlock.indexOf("/") > -1) {
        String fourCC = StringUtils.localeSafeToLowercase(fourCCBlock.split("/")[0].trim());
        if (fourCC.indexOf("[") == -1) {
          return fourCC;
        }
      }
    }
    return null;
  }

  protected static String getAudioCodec(String token)
  {
    String codecValue = token.substring(token.indexOf("Audio: ") + 7).split(" ")[0];
    return codecValue;
  }

  protected static Integer getStreamIndex(String token)
  {
    Matcher m = streamIndexPattern.matcher(token);
    if (m.find()) {
      return Integer.valueOf(Integer.parseInt(m.group(1)));
    }
    return null;
  }

  protected static void validateMandatoryMetadata(VideoMetadata metadata)
  {
    if (metadata.getContainer() is null) {
      throw new InvalidMediaFormatException("Unknown video file type.");
    }
    if (metadata.getVideoCodec() is null) {
      throw new InvalidMediaFormatException("Unknown video codec.");
    }
    if (metadata.getWidth() is null) {
      throw new InvalidMediaFormatException("Unknown video width.");
    }
    if (metadata.getHeight() is null)
      throw new InvalidMediaFormatException("Unknown video height.");
  }

  protected static void validateCodecsFound(AudioMetadata metadata)
  {
    if (metadata.getContainer() is null)
      throw new InvalidMediaFormatException("Unknown audio file type.");
  }

  private static void getProfileForH264(VideoMetadata metadata, String filePath, DeliveryContext context)
  {
    if (metadata.getVideoCodec() == VideoCodec.H264)
      try {
        log.debug_(String.format("Retrieving H264 profile/level for file '%s'", cast(Object[])[ filePath ]));
        byte[] h264Stream = FFMPEGWrapper.readH264AnnexBHeader(filePath, metadata.getContainer(), context);
        AVCHeader avcHeader = parseH264Header(h264Stream);
        if (avcHeader !is null) {
          metadata.setH264Profile(avcHeader.getProfile());
          String refFramesLevel = getAndValidateH264LevelBasedOnRefFrames(avcHeader.getRefFrames(), metadata.getWidth(), metadata.getHeight());

          if (ObjectValidator.isNotEmpty(avcHeader.getLevel())) {
            metadata.getH264Levels().put(H264LevelType.H, avcHeader.getLevel());
          }
          if (ObjectValidator.isNotEmpty(refFramesLevel)) {
            metadata.getH264Levels().put(H264LevelType.RF, refFramesLevel);
          }
          log.debug_(String.format("File '%s' has H264 profile %s, levels [%s] and %s ref frames", cast(Object[])[ filePath, metadata.getH264Profile(), metadata.getH264Levels(), avcHeader.getRefFrames() ]));
        }
        else {
          log.warn(String.format("Couldn't resolve H264 profile/level/ref_frames for file '%s' because the header was not recognized", cast(Object[])[ filePath ]));
        }
      }
      catch (Exception e)
      {
        log.warn(String.format("Failed to retrieve H264 profile/level/ref_frames information for file '%s': %s", cast(Object[])[ filePath, e.getMessage() ]));
      }
  }

  protected static AVCHeader parseH264Header(byte[] h264Stream)
  {
    try
    {
      AVCHeader avcHeader = new AVCHeader(h264Stream);
      avcHeader.parse();
      return avcHeader;
    } catch (Throwable e) {
      log.debug_("AVC Header parse error: " + e.getMessage());
    }return null;
  }

  protected static String getAndValidateH264LevelBasedOnRefFrames(Integer refFrames, Integer width, Integer height)
  {
    if ((width !is null) && (height !is null) && (width.intValue() > 0) && (height.intValue() > 0) && (refFrames !is null) && (refFrames.intValue() > 0))
    {
      Integer dpbMbs = Integer.valueOf(width.intValue() * height.intValue() * refFrames.intValue() / 256);

      String level = null;
      foreach (Entry!(String, Integer) levelDbp ; maxDpbMbs.entrySet()) {
        level = cast(String)levelDbp.getKey();
        if ((cast(Integer)levelDbp.getValue()).intValue() > dpbMbs.intValue()) {
          return level;
        }
      }
      return level;
    }
    return null;
  }

  private static void prepareMaxDpbMbs()
  {
    maxDpbMbs.put("1", Integer.valueOf(396));
    maxDpbMbs.put("1.1", Integer.valueOf(396));
    maxDpbMbs.put("1.2", Integer.valueOf(900));
    maxDpbMbs.put("1.3", Integer.valueOf(2376));
    maxDpbMbs.put("2", Integer.valueOf(2376));
    maxDpbMbs.put("2.1", Integer.valueOf(4752));
    maxDpbMbs.put("2.2", Integer.valueOf(8100));
    maxDpbMbs.put("3", Integer.valueOf(8100));
    maxDpbMbs.put("3.1", Integer.valueOf(18000));
    maxDpbMbs.put("3.2", Integer.valueOf(20480));
    maxDpbMbs.put("4", Integer.valueOf(32768));
    maxDpbMbs.put("4.1", Integer.valueOf(32768));
    maxDpbMbs.put("4.2", Integer.valueOf(34816));
    maxDpbMbs.put("5", Integer.valueOf(110400));
    maxDpbMbs.put("5.1", Integer.valueOf(184320));
  }

  static this()
  {
    prepareMaxDpbMbs();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.metadata.FFmpegMetadataRetriever
 * JD-Core Version:    0.6.2
 */