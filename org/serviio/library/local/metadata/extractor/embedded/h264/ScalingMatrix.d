module org.serviio.library.local.metadata.extractor.embedded.h264.ScalingMatrix;

import java.lang.String;
import java.util.Arrays;
import org.serviio.library.local.metadata.extractor.embedded.h264.ScalingList;

public class ScalingMatrix
{
    public ScalingList[] ScalingList4x4;
    public ScalingList[] ScalingList8x8;

    override public String toString()
    {
        return (new StringBuilder()).append("ScalingMatrix{ScalingList4x4=").append(ScalingList4x4 is null ? null : Arrays.asList(ScalingList4x4)).append("\n").append(", ScalingList8x8=").append(ScalingList8x8 is null ? null : Arrays.asList(ScalingList8x8)).append("\n").append('}').toString();
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.h264.ScalingMatrix
* JD-Core Version:    0.6.2
*/