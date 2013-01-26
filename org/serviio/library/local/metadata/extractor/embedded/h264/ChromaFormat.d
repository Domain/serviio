module org.serviio.library.local.metadata.extractor.embedded.h264.ChromaFormat;

import java.lang.String;

public class ChromaFormat
{
    public static ChromaFormat MONOCHROME;
    public static ChromaFormat YUV_420;
    public static ChromaFormat YUV_422;
    public static ChromaFormat YUV_444;
    private int id;
    private int subWidth;
    private int subHeight;

    static this()
    {
        MONOCHROME = new ChromaFormat(0, 0, 0);
        YUV_420 = new ChromaFormat(1, 2, 2);
        YUV_422 = new ChromaFormat(2, 2, 1);
        YUV_444 = new ChromaFormat(3, 1, 1);
    }

    public this(int id, int subWidth, int subHeight)
    {
        this.id = id;
        this.subWidth = subWidth;
        this.subHeight = subHeight;
    }

    public static ChromaFormat fromId(int id) {
        if (id == MONOCHROME.id)
            return MONOCHROME;
        if (id == YUV_420.id)
            return YUV_420;
        if (id == YUV_422.id)
            return YUV_422;
        if (id == YUV_444.id) {
            return YUV_444;
        }
        return null;
    }

    public int getId() {
        return id;
    }

    public int getSubWidth() {
        return subWidth;
    }

    public int getSubHeight() {
        return subHeight;
    }

    override public String toString()
    {
        return "ChromaFormat{\nid=" ~ id ~ ",\n" ~ " subWidth=" ~ subWidth ~ ",\n" ~ " subHeight=" ~ subHeight ~ '}';
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.h264.ChromaFormat
* JD-Core Version:    0.6.2
*/