module org.serviio.dlna.MediaFormatProfileResolver;

import java.lang.String;
import java.lang.Integer;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import org.serviio.library.entities.Image;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.entities.MusicTrack;
import org.serviio.library.entities.Video;
import org.serviio.library.local.metadata.TransportStreamTimestamp;

public class MediaFormatProfileResolver
{
  public static List!(MediaFormatProfile) resolve(MediaItem mediaItem)
  {
    if (( cast(Image)mediaItem !is null )) {
      Image image = cast(Image)mediaItem;
      return Collections.singletonList(resolveImageFormat(mediaItem.getFileName(), image.getContainer(), image.getWidth(), image.getHeight()));
    }if (( cast(MusicTrack)mediaItem !is null )) {
      MusicTrack track = cast(MusicTrack)mediaItem;
      return Collections.singletonList(resolveAudioFormat(track.getFileName(), track.getContainer(), track.getBitrate(), track.getSampleFrequency(), track.getChannels()));
    }
    Video video = cast(Video)mediaItem;
    return resolveVideoFormat(video.getFileName(), video.getContainer(), video.getVideoCodec(), video.getAudioCodec(), video.getWidth(), video.getHeight(), video.getBitrate(), video.getTimestampType());
  }

  public static MediaFormatProfile resolveImageFormat(String fileName, ImageContainer container, Integer width, Integer height)
  {
    if (container == ImageContainer.JPEG)
      return resolveImageJPGFormat(fileName, width, height);
    if (container == ImageContainer.PNG)
      return resolveImagePNGFormat(fileName, width, height);
    if (container == ImageContainer.GIF)
      return resolveImageGIFFormat(fileName, width, height);
    if (container == ImageContainer.RAW) {
      return resolveImageRAWFormat(fileName, width, height);
    }
    throw new UnsupportedDLNAMediaFileFormatException(String.format("Image %s does not match any supported DLNA profile", cast(Object[])[ fileName ]));
  }

  public static MediaFormatProfile resolveAudioFormat(String fileName, AudioContainer container, Integer bitrate, Integer frequency, Integer channels)
  {
    if (container == AudioContainer.ASF)
      return resolveAudioASFFormat(fileName, bitrate, frequency, channels);
    if (container == AudioContainer.MP3)
      return MediaFormatProfile.MP3;
    if (container == AudioContainer.LPCM)
      return resolveAudioLPCMFormat(fileName, bitrate, frequency, channels);
    if (container == AudioContainer.MP4)
      return resolveAudioMP4Format(fileName, bitrate, frequency, channels);
    if (container == AudioContainer.ADTS)
      return resolveAudioADTSFormat(fileName, bitrate, frequency, channels);
    if (container == AudioContainer.FLAC)
      return resolveAudioFLACFormat(fileName, bitrate, frequency, channels);
    if (container == AudioContainer.OGG) {
      return resolveAudioOGGFormat(fileName, bitrate, frequency, channels);
    }
    throw new UnsupportedDLNAMediaFileFormatException(String.format("Music track %s does not match any supported DLNA profile", cast(Object[])[ fileName ]));
  }

  public static List!(MediaFormatProfile) resolveVideoFormat(String fileName, VideoContainer container, VideoCodec videoCodec, AudioCodec audioCodec, Integer width, Integer height, Integer bitrate, TransportStreamTimestamp timestampType)
  {
    if (container == VideoContainer.ASF)
      return resolveVideoASFFormat(fileName, videoCodec, audioCodec, width, height, bitrate);
    if (container == VideoContainer.MP4)
      return resolveVideoMP4Format(fileName, videoCodec, audioCodec, width, height, bitrate);
    if (container == VideoContainer.AVI)
      return resolveVideoAVIFormat(fileName, videoCodec, audioCodec, width, height, bitrate);
    if (container == VideoContainer.MATROSKA)
      return resolveVideoMatroskaFormat(fileName, videoCodec, audioCodec, width, height, bitrate);
    if (container == VideoContainer.MPEG2PS)
      return resolveVideoMPEG2PSFormat(fileName, videoCodec, audioCodec, width, height, bitrate);
    if (container == VideoContainer.MPEG1)
      return resolveVideoMPEG1Format(fileName, videoCodec, audioCodec, width, height, bitrate);
    if ((container == VideoContainer.MPEG2TS) || (container == VideoContainer.M2TS))
      return resolveVideoMPEG2TSFormat(fileName, videoCodec, audioCodec, width, height, bitrate, timestampType);
    if (container == VideoContainer.FLV)
      return resolveVideoFLVFormat(fileName, videoCodec, audioCodec, width, height, bitrate);
    if (container == VideoContainer.WTV)
      return resolveVideoWTVFormat(fileName, videoCodec, audioCodec, width, height, bitrate);
    if (container == VideoContainer.THREE_GP) {
      return resolveVideo3GPFormat(fileName, videoCodec, audioCodec, width, height, bitrate);
    }
    throw new UnsupportedDLNAMediaFileFormatException(String.format("Video %s does not match any supported DLNA profile", cast(Object[])[ fileName ]));
  }

  protected static MediaFormatProfile resolveAudioASFFormat(String fileName, Integer bitrate, Integer frequency, Integer channels)
  {
    if ((bitrate !is null) && (bitrate.intValue() < 193)) {
      return MediaFormatProfile.WMA_BASE;
    }
    return MediaFormatProfile.WMA_FULL;
  }

  protected static MediaFormatProfile resolveAudioLPCMFormat(String fileName, Integer bitrate, Integer frequency, Integer channels)
  {
    if ((frequency !is null) && (channels !is null)) {
      if ((frequency.intValue() == 44100) && (channels.intValue() == 1))
        return MediaFormatProfile.LPCM16_44_MONO;
      if ((frequency.intValue() == 44100) && (channels.intValue() == 2))
        return MediaFormatProfile.LPCM16_44_STEREO;
      if ((frequency.intValue() == 48000) && (channels.intValue() == 1))
        return MediaFormatProfile.LPCM16_48_MONO;
      if ((frequency.intValue() == 48000) && (channels.intValue() == 2)) {
        return MediaFormatProfile.LPCM16_48_STEREO;
      }
      throw new UnsupportedDLNAMediaFileFormatException(String.format("Unsupported LPCM format of file %s. Only 44100 / 48000 Hz and Mono / Stereo files are allowed.", cast(Object[])[ fileName ]));
    }

    return MediaFormatProfile.LPCM16_48_STEREO;
  }

  protected static MediaFormatProfile resolveAudioMP4Format(String fileName, Integer bitrate, Integer frequency, Integer channels)
  {
    if ((bitrate !is null) && (bitrate.intValue() <= 320)) {
      return MediaFormatProfile.AAC_ISO_320;
    }
    return MediaFormatProfile.AAC_ISO;
  }

  protected static MediaFormatProfile resolveAudioADTSFormat(String fileName, Integer bitrate, Integer frequency, Integer channels)
  {
    if ((bitrate !is null) && (bitrate.intValue() <= 320)) {
      return MediaFormatProfile.AAC_ADTS_320;
    }
    return MediaFormatProfile.AAC_ADTS;
  }

  protected static MediaFormatProfile resolveAudioFLACFormat(String fileName, Integer bitrate, Integer frequency, Integer channels)
  {
    return MediaFormatProfile.FLAC;
  }

  protected static MediaFormatProfile resolveAudioOGGFormat(String fileName, Integer bitrate, Integer frequency, Integer channels)
  {
    return MediaFormatProfile.OGG;
  }

  protected static MediaFormatProfile resolveImageJPGFormat(String fileName, Integer width, Integer height)
  {
    if ((width is null) || (height is null))
    {
      return MediaFormatProfile.JPEG_LRG;
    }
    if ((width.intValue() <= 640) && (height.intValue() <= 480))
      return MediaFormatProfile.JPEG_SM;
    if ((width.intValue() <= 1024) && (height.intValue() <= 768)) {
      return MediaFormatProfile.JPEG_MED;
    }

    return MediaFormatProfile.JPEG_LRG;
  }

  protected static MediaFormatProfile resolveImagePNGFormat(String fileName, Integer width, Integer height)
  {
    return MediaFormatProfile.PNG_LRG;
  }

  protected static MediaFormatProfile resolveImageGIFFormat(String fileName, Integer width, Integer height)
  {
    return MediaFormatProfile.GIF_LRG;
  }

  protected static MediaFormatProfile resolveImageRAWFormat(String fileName, Integer width, Integer height)
  {
    return MediaFormatProfile.RAW;
  }

  protected static List!(MediaFormatProfile) resolveVideoMPEG1Format(String fileName, VideoCodec videoCodec, AudioCodec audioCodec, Integer width, Integer height, Integer bitrate)
  {
    return Collections.singletonList(MediaFormatProfile.MPEG1);
  }

  protected static List!(MediaFormatProfile) resolveVideoMPEG2PSFormat(String fileName, VideoCodec videoCodec, AudioCodec audioCodec, Integer width, Integer height, Integer bitrate)
  {
    return Arrays.asList(cast(MediaFormatProfile[])[ MediaFormatProfile.MPEG_PS_PAL, MediaFormatProfile.MPEG_PS_NTSC ]);
  }

  protected static List!(MediaFormatProfile) resolveVideoMPEG2TSFormat(String fileName, VideoCodec videoCodec, AudioCodec audioCodec, Integer width, Integer height, Integer bitrate, TransportStreamTimestamp timestampType)
  {
    String suffix = "";
    if (isNoTimestamp(timestampType))
      suffix = "_ISO";
    else if (timestampType == TransportStreamTimestamp.VALID) {
      suffix = "_T";
    }

    String resolution = "S";
    if ((width.intValue() > 720) || (height.intValue() > 576)) {
      resolution = "H";
    }

    if (videoCodec == VideoCodec.MPEG2)
    {
      List!(MediaFormatProfile) profiles = Arrays.asList(cast(MediaFormatProfile[])[ MediaFormatProfile.valueOf("MPEG_TS_SD_EU" + suffix), MediaFormatProfile.valueOf("MPEG_TS_SD_NA" + suffix), MediaFormatProfile.valueOf("MPEG_TS_SD_KO" + suffix) ]);

      if ((timestampType == TransportStreamTimestamp.VALID) && (audioCodec == AudioCodec.AAC)) {
        profiles.add(MediaFormatProfile.MPEG_TS_JP_T);
      }
      return profiles;
    }if (videoCodec == VideoCodec.H264)
    {
      if (audioCodec == AudioCodec.LPCM)
        return Collections.singletonList(MediaFormatProfile.AVC_TS_HD_50_LPCM_T);
      if (audioCodec == AudioCodec.DTS) {
        if (isNoTimestamp(timestampType)) {
          return Collections.singletonList(MediaFormatProfile.AVC_TS_HD_DTS_ISO);
        }
        return Collections.singletonList(MediaFormatProfile.AVC_TS_HD_DTS_T);
      }
      if (audioCodec == AudioCodec.MP2) {
        if (isNoTimestamp(timestampType)) {
          return Collections.singletonList(MediaFormatProfile.valueOf(String.format("AVC_TS_HP_%sD_MPEG1_L2_ISO", cast(Object[])[ resolution ])));
        }
        return Collections.singletonList(MediaFormatProfile.valueOf(String.format("AVC_TS_HP_%sD_MPEG1_L2_T", cast(Object[])[ resolution ])));
      }

      if (audioCodec == AudioCodec.AAC)
        return Collections.singletonList(MediaFormatProfile.valueOf(String.format("AVC_TS_MP_%sD_AAC_MULT5%s", cast(Object[])[ resolution, suffix ])));
      if (audioCodec == AudioCodec.MP3)
        return Collections.singletonList(MediaFormatProfile.valueOf(String.format("AVC_TS_MP_%sD_MPEG1_L3%s", cast(Object[])[ resolution, suffix ])));
      if ((audioCodec is null) || (audioCodec == AudioCodec.AC3)) {
        return Collections.singletonList(MediaFormatProfile.valueOf(String.format("AVC_TS_MP_%sD_AC3%s", cast(Object[])[ resolution, suffix ])));
      }
    }
    else if (videoCodec == VideoCodec.VC1) {
      if ((audioCodec is null) || (audioCodec == AudioCodec.AC3))
      {
        if ((width.intValue() > 720) || (height.intValue() > 576)) {
          return Collections.singletonList(MediaFormatProfile.VC1_TS_AP_L2_AC3_ISO);
        }
        return Collections.singletonList(MediaFormatProfile.VC1_TS_AP_L1_AC3_ISO);
      }
      if (audioCodec == AudioCodec.DTS) {
        suffix = suffix.equals("_ISO") ? suffix : "_T";
        return Collections.singletonList(MediaFormatProfile.valueOf(String.format("VC1_TS_HD_DTS%s", cast(Object[])[ suffix ])));
      }
    } else if ((videoCodec == VideoCodec.MPEG4) || (videoCodec == VideoCodec.MSMPEG4)) {
      if (audioCodec == AudioCodec.AAC)
        return Collections.singletonList(MediaFormatProfile.valueOf(String.format("MPEG4_P2_TS_ASP_AAC%s", cast(Object[])[ suffix ])));
      if (audioCodec == AudioCodec.MP3)
        return Collections.singletonList(MediaFormatProfile.valueOf(String.format("MPEG4_P2_TS_ASP_MPEG1_L3%s", cast(Object[])[ suffix ])));
      if (audioCodec == AudioCodec.MP2)
        return Collections.singletonList(MediaFormatProfile.valueOf(String.format("MPEG4_P2_TS_ASP_MPEG2_L2%s", cast(Object[])[ suffix ])));
      if ((audioCodec is null) || (audioCodec == AudioCodec.AC3)) {
        return Collections.singletonList(MediaFormatProfile.valueOf(String.format("MPEG4_P2_TS_ASP_AC3%s", cast(Object[])[ suffix ])));
      }
    }

    throw new UnsupportedDLNAMediaFileFormatException(String.format("MPEG2TS video file %s does not match any supported DLNA profile", cast(Object[])[ fileName ]));
  }

  protected static List!(MediaFormatProfile) resolveVideoMP4Format(String fileName, VideoCodec videoCodec, AudioCodec audioCodec, Integer width, Integer height, Integer bitrate)
  {
    if (videoCodec == VideoCodec.H264)
    {
      if (audioCodec == AudioCodec.LPCM)
        return Collections.singletonList(MediaFormatProfile.AVC_MP4_LPCM);
      if ((audioCodec is null) || (audioCodec == AudioCodec.AC3))
      {
        return Collections.singletonList(MediaFormatProfile.AVC_MP4_MP_SD_AC3);
      }
      if (audioCodec == AudioCodec.MP3)
      {
        return Collections.singletonList(MediaFormatProfile.AVC_MP4_MP_SD_MPEG1_L3);
      }
      if ((width.intValue() <= 720) && (height.intValue() <= 576))
      {
        if (audioCodec == AudioCodec.AAC)
          return Collections.singletonList(MediaFormatProfile.AVC_MP4_MP_SD_AAC_MULT5);
      }
      else if ((width.intValue() <= 1280) && (height.intValue() <= 720))
      {
        if (audioCodec == AudioCodec.AAC)
          return Collections.singletonList(MediaFormatProfile.AVC_MP4_MP_HD_720p_AAC);
      }
      else if ((width.intValue() <= 1920) && (height.intValue() <= 1080))
      {
        if (audioCodec == AudioCodec.AAC) {
          return Collections.singletonList(MediaFormatProfile.AVC_MP4_MP_HD_1080i_AAC);
        }
      }

    }
    else if ((videoCodec == VideoCodec.MPEG4) || (videoCodec == VideoCodec.MSMPEG4))
    {
      if ((width.intValue() <= 720) && (height.intValue() <= 576)) {
        if ((audioCodec is null) || (audioCodec == AudioCodec.AAC))
          return Collections.singletonList(MediaFormatProfile.MPEG4_P2_MP4_ASP_AAC);
        if ((audioCodec == AudioCodec.AC3) || (audioCodec == AudioCodec.MP3)) {
          return Collections.singletonList(MediaFormatProfile.MPEG4_P2_MP4_NDSD);
        }
      }
      else if ((audioCodec is null) || (audioCodec == AudioCodec.AAC)) {
        return Collections.singletonList(MediaFormatProfile.MPEG4_P2_MP4_SP_L6_AAC);
      }
    }
    else if ((videoCodec == VideoCodec.H263) && (audioCodec == AudioCodec.AAC)) {
      return Collections.singletonList(MediaFormatProfile.MPEG4_H263_MP4_P0_L10_AAC);
    }

    throw new UnsupportedDLNAMediaFileFormatException(String.format("MP4 video file %s does not match any supported DLNA profile", cast(Object[])[ fileName ]));
  }

  protected static List!(MediaFormatProfile) resolveVideoMatroskaFormat(String fileName, VideoCodec videoCodec, AudioCodec audioCodec, Integer width, Integer height, Integer bitrate)
  {
    return Collections.singletonList(MediaFormatProfile.MATROSKA);
  }

  protected static List!(MediaFormatProfile) resolveVideoFLVFormat(String fileName, VideoCodec videoCodec, AudioCodec audioCodec, Integer width, Integer height, Integer bitrate)
  {
    return Collections.singletonList(MediaFormatProfile.FLV);
  }

  protected static List!(MediaFormatProfile) resolveVideoWTVFormat(String fileName, VideoCodec videoCodec, AudioCodec audioCodec, Integer width, Integer height, Integer bitrate)
  {
    return Collections.singletonList(MediaFormatProfile.WTV);
  }

  protected static List!(MediaFormatProfile) resolveVideo3GPFormat(String fileName, VideoCodec videoCodec, AudioCodec audioCodec, Integer width, Integer height, Integer bitrate)
  {
    if (videoCodec == VideoCodec.H264) {
      if ((audioCodec is null) || (audioCodec == AudioCodec.AAC))
        return Collections.singletonList(MediaFormatProfile.AVC_3GPP_BL_QCIF15_AAC);
    }
    else if ((videoCodec == VideoCodec.MPEG4) || (videoCodec == VideoCodec.MSMPEG4)) {
      if ((audioCodec is null) || (audioCodec == AudioCodec.AAC))
        return Collections.singletonList(MediaFormatProfile.MPEG4_P2_3GPP_SP_L0B_AAC);
      if (audioCodec == AudioCodec.AMR)
        return Collections.singletonList(MediaFormatProfile.MPEG4_P2_3GPP_SP_L0B_AMR);
    }
    else if ((videoCodec == VideoCodec.H263) && (audioCodec == AudioCodec.AMR)) {
      return Collections.singletonList(MediaFormatProfile.MPEG4_H263_3GPP_P0_L10_AMR);
    }

    throw new UnsupportedDLNAMediaFileFormatException(String.format("3GP video file %s does not match any supported DLNA profile", cast(Object[])[ fileName ]));
  }

  protected static List!(MediaFormatProfile) resolveVideoOGGFormat(String fileName, VideoCodec videoCodec, AudioCodec audioCodec, Integer width, Integer height, Integer bitrate)
  {
    return Collections.singletonList(MediaFormatProfile.OGV);
  }

  protected static List!(MediaFormatProfile) resolveVideoAVIFormat(String fileName, VideoCodec videoCodec, AudioCodec audioCodec, Integer width, Integer height, Integer bitrate)
  {
    return Collections.singletonList(MediaFormatProfile.AVI);
  }

  protected static List!(MediaFormatProfile) resolveVideoASFFormat(String fileName, VideoCodec videoCodec, AudioCodec audioCodec, Integer width, Integer height, Integer bitrate)
  {
    if ((videoCodec == VideoCodec.WMV) && ((audioCodec is null) || (audioCodec == AudioCodec.WMA) || (audioCodec == AudioCodec.WMA_PRO)))
    {
      if ((width.intValue() <= 720) && (height.intValue() <= 576))
      {
        if ((audioCodec is null) || (audioCodec == AudioCodec.WMA)) {
          return Collections.singletonList(MediaFormatProfile.WMVMED_FULL);
        }
        return Collections.singletonList(MediaFormatProfile.WMVMED_PRO);
      }

      if ((audioCodec is null) || (audioCodec == AudioCodec.WMA)) {
        return Collections.singletonList(MediaFormatProfile.WMVHIGH_FULL);
      }
      return Collections.singletonList(MediaFormatProfile.WMVHIGH_PRO);
    }

    if (videoCodec == VideoCodec.VC1)
    {
      if ((width.intValue() <= 720) && (height.intValue() <= 576))
        return Collections.singletonList(MediaFormatProfile.VC1_ASF_AP_L1_WMA);
      if ((width.intValue() <= 1280) && (height.intValue() <= 720))
        return Collections.singletonList(MediaFormatProfile.VC1_ASF_AP_L2_WMA);
      if ((width.intValue() <= 1920) && (height.intValue() <= 1080))
        return Collections.singletonList(MediaFormatProfile.VC1_ASF_AP_L3_WMA);
    }
    else if (videoCodec == VideoCodec.MPEG2)
    {
      return Collections.singletonList(MediaFormatProfile.DVR_MS);
    }

    throw new UnsupportedDLNAMediaFileFormatException(String.format("ASF video file %s does not match any supported DLNA profile", cast(Object[])[ fileName ]));
  }

  private static bool isNoTimestamp(TransportStreamTimestamp timestampType)
  {
    return (timestampType is null) || (timestampType == TransportStreamTimestamp.NONE);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.dlna.MediaFormatProfileResolver
 * JD-Core Version:    0.6.2
 */