module org.serviio.dlna.AudioCodec;

import java.lang.String;

public class AudioCodec
{
	enum AudioCodecEnum
	{
		MP3,
		MP2,
		MP1,
		AAC,
		AC3,
		LPCM,
		DTS,
		WMA,
		WMA_PRO,
		FLAC,
		VORBIS,
		TRUEHD,
		AMR,
		REAL,
	}

	AudioCodecEnum audioCodec;
	alias audioCodec this;

	public String getFFmpegEncoderName()
	{
		switch(audioCodec)
		{
			case MP3:
				return "libmp3lame"; 

			case MP2:
				return "mp2"; 

			case MP1:
				return "mp1"; 

			case AAC:
				return "aac"; 

			case AC3:
				if (System.getProperty("serviio.fixedPointEncoders") is null) {
					return "ac3";
				} 
				return "ac3_fixed";

			case LPCM:
				return "pcm_s16be"; 

			case DTS:
				return "dca"; 

			case WMA:
				return "wmav2"; 

			case WMA_PRO:
				return "wmapro"; 

			case FLAC:
				return "flac"; 

			case VORBIS:
				return "vorbis"; 

			case TRUEHD:
				return "truehd"; 

			case AMR:
				return "amrnb"; 

			case REAL:
				throw new RuntimeException("RealAudio is not supported");
		}

		return "";
	}

  public static AudioCodecEnum getByFFmpegDecoderName(String ffmpegName)
  {
    if (ffmpegName !is null) {
      if (ffmpegName.equals("mp3"))
        return MP3;
      if ((ffmpegName.equals("ac3")) || (ffmpegName.startsWith("ac-3")) || (ffmpegName.equals("liba52")) || (ffmpegName.equals("eac3")))
      {
        return AC3;
      }if ((ffmpegName.equals("aac")) || (ffmpegName.equals("mpeg4aac")) || (ffmpegName.equals("aac_latm")))
        return AAC;
      if ((ffmpegName.startsWith("dca")) || (ffmpegName.startsWith("dts")))
        return DTS;
      if ((ffmpegName.equals("wmav1")) || (ffmpegName.equals("wmav2")))
        return WMA;
      if ((ffmpegName.equals("lpcm")) || (ffmpegName.startsWith("pcm_")) || (ffmpegName.startsWith("adpcm_")))
        return LPCM;
      if ((ffmpegName.equals("wmapro")) || (ffmpegName.equals("0x0162")))
        return WMA_PRO;
      if (ffmpegName.equals("mp2"))
        return MP2;
      if (ffmpegName.equals("mp1"))
        return MP1;
      if (ffmpegName.equals("flac"))
        return FLAC;
      if (ffmpegName.equals("vorbis"))
        return VORBIS;
      if (ffmpegName.equals("truehd"))
        return TRUEHD;
      if ((ffmpegName.equals("amrnb")) || (ffmpegName.equals("amrwb")) || (ffmpegName.equals("amr_nb")) || (ffmpegName.equals("amr_wb")))
        return AMR;
      if ((ffmpegName.equals("ralf")) || (ffmpegName.startsWith("real")) || (ffmpegName.equals("sipr")) || (ffmpegName.equals("cook"))) {
        return REAL;
      }
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.dlna.AudioCodec
 * JD-Core Version:    0.6.2
 */