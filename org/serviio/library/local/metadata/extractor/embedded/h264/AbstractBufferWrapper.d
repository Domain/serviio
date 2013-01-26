module org.serviio.library.local.metadata.extractor.embedded.h264.AbstractBufferWrapper;

import java.lang.String;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import org.serviio.library.local.metadata.extractor.embedded.h264.BufferWrapper;

public abstract class AbstractBufferWrapper : BufferWrapper
{
    public int readBitsRemaining;
    private byte readBitsBuffer;

    public long readUInt64()
    {
        long result = 0L;

        result += (readUInt32() << 32);
        if (result < 0L) {
            throw new RuntimeException("I don't know how to deal with UInt64! long is not sufficient and I don't want to use BigInt");
        }

        result += readUInt32();

        return result;
    }

    public long readUInt32() {
        long result = 0L;
        result += (readUInt16() << 16);
        result += readUInt16();
        return result;
    }

    public int readInt32() {
        int ch1 = readUInt8();
        int ch2 = readUInt8();
        int ch3 = readUInt8();
        int ch4 = readUInt8();
        return (ch1 << 24) + (ch2 << 16) + (ch3 << 8) + (ch4 << 0);
    }

    public int readUInt24()
    {
        int result = 0;
        result += (readUInt16() << 8);
        result += readUInt8();
        return result;
    }

    public int readUInt16() {
        int result = 0;
        result += (readUInt8() << 8);
        result += readUInt8();
        return result;
    }

    public int readUInt8() {
        byte b = readByte();
        return b < 0 ? b + 256 : b;
    }

    public byte readByte() {
        if (readBitsRemaining != 0) {}
        int b = read();
        if (b == -1) {
            throw new RuntimeException("Read beyond buffer's end");
        }
        return cast(byte)(b >= 128 ? b - 256 : b);
    }

    public String readIso639()
    {
        int bits = readUInt16();
        StringBuilder result = new StringBuilder();
        for (int i = 0; i < 3; i++) {
            int c = bits >> (2 - i) * 5 & 0x1F;
            result.append(cast(char)(c + 96));
        }
        return result.toString();
    }

    public String readString()
    {
        ByteArrayOutputStream out_ = new ByteArrayOutputStream();
        int read;
        while ((read = readByte()) != 0)
            out_.write(read);
        try
        {
            return out_.toString("UTF-8"); } catch (UnsupportedEncodingException e) {
            }
            throw new Error("JVM doesn't support UTF-8");
    }

    public long readUInt32BE()
    {
        long result = 0L;
        result += readUInt16BE();
        result += (readUInt16BE() << 16);
        return result;
    }

    public int readUInt16BE() {
        int result = 0;
        result += readUInt8();
        result += (readUInt8() << 8);
        return result;
    }

    public int readBits(int i)
    {
        if (i > 31)
        {
            throw new IllegalArgumentException("cannot readByte more than 31 bits");
        }

        int ret = 0;
        while (i > 8) {
            int moved = parse8(8) << i - 8;
            ret |= moved;
            i -= 8;
        }
        return ret | parse8(i);
    }

    private int parse8(int i) {
        if (readBitsRemaining == 0) {
            readBitsBuffer = readByte();
            readBitsRemaining = 8;
        }

        if (i > readBitsRemaining) {
            int resultRemaining = i - readBitsRemaining;
            int buffer = (readBitsBuffer & cast(int)(Math.pow(2.0, readBitsRemaining) - 1.0)) << resultRemaining;

            readBitsBuffer = readByte();
            readBitsRemaining = (8 - resultRemaining);
            int movedAndMasked = readBitsBuffer >>> readBitsRemaining & cast(int)(Math.pow(2.0, resultRemaining) - 1.0);

            return buffer | movedAndMasked;
        }
        readBitsRemaining -= i;

        return readBitsBuffer >>> readBitsRemaining & cast(int)(Math.pow(2.0, i) - 1.0);
    }

    public int getReadBitsRemaining()
    {
        return readBitsRemaining;
    }

    public double readFixedPoint1616() {
        byte[] bytes = read(4);
        int result = 0;
        result |= bytes[0] << 24 & 0xFF000000;
        result |= bytes[1] << 16 & 0xFF0000;
        result |= bytes[2] << 8 & 0xFF00;
        result |= bytes[3] & 0xFF;
        return result / 65536.0;
    }

    public float readFixedPoint88()
    {
        byte[] bytes = read(2);
        short result = 0;
        result = cast(short)(result | bytes[0] << 8 & 0xFF00);
        result = cast(short)(result | bytes[1] & 0xFF);
        return result / 256.0F;
    }

    public String readString(int length) {
        byte[] buffer = new byte[length];
        read(buffer);
        try {
            return new String(buffer, "UTF-8"); } catch (UnsupportedEncodingException e) {
            }
            throw new Error("JVM doesn't support UTF-8");
    }

    public byte[] read(int byteCount)
    {
        byte[] result = new byte[byteCount];
        read(result);
        return result;
    }

    public long skip(long n)
    {
        position(position() + n);
        return n;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.h264.AbstractBufferWrapper
* JD-Core Version:    0.6.2
*/