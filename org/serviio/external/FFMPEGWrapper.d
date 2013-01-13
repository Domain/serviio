module org.serviio.external.FFMPEGWrapper;

import java.lang.String;
import java.lang.Integer;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.serviio.ApplicationSettings;
import org.serviio.config.Configuration;
import org.serviio.delivery.DeliveryContext;
import org.serviio.delivery.resource.transcode.AudioTranscodingDefinition;
import org.serviio.delivery.resource.transcode.TranscodingDefinition;
import org.serviio.delivery.resource.transcode.TranscodingJobListener;
import org.serviio.delivery.resource.transcode.VideoTranscodingDefinition;
import org.serviio.dlna.AudioCodec;
import org.serviio.dlna.AudioContainer;
import org.serviio.dlna.DisplayAspectRatio;
import org.serviio.dlna.VideoCodec;
import org.serviio.dlna.VideoContainer;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.entities.MusicTrack;
import org.serviio.library.entities.Video;
import org.serviio.library.local.service.MediaService;
import org.serviio.util.CollectionUtils;
import org.serviio.util.MediaUtils;
import org.serviio.util.ObjectValidator;
import org.serviio.util.ThreadUtils;
import org.serviio.util.Tupple;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.serviio.external.AbstractExecutableWrapper;

public class FFMPEGWrapper : AbstractExecutableWrapper
{
  public static const String THREADS_AUTO = "auto";
  private static immutable Integer thumbnailSeekPosition = ApplicationSettings.getIntegerProperty("video_thumbnail_seek_position");

  private static immutable Integer defaultAudioBitrate = ApplicationSettings.getIntegerProperty("transcoding_default_audio_bitrate");

  private static immutable String videoQualityFactor = ApplicationSettings.getStringProperty("transcoding_quality_factor");

  private static immutable Logger log = LoggerFactory.getLogger!(FFMPEGWrapper);
  private static const int DEFAULT_AUDIO_FREQUENCY = 48000;
  private static const int MIN_AUDIO_FREQUENCY = 44100;
  private static const int RTMP_BUFFER_SIZE = 100000000;
  private static const long LOCAL_FILE_TIMEOUT = 30000L;//(new Long(30000L)).longValue();

  private static const long ONLINE_FILE_TIMEOUT = 60000L;//(new Long(60000L)).longValue();

  private static final List!(Integer) validAudioBitrates = Arrays.asList(cast(Integer[])[ Integer.valueOf(32), Integer.valueOf(48), Integer.valueOf(56), Integer.valueOf(64), Integer.valueOf(80), Integer.valueOf(96), Integer.valueOf(112), Integer.valueOf(128), Integer.valueOf(160), Integer.valueOf(192), Integer.valueOf(224), Integer.valueOf(256), Integer.valueOf(320), Integer.valueOf(384), Integer.valueOf(448), Integer.valueOf(512), Integer.valueOf(576), Integer.valueOf(640) ]);
  private static String ffmpegUserAgent;
  private static Map!(AudioCodec, Integer) maxChannelNumber;

  public static bool ffmpegPresent()
  {
    FFmpegCLBuilder builder = new FFmpegCLBuilder();

    log.debug_(String.format("Invoking FFMPEG to check if it exists of path %s", cast(Object[])[ FFmpegCLBuilder.executablePath ]));
    ProcessExecutor executor = new ProcessExecutor(builder.build(), false);
    executeSynchronously(executor);
    bool success = (executor.isSuccess()) && (executor.getResults().size() > 5);
    if (success) {
      String ffmpegOutput = CollectionUtils.listToCSV(executor.getResults(), "", false);
      if (ffmpegOutput.indexOf("--enable-librtmp") == -1) {
        log.warn("FFmpeg is not compiled with librtmp support, RTMP streaming will not work.");
      }
      ffmpegUserAgent = getUserAgent(ffmpegOutput);
    }
    return success;
  }

  public static List!(String) readMediaFileInformation(String filePath, DeliveryContext context)
  {
    FFmpegCLBuilder builder = new FFmpegCLBuilder();

    addInputFileOptions(filePath, context, builder);
    builder.inFile(fixFilePath(filePath, context.isLocalContent()));

    log.debug_(String.format("Invoking FFMPEG to retrieve media information for file: %s", cast(Object[])[ filePath ]));
    ProcessExecutor executor = new ProcessExecutor(builder.build(), false, Long.valueOf(context.isLocalContent() ? LOCAL_FILE_TIMEOUT : ONLINE_FILE_TIMEOUT));
    executeSynchronously(executor);
    return executor.getResults();
  }

  public static byte[] readVideoThumbnail(File f, Integer videoLength, VideoCodec vCodec, VideoContainer vContainer)
  {
    FFmpegCLBuilder builder = new FFmpegCLBuilder();
    builder.inFile(String.format("%s", cast(Object[])[ f.getAbsolutePath() ]));

    addTimePosition(videoLength, (vCodec != VideoCodec.MPEG2) && (vContainer != VideoContainer.MPEG2TS), builder);
    builder.outFileOptions(cast(String[])[ "-an", "-frames:v", "1", "-f", "image2" ]).outFile("pipe:");

    log.debug_(String.format("Invoking FFMPEG to retrieve thumbnail for file: %s", cast(Object[])[ f.getAbsolutePath() ]));
    ProcessExecutor executor = new ProcessExecutor(builder.build(), false, new Long(160000L));
    executeSynchronously(executor);
    ByteArrayOutputStream out_ = cast(ByteArrayOutputStream)executor.getOutputStream();
    if (out_ !is null) {
      return out_.toByteArray();
    }
    return null;
  }

  public static byte[] readH264AnnexBHeader(String filePath, VideoContainer container, DeliveryContext context)
  {
    FFmpegCLBuilder builder = new FFmpegCLBuilder();

    addInputFileOptions(filePath, context, builder);
    builder.inFile(String.format("%s", cast(Object[])[ fixFilePath(filePath, context.isLocalContent()) ]));
    builder.outFileOptions(cast(String[])[ "-frames:v", "1", "-c:v", "copy", "-f", "h264" ]);
    if (container != VideoContainer.MPEG2TS) {
      builder.outFileOptions(cast(String[])[ "-bsf:v", "h264_mp4toannexb" ]);
    }
    builder.outFileOptions(cast(String[])[ "-an" ]);
    builder.outFile("pipe:");

    log.debug_(String.format("Invoking FFMPEG to retrieve H264 header for file: %s", cast(Object[])[ filePath ]));
    ProcessExecutor executor = new ProcessExecutor(builder.build(), false, Long.valueOf(context.isLocalContent() ? LOCAL_FILE_TIMEOUT : ONLINE_FILE_TIMEOUT));
    executeSynchronously(executor);
    ByteArrayOutputStream out_ = cast(ByteArrayOutputStream)executor.getOutputStream();
    if (out_ !is null) {
      return out_.toByteArray();
    }
    return null;
  }

  public static OutputStream transcodeFile(MediaItem mediaItem, DeliveryContext context, File tmpFile, TranscodingDefinition tDef, TranscodingJobListener listener, Double timeOffset, Double timeDuration)
  {
    if (( cast(Video)mediaItem !is null ))
      return transcodeVideoFile(cast(Video)mediaItem, context, tmpFile, cast(VideoTranscodingDefinition)tDef, listener, timeOffset, timeDuration);
    if (( cast(MusicTrack)mediaItem !is null )) {
      return transcodeAudioFile(cast(MusicTrack)mediaItem, context, tmpFile, cast(AudioTranscodingDefinition)tDef, listener, timeOffset, timeDuration);
    }
    return null;
  }

  public static String getFFmpegUserAgent() {
    return ffmpegUserAgent;
  }

  protected static String prepareOnlineContentUrl(String url)
  {
    if (url.startsWith("mms://"))
    {
      return url.replaceFirst("mms://", "mmsh://");
    }
    return url;
  }

  private static void addTimePosition(Integer videoLength, bool inputOption, FFmpegCLBuilder builder) {
    String thumbnailPosition = null;
    if ((videoLength !is null) && (videoLength.intValue() < thumbnailSeekPosition.intValue()))
      thumbnailPosition = Integer.toString(videoLength.intValue() / 2);
    else {
      thumbnailPosition = Integer.toString(thumbnailSeekPosition.intValue());
    }
    if (inputOption)
      builder.inFileOptions(cast(String[])[ "-ss", thumbnailPosition ]);
    else
      builder.outFileOptions(cast(String[])[ "-ss", thumbnailPosition ]);
  }

  private static OutputStream transcodeVideoFile(Video mediaItem, DeliveryContext context, File tmpFile, VideoTranscodingDefinition tDef, TranscodingJobListener listener, Double timeOffset, Double timeDuration)
  {
    String sourceFileName = getFilePathForTranscoding(mediaItem);
    FFmpegCLBuilder builder = buildBasicTranscodingParameters(tDef, sourceFileName, context);

    builder.inFileOptions(cast(String[])[ "-threads", Configuration.getTranscodingThreads() ]);

    addTimeConstraintParameters(timeOffset, timeDuration, builder);
    addVideoParameters(mediaItem, tDef, builder);
    addAudioParameters(mediaItem, tDef, builder);
    mapStreams(mediaItem, builder);

    builder.outFileOptions(cast(String[])[ "-sn" ]);
    builder.outFileOptions(cast(String[])[ "-f", tDef.getTargetContainer().getFFmpegValue() ]);
    builder.outFile(getOutputFile(tmpFile));

    log.debug_(String.format("Invoking FFmpeg to transcode video file: %s", cast(Object[])[ sourceFileName ]));
    return executeTranscodingProcess(tmpFile, listener, builder.build());
  }

  private static OutputStream transcodeAudioFile(MusicTrack mediaItem, DeliveryContext context, File tmpFile, AudioTranscodingDefinition tDef, TranscodingJobListener listener, Double timeOffset, Double timeDuration) {
    String sourceFileName = getFilePathForTranscoding(mediaItem);
    FFmpegCLBuilder builder = buildBasicTranscodingParameters(tDef, sourceFileName, context);

    addTimeConstraintParameters(timeOffset, timeDuration, builder);

    if (tDef.getTargetContainer() != AudioContainer.LPCM)
    {
      Integer itemBitrate = mediaItem.getBitrate() !is null ? mediaItem.getBitrate() : null;
      Integer audioBitrate = getAudioBitrate(itemBitrate, tDef);
      builder.outFileOptions(cast(String[])[ "-b:a", String.format("%sk", [ audioBitrate ]) ]);
    }

    Integer frequency = getAudioFrequency(tDef, mediaItem);
    if (frequency !is null) {
      builder.outFileOptions(cast(String[])[ "-ar", frequency.toString() ]);
    }

    addAudioChannelsNumber(mediaItem.getChannels(), null, true, false, builder);

    builder.outFileOptions(cast(String[])[ "-vn" ]);

    builder.outFileOptions(cast(String[])[ "-f", tDef.getTargetContainer().getFFmpegContainerEncoderName() ]).outFile(getOutputFile(tmpFile));

    log.debug_(String.format("Invoking FFmpeg to transcode audio file: %s", cast(Object[])[ sourceFileName ]));
    return executeTranscodingProcess(tmpFile, listener, builder.build());
  }

  private static OutputStream executeTranscodingProcess(File tmpFile, TranscodingJobListener listener, String[] ffmpegArgs)
  {
    ProcessExecutor executor = new ProcessExecutor(ffmpegArgs, true, null, tmpFile is null);
    executor.addListener(listener);
    executor.start();
    if (tmpFile is null)
    {
      int retries = 0;
      while ((executor.getOutputStream() is null) && (retries++ < 5)) {
        ThreadUtils.currentThreadSleep(500L);
      }
    }
    return executor.getOutputStream();
  }

  private static String getOutputFile(File outputFile) {
    if (outputFile is null) {
      return "pipe:";
    }
    return outputFile.getAbsolutePath();
  }

  private static FFmpegCLBuilder buildBasicTranscodingParameters(TranscodingDefinition tDef, String sourceFilePath, DeliveryContext context)
  {
    FFmpegCLBuilder builder = new FFmpegCLBuilder();
    addInputFileOptions(sourceFilePath, context, builder);
    builder.inFile(String.format("%s", cast(Object[])[ sourceFilePath ])).outFileOptions(cast(String[])[ "-y" ]);
    return builder;
  }

  private static void addInputFileOptions(String fileName, DeliveryContext context, FFmpegCLBuilder builder) {
    if ((!context.isLocalContent()) && (ObjectValidator.isNotEmpty(context.getUserAgent()))) {
      builder.inFileOptions(cast(String[])[ "-user-agent", context.getUserAgent() ]);
    }
    if ((!context.isLocalContent()) && (fileName.startsWith("rtsp://"))) {
      builder.globalOptions(cast(String[])[ "-rtsp_transport", "+tcp+udp" ]);
    }
    if (!context.isLocalContent())
    {
      builder.globalOptions(cast(String[])[ "-analyzeduration", "10000000" ]);
    }
  }

  private static void mapStreams(Video mediaItem, FFmpegCLBuilder builder)
  {
    if (mediaItem.getVideoStreamIndex() !is null) {
      builder.outFileOptions(cast(String[])[ "-map", String.format("0:%s", [ mediaItem.getVideoStreamIndex() ]) ]);
    }
    if ((mediaItem.getAudioCodec() !is null) && (mediaItem.getAudioStreamIndex() !is null))
      builder.outFileOptions(cast(String[])[ "-map", String.format("0:%s", [ mediaItem.getAudioStreamIndex() ]) ]);
  }

  private static void addTimeConstraintParameters(Double timeOffset, Double timeDuration, FFmpegCLBuilder builder)
  {
    if (timeOffset !is null) {
      builder.inFileOptions(cast(String[])[ "-ss", timeOffset.toString() ]);
    }
    if (timeDuration !is null)
      builder.outFileOptions(cast(String[])[ "-t", timeDuration.toString() ]);
  }

  private static void addVideoParameters(Video mediaItem, VideoTranscodingDefinition tDef, FFmpegCLBuilder builder)
  {
    bool vCodecCopy = false;
    builder.outFileOptions(cast(String[])[ "-copyts" ]);
    builder.outFileOptions(cast(String[])[ "-c:v" ]);
    if (!isVideoStreamChanged(mediaItem, tDef))
    {
      builder.outFileOptions(cast(String[])[ "copy" ]);
      vCodecCopy = true;
      builder.globalOptions(cast(String[])[ "-fflags", "+genpts" ]);
    }
    else {
      VideoCodec targetCodec = getTargetVideoCodec(mediaItem, tDef);
      builder.outFileOptions(cast(String[])[ targetCodec.getFFmpegEncoderName() ]);
      if (tDef.getMaxVideoBitrate() !is null)
      {
        builder.outFileOptions(cast(String[])[ "-b:v", tDef.getMaxVideoBitrate().toString() + "k", "-maxrate:v", tDef.getMaxVideoBitrate().toString() + "k", "-bufsize:v", tDef.getMaxVideoBitrate().toString() + "k" ]);
      }
      else if (Configuration.isTranscodingBestQuality())
        builder.outFileOptions(cast(String[])[ "-qscale:v", "1" ]);
      else {
        builder.outFileOptions(cast(String[])[ "-qscale:v", videoQualityFactor ]);
      }

      addVideoFilters(mediaItem, tDef.getMaxHeight(), tDef.getDar(), tDef.getTargetContainer(), builder);
      addFrameRate(mediaItem, builder);

      builder.outFileOptions(cast(String[])[ "-g", "15" ]);
    }

    if ((vCodecCopy) && (mediaItem.getVideoCodec() == VideoCodec.H264) && (mediaItem.getContainer() != VideoContainer.MPEG2TS) && ((tDef.getTargetContainer() == VideoContainer.MPEG2TS) || (tDef.getTargetContainer() == VideoContainer.M2TS)))
    {
      builder.outFileOptions(cast(String[])[ "-bsf:v", "h264_mp4toannexb" ]);
    }
    if (tDef.getTargetContainer() == VideoContainer.M2TS)
    {
      builder.outFileOptions(cast(String[])[ "-mpegts_m2ts_mode", "1" ]);
    }
  }

  public static VideoCodec getTargetVideoCodec(Video mediaItem, VideoTranscodingDefinition tDef) {
    return tDef.getTargetVideoCodec() !is null ? tDef.getTargetVideoCodec() : mediaItem.getVideoCodec();
  }

  private static bool isVideoStreamChanged(Video mediaItem, VideoTranscodingDefinition tDef)
  {
    bool codecCopy = (!tDef.isForceVTranscoding()) && ((tDef.getTargetVideoCodec() is null) || (tDef.getTargetVideoCodec().equals(mediaItem.getVideoCodec())));
    return (!codecCopy) || (tDef.getMaxVideoBitrate() !is null) || (isVideoResolutionChangeRequired(mediaItem.getWidth(), mediaItem.getHeight(), tDef.getMaxHeight(), tDef.getDar(), tDef.getTargetContainer(), mediaItem.hasSquarePixels()));
  }

  private static void addFrameRate(Video mediaItem, FFmpegCLBuilder builder)
  {
    String fr = mediaItem.getFps();
    if (fr !is null)
    {
      fr = findNearestValidFFmpegFrameRate(fr);
      builder.outFileOptions(cast(String[])[ "-r", fr.toString() ]);
    }
  }

  protected static void addVideoFilters(Video video, Integer maxHeight, DisplayAspectRatio dar, VideoContainer targetContainer, FFmpegCLBuilder builder) {
    List!(String) filters = new ArrayList!(String)();
    ResizeDefinition resizeDefinition = getTargetVideoDimensions(video, maxHeight, dar, targetContainer);
    if (resizeDefinition.changed()) {
      if (resizeDefinition.physicalDimensionsChanged())
      {
        filters.add(String.format("scale=%s:%s", cast(Object[])[ Integer.valueOf(resizeDefinition.contentWidth), Integer.valueOf(resizeDefinition.contentHeight) ]));
        if (resizeDefinition.sarChangedToSquarePixels) {
          filters.add("setsar=1");
        }
      }
      if (resizeDefinition.darChanged)
      {
        Integer posX = Integer.valueOf(Math.abs(resizeDefinition.width - resizeDefinition.contentWidth) / 2);
        Integer posY = Integer.valueOf(Math.abs(resizeDefinition.height - resizeDefinition.contentHeight) / 2);
        filters.add(String.format("pad=%s:%s:%s:%s:black", cast(Object[])[ Integer.valueOf(resizeDefinition.width), Integer.valueOf(resizeDefinition.height), posX, posY ]));
        filters.add("setdar=4:3");
      }
    }
    if (filters.size() > 0)
      builder.outFileOptions(cast(String[])[ "-vf", CollectionUtils.listToCSV(filters, ",", true) ]);
  }

  private static void addAudioParameters(Video mediaItem, VideoTranscodingDefinition tDef, FFmpegCLBuilder builder)
  {
    if (mediaItem.getAudioCodec() is null)
    {
      builder.outFileOptions(cast(String[])[ "-an" ]);
      return;
    }
    builder.outFileOptions(cast(String[])[ "-c:a" ]);
    if ((tDef.getTargetAudioCodec() is null) || ((tDef.getTargetAudioCodec().equals(mediaItem.getAudioCodec())) && ((tDef.getAudioSamplerate() is null) || (tDef.getAudioSamplerate().equals(mediaItem.getFrequency())))))
    {
      builder.outFileOptions(cast(String[])[ "copy" ]);
    }
    else {
      builder.outFileOptions(cast(String[])[ tDef.getTargetAudioCodec().getFFmpegEncoderName() ]);
      if (tDef.getTargetAudioCodec() == AudioCodec.AAC) {
        builder.outFileOptions(cast(String[])[ "-strict", "experimental" ]);
      }
      if (tDef.getTargetAudioCodec() != AudioCodec.LPCM)
      {
        Integer itemBitrate = mediaItem.getAudioBitrate() !is null ? mediaItem.getAudioBitrate() : null;
        Integer audioBitrate = getAudioBitrate(itemBitrate, tDef);
        builder.outFileOptions(cast(String[])[ "-b:a", String.format("%sk", [ audioBitrate ]) ]);
      }

      Integer frequency = getAudioFrequency(tDef, mediaItem);
      if (frequency !is null) {
        builder.outFileOptions(cast(String[])[ "-ar", frequency.toString() ]);
      }

      bool downmixingSupported = mediaItem.getAudioCodec() != AudioCodec.FLAC;
      addAudioChannelsNumber(mediaItem.getChannels(), tDef.getTargetAudioCodec(), downmixingSupported, tDef.isForceStereo(), builder);
    }
  }

  public static Integer getAudioBitrate(Integer itemBitrate, TranscodingDefinition tDef)
  {
    if ((itemBitrate !is null) && 
      (!validAudioBitrates.contains(itemBitrate)))
    {
      itemBitrate = findNearestValidBitrate(itemBitrate);
    }

    Integer minimalAudioBitrate = (itemBitrate !is null) && (itemBitrate.intValue() < defaultAudioBitrate.intValue()) ? itemBitrate : defaultAudioBitrate;

    Integer audioBitrate = tDef.getAudioBitrate() !is null ? tDef.getAudioBitrate() : minimalAudioBitrate;
    return audioBitrate;
  }

  private static Integer findNearestValidBitrate(Integer itemBitrate) {
    int nearest = -1;
    int bestDistanceFoundYet = 2147483647;

    for (Iterator!(Integer) i = validAudioBitrates.iterator(); i.hasNext(); ) { int validRate = (cast(Integer)i.next()).intValue();
      int d = Math.abs(itemBitrate.intValue() - validRate);
      if (d < bestDistanceFoundYet) {
        nearest = validRate;
        bestDistanceFoundYet = d;
      }
    }
    return Integer.valueOf(nearest);
  }

  private static Integer getAudioFrequency(VideoTranscodingDefinition tDef, Video mediaItem) {
    return getAudioFrequency(tDef, mediaItem.getFrequency(), (tDef.getTargetAudioCodec() == AudioCodec.LPCM) || (mediaItem.getAudioCodec() == AudioCodec.LPCM));
  }

  private static Integer getAudioFrequency(AudioTranscodingDefinition tDef, MusicTrack mediaItem) {
    return getAudioFrequency(tDef, mediaItem.getSampleFrequency(), (tDef.getTargetContainer() == AudioContainer.LPCM) || (mediaItem.getContainer() == AudioContainer.LPCM));
  }

  public static Integer getAudioFrequency(TranscodingDefinition tDef, Integer itemFrequency, bool isLPCM) {
    Integer frequency = Integer.valueOf(DEFAULT_AUDIO_FREQUENCY);
    bool frequencyRequired = false;
    if (itemFrequency !is null) {
      if (itemFrequency.intValue() >= MIN_AUDIO_FREQUENCY) {
        frequency = itemFrequency;
      }
      else {
        frequencyRequired = true;
      }
    }
    else {
      frequencyRequired = true;
    }

    if (tDef.getAudioSamplerate() is null) {
      if ((isLPCM) || (frequencyRequired))
      {
        return frequency;
      }

      return null;
    }

    return tDef.getAudioSamplerate();
  }

  private static void addAudioChannelsNumber(Integer channelNumber, AudioCodec targetCodec, bool downmixingSupported, bool alwaysForceStereo, FFmpegCLBuilder builder)
  {
    Integer channels = getAudioChannelNumber(channelNumber, targetCodec, downmixingSupported, alwaysForceStereo);
    if (channels !is null)
      builder.outFileOptions(cast(String[])[ "-ac", channels.toString() ]);
  }

  private static Integer getMaxNumberOfChannels(AudioCodec codec)
  {
    if (codec !is null) {
      return cast(Integer)maxChannelNumber.get(codec);
    }
    return null;
  }

  public static Integer getAudioChannelNumber(Integer channelNumber, AudioCodec targetCodec, bool downmixingSupported, bool alwaysForceStereo) {
    if (channelNumber is null)
    {
      if ((Configuration.isTranscodingDownmixToStereo()) || (alwaysForceStereo))
        return Integer.valueOf(2);
    }
    else {
      Integer maxChannels = getMaxNumberOfChannels(targetCodec);

      if ((channelNumber.intValue() > 2) && ((Configuration.isTranscodingDownmixToStereo()) || (alwaysForceStereo)) && (downmixingSupported)) {
        return Integer.valueOf(2);
      }
      if ((maxChannels !is null) && (maxChannels.intValue() < channelNumber.intValue())) {
        return maxChannels;
      }
      return channelNumber;
    }

    return null;
  }

  public static ResizeDefinition getTargetVideoDimensions(Video video, Integer maxHeight, DisplayAspectRatio dar, VideoContainer targetContainer) {
    if ((!isVideoHeightChanged(video.getHeight(), maxHeight)) && (!isVideoDARChanged(video.getWidth(), video.getHeight(), dar)) && (!isSARFixNeeded(targetContainer, video.hasSquarePixels())))
    {
      return new ResizeDefinition(video.getWidth().intValue(), video.getHeight().intValue());
    }

    Integer newWidth = video.getWidth();
    Integer newHeight = video.getHeight();
    Integer newContentWidth = video.getWidth();
    Integer newContentHeight = video.getHeight();
    bool sarChanged = false;
    bool darChanged = false;
    bool heightChanged = false;

    if (isSARFixNeeded(targetContainer, video.hasSquarePixels())) {
      Tupple!(Object, Object) dimensions = getResolutionForSquarePixels(video.getWidth(), video.getHeight(), video.getSar());
      newWidth = cast(Integer)dimensions.getValueA();
      newHeight = cast(Integer)dimensions.getValueB();
      newContentWidth = newWidth;
      newContentHeight = newHeight;
      sarChanged = true;
    }

    if (isVideoDARChanged(newWidth, newHeight, dar)) {
      float originalDar = newWidth.intValue() / newHeight.intValue();
      if (originalDar >= dar.getRatio())
        newHeight = Integer.valueOf(Math.round(newWidth.intValue() / dar.getRatio()));
      else {
        newWidth = Integer.valueOf(Math.round(newHeight.intValue() * dar.getRatio()));
      }
      darChanged = true;
    }
    if (isVideoHeightChanged(newHeight, maxHeight))
    {
      int origNewWidth = newWidth.intValue();
      int origNewHeight = newHeight.intValue();
      newWidth = Integer.valueOf(Math.round(newWidth.intValue() * (maxHeight.intValue() / newHeight.intValue())));
      newHeight = maxHeight;
      newContentWidth = Integer.valueOf(Math.round(newContentWidth.intValue() * (newWidth.intValue() / origNewWidth)));
      newContentHeight = Integer.valueOf(Math.round(newContentHeight.intValue() * (newHeight.intValue() / origNewHeight)));
      heightChanged = true;
    }
    return new ResizeDefinition(newWidth.intValue(), newHeight.intValue(), newContentWidth.intValue(), newContentHeight.intValue(), darChanged, sarChanged, heightChanged);
  }

  private static Tupple!(Integer, Integer) getResolutionForSquarePixels(Integer width, Integer height, String sar)
  {
    String[] sarRatio = sar.split(":");
    if (sarRatio.length == 2)
      try {
        Float sarFloat = Float.valueOf(Float.parseFloat(sarRatio[0]) / Float.parseFloat(sarRatio[1]));
        return new Tupple!(Integer, Integer)(Integer.valueOf(Math.round(width.intValue() * sarFloat.floatValue())), height);
      } catch (Exception e) {
      }
    log.debug_(String.format("File's SAR is not valid: %s", cast(Object[])[ sar ]));
    return new Tupple!(Integer, Integer)(width, height);
  }

  protected static bool isVideoResolutionChangeRequired(Integer width, Integer height, Integer maxHeight, DisplayAspectRatio dar, VideoContainer targetContainer, bool squarePixels)
  {
    return (isVideoHeightChanged(height, maxHeight)) || (isVideoDARChanged(width, height, dar)) || (isSARFixNeeded(targetContainer, squarePixels));
  }

  private static bool isVideoHeightChanged(Integer height, Integer maxHeight)
  {
    return (maxHeight !is null) && (height !is null) && (height.intValue() > maxHeight.intValue());
  }

  private static bool isSARFixNeeded(VideoContainer targetContainer, bool squarePixels)
  {
    return ((targetContainer == VideoContainer.ASF) || (targetContainer == VideoContainer.FLV)) && (!squarePixels);
  }

  private static bool isVideoDARChanged(Integer width, Integer height, DisplayAspectRatio dar)
  {
    return (dar !is null) && (width !is null) && (height !is null) && (!dar.isEqualTo(width.intValue(), height.intValue()));
  }

  protected static String findNearestValidFFmpegFrameRate(String frameRate)
  {
    float frFloat = Float.parseFloat(frameRate);
    float validFrameRate = (new Float(frFloat)).floatValue();
    while (validFrameRate < 23.0F) {
      validFrameRate += frFloat;
    }
    return MediaUtils.formatFpsForFFmpeg(Float.toString(validFrameRate));
  }

  private static String getFilePathForTranscoding(MediaItem mediaItem)
  {
    bool isLocalMedia = mediaItem.isLocalMedia();
    String sourceFileName = null;
    if (isLocalMedia)
      sourceFileName = MediaService.getFile(mediaItem.getId()).getPath();
    else {
      sourceFileName = mediaItem.getFileName();
    }
    sourceFileName = fixFilePath(sourceFileName, isLocalMedia);
    if (!isLocalMedia) {
      sourceFileName = buildOnlineContentUrl(sourceFileName, mediaItem.isLive());
    }
    return sourceFileName;
  }

  private static String fixFilePath(String filePath, bool isLocalContent) {
    if (!isLocalContent) {
      return prepareOnlineContentUrl(filePath);
    }
    return filePath;
  }

  private static String buildOnlineContentUrl(String url, bool live)
  {
    if ((url.startsWith("rtmp")) && (!live))
    {
      url = String.format("%s buffer=%s", cast(Object[])[ url, Integer.valueOf(RTMP_BUFFER_SIZE) ]);
    }
    return url;
  }

  protected static String getUserAgent(String ffmpegOutput) {
    Pattern p = Pattern.compile("libavformat(.*?)/", 2);
    Matcher m = p.matcher(ffmpegOutput);
    if (m.find()) {
      String version_ = m.group(1);
      version_ = version_.replaceAll(" ", "");
      return "Lavf" ~ version_;
    }
    log.warn("Could not work out FFmpeg default User-Agent");
    return null;
  }

  private static void setupMaxChannelsMap() {
    maxChannelNumber = new HashMap!(AudioCodec, Integer)();
    maxChannelNumber.put(AudioCodec.AC3, new Integer(6));
    maxChannelNumber.put(AudioCodec.MP2, new Integer(2));
    maxChannelNumber.put(AudioCodec.MP3, new Integer(2));
    maxChannelNumber.put(AudioCodec.WMA, new Integer(2));
    maxChannelNumber.put(AudioCodec.LPCM, new Integer(2));
  }

  static this()
  {
    setupMaxChannelsMap();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.external.FFMPEGWrapper
 * JD-Core Version:    0.6.2
 */