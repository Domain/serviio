module org.serviio.library.local.metadata.extractor.embedded.AVCHeader;

import java.io.IOException;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.Locale;
import org.serviio.dlna.H264Profile;
import org.serviio.library.local.metadata.extractor.embedded.h264.AnnexBNALUnitReader;
import org.serviio.library.local.metadata.extractor.embedded.h264.BufferWrapper;
import org.serviio.library.local.metadata.extractor.embedded.h264.BufferWrapperImpl;
import org.serviio.library.local.metadata.extractor.embedded.h264.NALUnit;
import org.serviio.library.local.metadata.extractor.embedded.h264.NALUnitType;
import org.serviio.library.local.metadata.extractor.embedded.h264.SeqParameterSet;

public class AVCHeader
{
  private byte[] buffer;
  private Integer profile;
  private Integer level;
  private Integer refFrames;

  public this(byte[] buffer)
  {
    this.buffer = buffer;
  }

  public void parse()
  {
    BufferWrapper ibw = new BufferWrapperImpl(buffer);
    AnnexBNALUnitReader nalUnitReader = new AnnexBNALUnitReader(ibw);
    BufferWrapper nal;
    while ((nal = nalUnitReader.nextNALUnit()) !is null) {
      NALUnit nu = NALUnit.read(nal);
      if (nu.type == NALUnitType.SPS) {
        SeqParameterSet param = SeqParameterSet.read(nal);
        profile = Integer.valueOf(param.profile_idc);
        level = Integer.valueOf(param.level_idc);
        refFrames = Integer.valueOf(param.num_ref_frames);
        break;
      }
    }
  }

  public H264Profile getProfile() {
    return profile !is null ? H264Profile.getByCode(profile.intValue()) : null;
  }

  public String getLevel() {
    return level !is null ? convertLevelToString(level.intValue() / 10.0F) : null;
  }

  public Integer getRefFrames() {
    return refFrames;
  }

  private String convertLevelToString(float level) {
    NumberFormat df = DecimalFormat.getInstance(Locale.ENGLISH);
    df.setMinimumFractionDigits(0);
    df.setMaximumFractionDigits(1);

    return df.format(level);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.AVCHeader
 * JD-Core Version:    0.6.2
 */