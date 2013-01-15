module org.serviio.delivery.resource.transcode.VideoTranscodingMatch;

import java.lang.String;
import java.lang.Float;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import org.serviio.dlna.AudioCodec;
import org.serviio.dlna.H264Profile;
import org.serviio.dlna.VideoCodec;
import org.serviio.dlna.VideoContainer;
import org.serviio.library.local.H264LevelType;
import org.serviio.profile.H264LevelCheckType;
import org.serviio.profile.OnlineContentType;
import org.serviio.util.ObjectValidator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class VideoTranscodingMatch
{
  private static immutable Logger log = LoggerFactory.getLogger!(VideoTranscodingMatch)();
  private VideoContainer container;
  private VideoCodec videoCodec;
  private AudioCodec audioCodec;
  private H264Profile h264Profile;
  private Float h264LevelGT;
  private List!(String) ftypNotIn = new ArrayList!(String)();
  private OnlineContentType onlineContentType;
  private bool squarePixels;
  private List!(String) vFourCC = new ArrayList!(String)();
  private H264LevelCheckType h264LevelCheckType;

  public this(VideoContainer container, VideoCodec videoCodec, AudioCodec audioCodec, H264Profile h264Profile, Float h264LevelGT, String ftypNotIn, OnlineContentType onlineContentType, bool squarePixels, String vFourCC, H264LevelCheckType h264LevelCheckType)
  {
    this.container = container;
    this.videoCodec = videoCodec;
    this.audioCodec = audioCodec;
    this.h264Profile = h264Profile;
    this.h264LevelGT = h264LevelGT;
    if (ObjectValidator.isNotEmpty(ftypNotIn)) {
      this.ftypNotIn.addAll(Arrays.asList(ftypNotIn.split(",")));
    }
    this.onlineContentType = onlineContentType;
    this.squarePixels = squarePixels;
    if (ObjectValidator.isNotEmpty(vFourCC)) {
      this.vFourCC.addAll(Arrays.asList(vFourCC.split(",")));
    }
    this.h264LevelCheckType = h264LevelCheckType;
  }

  public bool matches(VideoContainer container, VideoCodec videoCodec, AudioCodec audioCodec, H264Profile h264Profile, Map!(H264LevelType, String) h264Levels, String ftyp, OnlineContentType onlineContentType, bool squarePixels, String vFourCC)
  {
    if (((container == this.container) || (this.container == VideoContainer.ANY)) && ((this.videoCodec is null) || (videoCodec == this.videoCodec)) && ((this.audioCodec is null) || (audioCodec == this.audioCodec)) && (checkFtyp(ftyp)) && (checkVFourCC(vFourCC)) && (checkH264Profile(videoCodec, h264Profile, h264Levels)) && ((this.onlineContentType == OnlineContentType.ANY) || (this.onlineContentType == onlineContentType)) && ((this.squarePixels is null) || (this.squarePixels.equals(bool.valueOf(squarePixels)))))
    {
      return true;
    }
    return false;
  }

  private bool checkFtyp(String ftyp)
  {
    if ((ftypNotIn.isEmpty()) || ((ftyp !is null) && (!ftypNotIn.contains(ftyp)))) {
      return true;
    }
    return false;
  }

  private bool checkVFourCC(String vFourCC) {
    if ((this.vFourCC.isEmpty()) || ((vFourCC !is null) && (this.vFourCC.contains(vFourCC)))) {
      return true;
    }
    return false;
  }

  private bool checkH264Profile(VideoCodec videoCodec, H264Profile videoH264Profile, Map!(H264LevelType, String) videoH264Levels) {
    if (videoCodec == VideoCodec.H264) {
      if (h264Profile is null)
      {
        return true;
      }
      if (h264LevelGT is null)
      {
        return (videoH264Profile !is null) && (h264Profile == videoH264Profile);
      }

      String videoH264Level = getLevelToMatch(videoH264Levels);
      try {
        return (videoH264Profile !is null) && (videoH264Level !is null) && (h264Profile == videoH264Profile) && ((new Float(videoH264Level)).floatValue() > h264LevelGT.floatValue());
      }
      catch (NumberFormatException e) {
        log.warn(String.format("H264 level of the file is not a valid number: %s", cast(Object[])[ videoH264Level ]));
        return false;
      }

    }

    return true;
  }

  private String getLevelToMatch(Map!(H264LevelType, String) videoH264Levels) {
    if (h264LevelCheckType == H264LevelCheckType.FILE_ATTRIBUTES)
      return cast(String)videoH264Levels.get(H264LevelType.RF);
    if (h264LevelCheckType == H264LevelCheckType.HEADER) {
      return cast(String)videoH264Levels.get(H264LevelType.H);
    }

    return selectHigherH264Level(cast(String)videoH264Levels.get(H264LevelType.H), cast(String)videoH264Levels.get(H264LevelType.RF));
  }

  private String selectHigherH264Level(String headerLevel, String refFramesLevel)
  {
    if (ObjectValidator.isEmpty(headerLevel)) {
      return refFramesLevel;
    }
    if (ObjectValidator.isEmpty(refFramesLevel)) {
      return headerLevel;
    }
    Float headerLevelFloat = new Float(headerLevel);
    Float refFramesLevelFloat = new Float(refFramesLevel);
    if (headerLevelFloat.floatValue() > refFramesLevelFloat.floatValue()) {
      return headerLevel;
    }
    return refFramesLevel;
  }

  public VideoContainer getContainer()
  {
    return container;
  }

  public VideoCodec getVideoCodec() {
    return videoCodec;
  }

  public AudioCodec getAudioCodec() {
    return audioCodec;
  }

  public H264Profile getH264Profile() {
    return h264Profile;
  }

  public Float getH264LevelGT() {
    return h264LevelGT;
  }

  public List!(String) getFtypNotIn() {
    return Collections.unmodifiableList(ftypNotIn);
  }

  public OnlineContentType getOnlineContentType() {
    return onlineContentType;
  }

  public bool getSquarePixels() {
    return squarePixels;
  }

  public H264LevelCheckType getH264LevelCheckType() {
    return h264LevelCheckType;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.resource.transcode.VideoTranscodingMatch
 * JD-Core Version:    0.6.2
 */