module org.serviio.dlna.VideoCodec;

import java.lang.String;

public class VideoCodec
{
	enum VideoCodecEnum
	{
		H264, 
		H263, 
		VC1, 
		MPEG4, 
		MSMPEG4, 
		MPEG2, 
		WMV, 
		MPEG1, 
		MJPEG, 
		FLV, 
		VP6, 
		VP8, 
		THEORA, 
		DV, 
		REAL,
	}

	VideoCodecEnum videoCodec;
	alias videoCodec this;

  public String getFFmpegEncoderName()
  {
	  switch (videoCodec)
	  {
		  case H264:
			  throw new RuntimeException("Canot transcode to H264"); 

		  case H263:
			  throw new RuntimeException("Canot transcode to H263"); 

		  case VC1:
			  throw new RuntimeException("Canot transcode to VC1"); 

		  case MPEG4:
			  throw new RuntimeException("Canot transcode to MPEG4"); 

		  case MSMPEG4:
			  throw new RuntimeException("Canot transcode to MSMPEG4"); 

		  case MPEG2:
			  return "mpeg2video"; 

		  case WMV:
			  return "wmv2"; 

		  case MPEG1:
			  throw new RuntimeException("Canot transcode to Mpeg1"); 

		  case MJPEG:
			  throw new RuntimeException("Canot transcode to MJpeg"); 

		  case FLV:
			  return "flv"; 

		  case VP6:
			  throw new RuntimeException("Canot transcode to VP6"); 

		  case VP8:
			  throw new RuntimeException("Canot transcode to VP8"); 

		  case THEORA:
			  throw new RuntimeException("Canot transcode to Theora"); 

		  case DV:
			  throw new RuntimeException("Canot transcode to DV"); 

		  case REAL:
			  throw new RuntimeException("Canot transcode to Real Video");
	  }

	  return "";
  }

  public static VideoCodec getByFFmpegValue(String ffmpegName)
  {
    if (ffmpegName !is null) {
      if (ffmpegName.equals("vc1"))
        return VC1;
      if (ffmpegName.equals("mpeg4"))
        return MPEG4;
      if (ffmpegName.startsWith("msmpeg4"))
        return MSMPEG4;
      if (ffmpegName.equals("mpeg2video"))
        return MPEG2;
      if (ffmpegName.equals("h264"))
        return H264;
      if ((ffmpegName.equals("wmv1")) || (ffmpegName.equals("wmv3")) || (ffmpegName.equals("wmv2")))
        return WMV;
      if ((ffmpegName.equals("mpeg1video")) || (ffmpegName.equals("mpegvideo")))
        return MPEG1;
      if ((ffmpegName.equals("mjpeg")) || (ffmpegName.equals("mjpegb")))
        return MJPEG;
      if (ffmpegName.startsWith("vp6"))
        return VP6;
      if (ffmpegName.startsWith("vp8"))
        return VP8;
      if (ffmpegName.startsWith("flv"))
        return FLV;
      if (ffmpegName.equals("theora"))
        return THEORA;
      if (ffmpegName.equals("dvvideo"))
        return DV;
      if (ffmpegName.startsWith("h263"))
        return H263;
      if (ffmpegName.startsWith("rv")) {
        return REAL;
      }
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.dlna.VideoCodec
 * JD-Core Version:    0.6.2
 */