module org.serviio.dlna.MediaFormatProfile;

import java.util.Arrays;
import java.util.List;
import org.serviio.library.metadata.MediaFileType;

public class MediaFormatProfile
{
	enum MediaFormatProfileEnum
	{
		MP3, 
		WMA_BASE, 
		WMA_FULL, 
		LPCM16_44_MONO, 
		LPCM16_44_STEREO, 
		LPCM16_48_MONO, 
		LPCM16_48_STEREO, 
		AAC_ISO, 
		AAC_ISO_320, 
		AAC_ADTS, 
		AAC_ADTS_320, 
		FLAC, 
		OGG, 

		JPEG_SM, 
		JPEG_MED, 
		JPEG_LRG, 
		JPEG_TN, 
		PNG_LRG, 
		PNG_TN, 
		GIF_LRG, 
		RAW, 

		MPEG1, 
		MPEG_PS_PAL, 
		MPEG_PS_NTSC, 
		MPEG_TS_SD_EU, 
		MPEG_TS_SD_EU_ISO, 
		MPEG_TS_SD_EU_T, 
		MPEG_TS_SD_NA, 
		MPEG_TS_SD_NA_ISO, 
		MPEG_TS_SD_NA_T, 
		MPEG_TS_SD_KO, 
		MPEG_TS_SD_KO_ISO, 
		MPEG_TS_SD_KO_T, 
		MPEG_TS_JP_T, 
		AVI, 
		MATROSKA, 
		FLV, 
		DVR_MS, 
		WTV, 
		OGV, 
		AVC_MP4_MP_SD_AAC_MULT5, 
		AVC_MP4_MP_SD_MPEG1_L3, 
		AVC_MP4_MP_SD_AC3, 
		AVC_MP4_MP_HD_720p_AAC, 
		AVC_MP4_MP_HD_1080i_AAC, 
		AVC_MP4_HP_HD_AAC, 
		AVC_TS_MP_HD_AAC_MULT5, 
		AVC_TS_MP_HD_AAC_MULT5_T, 
		AVC_TS_MP_HD_AAC_MULT5_ISO, 
		AVC_TS_MP_HD_MPEG1_L3, 
		AVC_TS_MP_HD_MPEG1_L3_T, 
		AVC_TS_MP_HD_MPEG1_L3_ISO, 
		AVC_TS_MP_HD_AC3, 
		AVC_TS_MP_HD_AC3_T, 
		AVC_TS_MP_HD_AC3_ISO, 
		AVC_TS_HP_HD_MPEG1_L2_T, 
		AVC_TS_HP_HD_MPEG1_L2_ISO, 
		AVC_TS_MP_SD_AAC_MULT5, 
		AVC_TS_MP_SD_AAC_MULT5_T, 
		AVC_TS_MP_SD_AAC_MULT5_ISO, 
		AVC_TS_MP_SD_MPEG1_L3, 
		AVC_TS_MP_SD_MPEG1_L3_T, 
		AVC_TS_MP_SD_MPEG1_L3_ISO, 
		AVC_TS_HP_SD_MPEG1_L2_T, 
		AVC_TS_HP_SD_MPEG1_L2_ISO, 
		AVC_TS_MP_SD_AC3, 
		AVC_TS_MP_SD_AC3_T, 
		AVC_TS_MP_SD_AC3_ISO, 
		AVC_TS_HD_DTS_T, 
		AVC_TS_HD_DTS_ISO, 
		WMVMED_BASE, 
		WMVMED_FULL, 
		WMVMED_PRO, 
		WMVHIGH_FULL, 
		WMVHIGH_PRO, 
		VC1_ASF_AP_L1_WMA, 
		VC1_ASF_AP_L2_WMA, 
		VC1_ASF_AP_L3_WMA, 
		VC1_TS_AP_L1_AC3_ISO, 
		VC1_TS_AP_L2_AC3_ISO, 
		VC1_TS_HD_DTS_ISO, 
		VC1_TS_HD_DTS_T, 
		MPEG4_P2_MP4_ASP_AAC, 
		MPEG4_P2_MP4_SP_L6_AAC, 
		MPEG4_P2_MP4_NDSD, 
		MPEG4_P2_TS_ASP_AAC, 
		MPEG4_P2_TS_ASP_AAC_T, 
		MPEG4_P2_TS_ASP_AAC_ISO, 
		MPEG4_P2_TS_ASP_MPEG1_L3, 
		MPEG4_P2_TS_ASP_MPEG1_L3_T, 
		MPEG4_P2_TS_ASP_MPEG1_L3_ISO, 
		MPEG4_P2_TS_ASP_MPEG2_L2, 
		MPEG4_P2_TS_ASP_MPEG2_L2_T, 
		MPEG4_P2_TS_ASP_MPEG2_L2_ISO, 
		MPEG4_P2_TS_ASP_AC3, 
		MPEG4_P2_TS_ASP_AC3_T, 
		MPEG4_P2_TS_ASP_AC3_ISO, 
		AVC_TS_HD_50_LPCM_T, 
		AVC_MP4_LPCM, 
		MPEG4_P2_3GPP_SP_L0B_AAC, 
		MPEG4_P2_3GPP_SP_L0B_AMR, 
		AVC_3GPP_BL_QCIF15_AAC, 
		MPEG4_H263_3GPP_P0_L10_AMR, 
		MPEG4_H263_MP4_P0_L10_AAC,
	}

	MediaFormatProfileEnum mediaFormatProfile;
	alias mediaFormatProfile this;

  public MediaFileType getFileType()
  {
	  switch (mediaFormatProfile)
	  {
		  case MP3:
			  return MediaFileType.AUDIO; 

		  case WMA_BASE:
			  return MediaFileType.AUDIO; 

		  case WMA_FULL:
			  return MediaFileType.AUDIO; 

		  case LPCM16_44_MONO:
			  return MediaFileType.AUDIO; 

		  case LPCM16_44_STEREO:
			  return MediaFileType.AUDIO; 

		  case LPCM16_48_MONO:
			  return MediaFileType.AUDIO; 

		  case LPCM16_48_STEREO:
			  return MediaFileType.AUDIO; 

		  case AAC_ISO:
			  return MediaFileType.AUDIO; 

		  case AAC_ISO_320:
			  return MediaFileType.AUDIO; 

		  case AAC_ADTS:
			  return MediaFileType.AUDIO; 

		  case AAC_ADTS_320:
			  return MediaFileType.AUDIO; 

		  case FLAC:
			  return MediaFileType.AUDIO; 

		  case OGG:
			  return MediaFileType.AUDIO; 

		  case JPEG_SM:
			  return MediaFileType.IMAGE; 

		  case JPEG_MED:
			  return MediaFileType.IMAGE; 

		  case JPEG_LRG:
			  return MediaFileType.IMAGE; 

		  case JPEG_TN:
			  return MediaFileType.IMAGE; 

		  case PNG_LRG:
			  return MediaFileType.IMAGE; 

		  case PNG_TN:
			  return MediaFileType.IMAGE; 

		  case GIF_LRG:
			  return MediaFileType.IMAGE; 

		  case RAW:
			  return MediaFileType.IMAGE; 

		  case MPEG1:
			  return MediaFileType.VIDEO; 

		  case MPEG_PS_PAL:
			  return MediaFileType.VIDEO; 

		  case MPEG_PS_NTSC:
			  return MediaFileType.VIDEO; 

		  case MPEG_TS_SD_EU:
			  return MediaFileType.VIDEO; 

		  case MPEG_TS_SD_EU_ISO:
			  return MediaFileType.VIDEO; 

		  case MPEG_TS_SD_EU_T:
			  return MediaFileType.VIDEO; 

		  case MPEG_TS_SD_NA:
			  return MediaFileType.VIDEO; 

		  case MPEG_TS_SD_NA_ISO:
			  return MediaFileType.VIDEO; 

		  case MPEG_TS_SD_NA_T:
			  return MediaFileType.VIDEO; 

		  case MPEG_TS_SD_KO:
			  return MediaFileType.VIDEO; 

		  case MPEG_TS_SD_KO_ISO:
			  return MediaFileType.VIDEO; 

		  case MPEG_TS_SD_KO_T:
			  return MediaFileType.VIDEO; 

		  case MPEG_TS_JP_T:
			  return MediaFileType.VIDEO; 

		  case AVI:
			  return MediaFileType.VIDEO; 

		  case MATROSKA:
			  return MediaFileType.VIDEO; 

		  case FLV:
			  return MediaFileType.VIDEO; 

		  case DVR_MS:
			  return MediaFileType.VIDEO; 

		  case WTV:
			  return MediaFileType.VIDEO; 

		  case OGV:
			  return MediaFileType.VIDEO; 

		  case AVC_MP4_MP_SD_AAC_MULT5:
			  return MediaFileType.VIDEO; 

		  case AVC_MP4_MP_SD_MPEG1_L3:
			  return MediaFileType.VIDEO; 

		  case AVC_MP4_MP_SD_AC3:
			  return MediaFileType.VIDEO; 

		  case AVC_MP4_MP_HD_720p_AAC:
			  return MediaFileType.VIDEO; 

		  case AVC_MP4_MP_HD_1080i_AAC:
			  return MediaFileType.VIDEO; 

		  case AVC_MP4_HP_HD_AAC:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_MP_HD_AAC_MULT5:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_MP_HD_AAC_MULT5_T:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_MP_HD_AAC_MULT5_ISO:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_MP_HD_MPEG1_L3:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_MP_HD_MPEG1_L3_T:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_MP_HD_MPEG1_L3_ISO:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_MP_HD_AC3:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_MP_HD_AC3_T:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_MP_HD_AC3_ISO:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_HP_HD_MPEG1_L2_T:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_HP_HD_MPEG1_L2_ISO:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_MP_SD_AAC_MULT5:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_MP_SD_AAC_MULT5_T:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_MP_SD_AAC_MULT5_ISO:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_MP_SD_MPEG1_L3:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_MP_SD_MPEG1_L3_T:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_MP_SD_MPEG1_L3_ISO:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_HP_SD_MPEG1_L2_T:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_HP_SD_MPEG1_L2_ISO:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_MP_SD_AC3:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_MP_SD_AC3_T:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_MP_SD_AC3_ISO:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_HD_DTS_T:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_HD_DTS_ISO:
			  return MediaFileType.VIDEO; 

		  case WMVMED_BASE:
			  return MediaFileType.VIDEO; 

		  case WMVMED_FULL:
			  return MediaFileType.VIDEO; 

		  case WMVMED_PRO:
			  return MediaFileType.VIDEO; 

		  case WMVHIGH_FULL:
			  return MediaFileType.VIDEO; 

		  case WMVHIGH_PRO:
			  return MediaFileType.VIDEO; 

		  case VC1_ASF_AP_L1_WMA:
			  return MediaFileType.VIDEO; 

		  case VC1_ASF_AP_L2_WMA:
			  return MediaFileType.VIDEO; 

		  case VC1_ASF_AP_L3_WMA:
			  return MediaFileType.VIDEO; 

		  case VC1_TS_AP_L1_AC3_ISO:
			  return MediaFileType.VIDEO; 

		  case VC1_TS_AP_L2_AC3_ISO:
			  return MediaFileType.VIDEO; 

		  case VC1_TS_HD_DTS_ISO:
			  return MediaFileType.VIDEO; 

		  case VC1_TS_HD_DTS_T:
			  return MediaFileType.VIDEO; 

		  case MPEG4_P2_MP4_ASP_AAC:
			  return MediaFileType.VIDEO; 

		  case MPEG4_P2_MP4_SP_L6_AAC:
			  return MediaFileType.VIDEO; 

		  case MPEG4_P2_MP4_NDSD:
			  return MediaFileType.VIDEO; 

		  case MPEG4_P2_TS_ASP_AAC:
			  return MediaFileType.VIDEO; 

		  case MPEG4_P2_TS_ASP_AAC_T:
			  return MediaFileType.VIDEO; 

		  case MPEG4_P2_TS_ASP_AAC_ISO:
			  return MediaFileType.VIDEO; 

		  case MPEG4_P2_TS_ASP_MPEG1_L3:
			  return MediaFileType.VIDEO; 

		  case MPEG4_P2_TS_ASP_MPEG1_L3_T:
			  return MediaFileType.VIDEO; 

		  case MPEG4_P2_TS_ASP_MPEG1_L3_ISO:
			  return MediaFileType.VIDEO; 

		  case MPEG4_P2_TS_ASP_MPEG2_L2:
			  return MediaFileType.VIDEO; 

		  case MPEG4_P2_TS_ASP_MPEG2_L2_T:
			  return MediaFileType.VIDEO; 

		  case MPEG4_P2_TS_ASP_MPEG2_L2_ISO:
			  return MediaFileType.VIDEO; 

		  case MPEG4_P2_TS_ASP_AC3:
			  return MediaFileType.VIDEO; 

		  case MPEG4_P2_TS_ASP_AC3_T:
			  return MediaFileType.VIDEO; 

		  case MPEG4_P2_TS_ASP_AC3_ISO:
			  return MediaFileType.VIDEO; 

		  case AVC_TS_HD_50_LPCM_T:
			  return MediaFileType.VIDEO; 

		  case AVC_MP4_LPCM:
			  return MediaFileType.VIDEO; 

		  case MPEG4_P2_3GPP_SP_L0B_AAC:
			  return MediaFileType.VIDEO; 

		  case MPEG4_P2_3GPP_SP_L0B_AMR:
			  return MediaFileType.VIDEO; 

		  case AVC_3GPP_BL_QCIF15_AAC:
			  return MediaFileType.VIDEO; 

		  case MPEG4_H263_3GPP_P0_L10_AMR:
			  return MediaFileType.VIDEO; 

		  case MPEG4_H263_MP4_P0_L10_AAC:
			  return MediaFileType.VIDEO;
	  }
  }

  public static List!(MediaFormatProfile) getSupportedMediaFormatProfiles()
  {
    return Arrays.asList(values());
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.dlna.MediaFormatProfile
 * JD-Core Version:    0.6.2
 */