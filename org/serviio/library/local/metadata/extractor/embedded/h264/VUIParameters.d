module org.serviio.library.local.metadata.extractor.embedded.h264.VUIParameters;

public class VUIParameters
{
  public bool aspect_ratio_info_present_flag;
  public int sar_width;
  public int sar_height;
  public bool overscan_info_present_flag;
  public bool overscan_appropriate_flag;
  public bool video_signal_type_present_flag;
  public int video_format;
  public bool video_full_range_flag;
  public bool colour_description_present_flag;
  public int colour_primaries;
  public int transfer_characteristics;
  public int matrix_coefficients;
  public bool chroma_loc_info_present_flag;
  public int chroma_sample_loc_type_top_field;
  public int chroma_sample_loc_type_bottom_field;
  public bool timing_info_present_flag;
  public int num_units_in_tick;
  public int time_scale;
  public bool fixed_frame_rate_flag;
  public bool low_delay_hrd_flag;
  public bool pic_struct_present_flag;
  public HRDParameters nalHRDParams;
  public HRDParameters vclHRDParams;
  public BitstreamRestriction bitstreamRestriction;
  public AspectRatio aspect_ratio;

  public String toString()
  {
    return "VUIParameters{\naspect_ratio_info_present_flag=" + aspect_ratio_info_present_flag + "\n" + ", sar_width=" + sar_width + "\n" + ", sar_height=" + sar_height + "\n" + ", overscan_info_present_flag=" + overscan_info_present_flag + "\n" + ", overscan_appropriate_flag=" + overscan_appropriate_flag + "\n" + ", video_signal_type_present_flag=" + video_signal_type_present_flag + "\n" + ", video_format=" + video_format + "\n" + ", video_full_range_flag=" + video_full_range_flag + "\n" + ", colour_description_present_flag=" + colour_description_present_flag + "\n" + ", colour_primaries=" + colour_primaries + "\n" + ", transfer_characteristics=" + transfer_characteristics + "\n" + ", matrix_coefficients=" + matrix_coefficients + "\n" + ", chroma_loc_info_present_flag=" + chroma_loc_info_present_flag + "\n" + ", chroma_sample_loc_type_top_field=" + chroma_sample_loc_type_top_field + "\n" + ", chroma_sample_loc_type_bottom_field=" + chroma_sample_loc_type_bottom_field + "\n" + ", timing_info_present_flag=" + timing_info_present_flag + "\n" + ", num_units_in_tick=" + num_units_in_tick + "\n" + ", time_scale=" + time_scale + "\n" + ", fixed_frame_rate_flag=" + fixed_frame_rate_flag + "\n" + ", low_delay_hrd_flag=" + low_delay_hrd_flag + "\n" + ", pic_struct_present_flag=" + pic_struct_present_flag + "\n" + ", nalHRDParams=" + nalHRDParams + "\n" + ", vclHRDParams=" + vclHRDParams + "\n" + ", bitstreamRestriction=" + bitstreamRestriction + "\n" + ", aspect_ratio=" + aspect_ratio + "\n" + '}';
  }

  public static class BitstreamRestriction
  {
    public bool motion_vectors_over_pic_boundaries_flag;
    public int max_bytes_per_pic_denom;
    public int max_bits_per_mb_denom;
    public int log2_max_mv_length_horizontal;
    public int log2_max_mv_length_vertical;
    public int num_reorder_frames;
    public int max_dec_frame_buffering;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.h264.VUIParameters
 * JD-Core Version:    0.6.2
 */