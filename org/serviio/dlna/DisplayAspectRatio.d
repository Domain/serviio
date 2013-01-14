module org.serviio.dlna.DisplayAspectRatio;

import java.lang.String;
import java.text.DecimalFormat;

public class DisplayAspectRatio
{
	enum DisplayAspectRatioEnum : int[]
	{
		DAR_16_9 = [16, 9],
	}

	DisplayAspectRatioEnum displayAspectRatio;
	alias displayAspectRatio this;

  //private int x;
  //private int y;
  private static DecimalFormat df = new DecimalFormat("##.##");

  //private this(int x, int y) {
  //  this.x = x;
  //  this.y = y;
  //}

  public float getRatio() {
    //return x / y;
	  return displayAspectRatio[0] / displayAspectRatio[1];
  }

  public static float getRatio(int width, int height) {
    return width / height;
  }

  public bool isEqualTo(int width, int height) {
    return df.format(getRatio()).equals(df.format(getRatio(width, height)));
  }

  public static DisplayAspectRatio fromString(String dar) {
    if (dar.equals("16:9")) {
      return DAR_16_9;
    }
    throw new IllegalArgumentException("DAR " ~ dar ~ "is not supported");
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.dlna.DisplayAspectRatio
 * JD-Core Version:    0.6.2
 */