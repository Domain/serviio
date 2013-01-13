module org.serviio.dlna.VideoContainer;

import java.lang.String;
import org.serviio.util.StringUtils;

public class VideoContainer
{
	enum VideoContainerEnum
	{
		ANY, 
		AVI, 
		MATROSKA, 
		ASF, 
		MP4, 
		MPEG2PS, 
		MPEG2TS, 
		M2TS, 
		MPEG1, 
		FLV, 
		WTV, 
		OGG, 
		THREE_GP, 
		RTP, 
		RTSP, 
		APPLE_HTTP, 
		REAL_MEDIA,
	}

	VideoContainerEnum videoContainer;
	alias videoContainer this;

  public String getFFmpegValue()
  {
	  switch (videoContainer)
	  {
		  case ANY:
			  throw new RuntimeException("Cannot transcode audio into any"); 

		  case AVI:
			  return "avi"; 

		  case MATROSKA:
			  return "matroska"; 

		  case ASF:
			  return "asf"; 

		  case MP4:
			  return "mp4"; 

		  case MPEG2PS:
			  return "vob"; 

		  case MPEG2TS:
			  return "mpegts"; 

		  case M2TS:
			  return "mpegts"; 

		  case MPEG1:
			  return "mpegvideo"; 

		  case FLV:
			  return "flv"; 

		  case WTV:
			  return "wtv"; 

		  case OGG:
			  return "ogg"; 

		  case THREE_GP:
			  return "3gp"; 

		  case RTP:
			  return "rtp"; 

		  case RTSP:
			  return "rtsp"; 

		  case APPLE_HTTP:
			  return "applehttp"; 

		  case REAL_MEDIA:
			  return "rm";
	  }
	  return "";
  }

  public static VideoContainer getByFFmpegValue(String ffmpegName, String filePath)
  {
    if (ffmpegName !is null) {
      if (ffmpegName.equals("*"))
        return ANY;
      if (ffmpegName.equals("asf"))
        return ASF;
      if (ffmpegName.equals("mpegvideo"))
        return MPEG1;
      if ((ffmpegName.equals("mpeg")) || (ffmpegName.equals("vob")))
        return MPEG2PS;
      if (ffmpegName.equals("mpegts"))
        return MPEG2TS;
      if (ffmpegName.equals("m2ts"))
        return M2TS;
      if (ffmpegName.equals("matroska"))
        return MATROSKA;
      if (ffmpegName.equals("avi"))
        return AVI;
      if ((ffmpegName.equals("mov")) || (ffmpegName.equals("mp4"))) {
        if ((filePath !is null) && (StringUtils.localeSafeToLowercase(filePath).endsWith(".3gp"))) {
          return THREE_GP;
        }
        return MP4;
      }if (ffmpegName.equals("flv"))
        return FLV;
      if (ffmpegName.equals("wtv"))
        return WTV;
      if (ffmpegName.equals("ogg"))
        return OGG;
      if (ffmpegName.equals("3gp"))
        return THREE_GP;
      if (ffmpegName.equals("rtp"))
        return RTP;
      if (ffmpegName.equals("rtsp"))
        return RTSP;
      if ((ffmpegName.equals("applehttp")) || (ffmpegName.equals("hls")))
        return APPLE_HTTP;
      if (ffmpegName.equals("rm")) {
        return REAL_MEDIA;
      }
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.dlna.VideoContainer
 * JD-Core Version:    0.6.2
 */