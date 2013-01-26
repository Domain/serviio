module org.serviio.library.local.metadata.extractor.embedded.h264.NALUnitType;

import java.lang.String;

public class NALUnitType
{
    public static const NALUnitType NON_IDR_SLICE = new NALUnitType(1, "non IDR slice");
    public static const NALUnitType SLICE_PART_A = new NALUnitType(2, "slice part a");
    public static const NALUnitType SLICE_PART_B = new NALUnitType(3, "slice part b");
    public static const NALUnitType SLICE_PART_C = new NALUnitType(4, "slice part c");
    public static const NALUnitType IDR_SLICE = new NALUnitType(5, "idr slice");
    public static const NALUnitType SEI = new NALUnitType(6, "sei");
    public static const NALUnitType SPS = new NALUnitType(7, "sequence parameter set");
    public static const NALUnitType PPS = new NALUnitType(8, "picture parameter set");
    public static const NALUnitType ACC_UNIT_DELIM = new NALUnitType(9, "access unit delimiter");
    public static const NALUnitType END_OF_SEQ = new NALUnitType(10, "end of sequence");
    public static const NALUnitType END_OF_STREAM = new NALUnitType(11, "end of stream");
    public static const NALUnitType FILTER_DATA = new NALUnitType(12, "filter data");
    public static const NALUnitType SEQ_PAR_SET_EXT = new NALUnitType(13, "sequence parameter set extension");
    public static const NALUnitType AUX_SLICE = new NALUnitType(19, "auxilary slice");
    private /*final*/ int value;
    private /*final*/ String name;

    private this(int value, String name)
    {
        this.value = value;
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public int getValue() {
        return value;
    }

    public static NALUnitType fromValue(int value) {
        if (value == NON_IDR_SLICE.value)
            return NON_IDR_SLICE;
        if (value == SLICE_PART_A.value)
            return SLICE_PART_A;
        if (value == SLICE_PART_B.value)
            return SLICE_PART_B;
        if (value == SLICE_PART_C.value)
            return SLICE_PART_C;
        if (value == IDR_SLICE.value)
            return IDR_SLICE;
        if (value == SEI.value)
            return SEI;
        if (value == SPS.value)
            return SPS;
        if (value == PPS.value)
            return PPS;
        if (value == ACC_UNIT_DELIM.value)
            return ACC_UNIT_DELIM;
        if (value == END_OF_SEQ.value)
            return END_OF_SEQ;
        if (value == END_OF_STREAM.value)
            return END_OF_STREAM;
        if (value == FILTER_DATA.value)
            return FILTER_DATA;
        if (value == SEQ_PAR_SET_EXT.value)
            return SEQ_PAR_SET_EXT;
        if (value == AUX_SLICE.value)
            return AUX_SLICE;
        return null;
    }

    override public String toString()
    {
        return "NALUnitType{value=" ~ value ~ ", name='" ~ name ~ '\'' ~ '}';
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.h264.NALUnitType
* JD-Core Version:    0.6.2
*/