module org.serviio.library.local.metadata.extractor.embedded.h264.CAVLCReader;

import java.lang.String;
import java.io.IOException;
import org.serviio.library.local.metadata.extractor.embedded.h264.BitstreamReader;
import org.serviio.library.local.metadata.extractor.embedded.h264.BufferWrapper;
import org.serviio.library.local.metadata.extractor.embedded.h264.BTree;

public class CAVLCReader : BitstreamReader
{
    public this(BufferWrapper is_)
    {
        super(is_);
    }

    public long readNBit(int n, String message) {
        long val = readNBit(n);

        trace(message, String.valueOf(val));

        return val;
    }

    private int readUE()
    {
        int cnt = 0;
        while (read1Bit() == 0) {
            cnt++;
        }
        int res = 0;
        if (cnt > 0) {
            long val = readNBit(cnt);

            res = cast(int)((1 << cnt) - 1 + val);
        }

        return res;
    }

    public int readUE(String message)
    {
        int res = readUE();

        trace(message, String.valueOf(res));

        return res;
    }

    public int readSE(String message) {
        int val = readUE();

        int sign = ((val & 0x1) << 1) - 1;
        val = ((val >> 1) + (val & 0x1)) * sign;

        trace(message, String.valueOf(val));

        return val;
    }

    public bool readBool(String message)
    {
        bool res = read1Bit() != 0;

        trace(message, res ? "1" : "0");

        return res;
    }

    public int readU(int i, String string) {
        return cast(int)readNBit(i, string);
    }

    public byte[] read(int payloadSize) {
        byte[] result = new byte[payloadSize];
        for (int i = 0; i < payloadSize; i++) {
            result[i] = (cast(byte)readByte());
        }
        return result;
    }

    public bool readAE()
    {
        throw new UnsupportedOperationException("Stan");
    }

    public int readTE(int max) {
        if (max > 1)
            return readUE();
        return (read1Bit() ^ 0xFFFFFFFF) & 0x1;
    }

    public int readAEI()
    {
        throw new UnsupportedOperationException("Stan");
    }

    public int readME(String string) {
        return readUE(string);
    }

    public Object readCE(BTree bt, String message) {
        while (true) {
            int bit = read1Bit();
            bt = bt.down(bit);
            if (bt is null) {
                throw new RuntimeException("Illegal code");
            }
            Object i = bt.getValue();
            if (i !is null) {
                trace(message, i.toString());
                return i;
            }
        }
    }

    public int readZeroBitCount(String message) {
        int count = 0;
        while (read1Bit() == 0) {
            count++;
        }
        trace(message, String.valueOf(count));

        return count;
    }

    public void readTrailingBits() {
        read1Bit();
        readRemainingByte();
    }

    private void trace(String message, String val) {
        StringBuilder traceBuilder = new StringBuilder();

        String pos = String.valueOf(bitsRead - debugBits.length());
        int spaces = 8 - pos.length();

        traceBuilder.append((new StringBuilder()).append("@").append(pos).toString());

        for (int i = 0; i < spaces; i++) {
            traceBuilder.append(' ');
        }
        traceBuilder.append(message);
        spaces = 100 - traceBuilder.length() - debugBits.length();
        for (int i = 0; i < spaces; i++)
            traceBuilder.append(' ');
        traceBuilder.append(debugBits);
        traceBuilder.append((new StringBuilder()).append(" (").append(val).append(")").toString());
        debugBits.clear();
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.h264.CAVLCReader
* JD-Core Version:    0.6.2
*/