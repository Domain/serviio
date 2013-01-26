module org.serviio.util.MediaUtils;

import java.lang.Integer;
import java.lang.String;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MediaUtils
{
    private static immutable Logger log;

    static this()
    {
        log = LoggerFactory.getLogger!(MediaUtils)();
    }

    public static Integer convertBitrateFromKbpsToByPS(Integer bitrate)
    {
        if ((bitrate !is null) && (bitrate.intValue() > 0)) {
            return Integer.valueOf(bitrate.intValue() * 1000 / 8);
        }
        return null;
    }

    public static String getValidFps(String fps)
    {
        String validFrameRate = fps;
        if (ObjectValidator.isNotEmpty(fps)) {
            try {
                double fr = Double.parseDouble(fps);
                if ((fr > 23.899999999999999) && (fr < 23.989999999999998))
                    validFrameRate = "23.976";
                else if ((fr > 23.989999999999998) && (fr < 24.100000000000001))
                    validFrameRate = "24";
                else if ((fr >= 24.989999999999998) && (fr < 25.100000000000001))
                    validFrameRate = "25";
                else if ((fr > 29.899999999999999) && (fr < 29.989999999999998))
                    validFrameRate = "29.97";
                else if ((fr >= 29.989999999999998) && (fr < 30.100000000000001))
                    validFrameRate = "30";
                else if ((fr > 49.899999999999999) && (fr < 50.100000000000001))
                    validFrameRate = "50";
                else if ((fr > 59.899999999999999) && (fr < 59.990000000000002))
                    validFrameRate = "59.94";
                else if ((fr >= 59.990000000000002) && (fr < 60.100000000000001)) {
                    validFrameRate = "60";
                }
                else
                    validFrameRate = "23.976";
            }
            catch (NumberFormatException nfe) {
                log.warn(String.format("Cannot get valid FPS of video file: %s", cast(Object[])[ fps ]));
            }
        }
        return validFrameRate;
    }

    public static String formatFpsForFFmpeg(String fps)
    {
        String normalizedFps = getValidFps(fps);
        if (normalizedFps.equals("23.976"))
            return "24000/1001";
        if (normalizedFps.equals("29.97"))
            return "30000/1001";
        if (normalizedFps.equals("59.94")) {
            return "60000/1001";
        }
        return normalizedFps;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.util.MediaUtils
* JD-Core Version:    0.6.2
*/