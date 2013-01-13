module org.serviio.library.local.metadata.extractor.embedded.h264.HRDParameters;

public class HRDParameters
{
  public int cpb_cnt_minus1;
  public int bit_rate_scale;
  public int cpb_size_scale;
  public int[] bit_rate_value_minus1;
  public int[] cpb_size_value_minus1;
  public bool[] cbr_flag;
  public int initial_cpb_removal_delay_length_minus1;
  public int cpb_removal_delay_length_minus1;
  public int dpb_output_delay_length_minus1;
  public int time_offset_length;
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.h264.HRDParameters
 * JD-Core Version:    0.6.2
 */