module org.serviio.library.local.metadata.extractor.embedded.h264.BufferWrapper;

import java.io.IOException;

public abstract interface BufferWrapper
{
  public abstract int readUInt8();

  public abstract int readUInt24();

  public abstract String readIso639();

  public abstract String readString();

  public abstract long position();

  public abstract long remaining();

  public abstract String readString(int paramInt);

  public abstract long skip(long paramLong);

  public abstract void position(long paramLong);

  public abstract int read(byte[] paramArrayOfByte);

  public abstract BufferWrapper getSegment(long paramLong1, long paramLong2);

  public abstract long readUInt32();

  public abstract int readInt32();

  public abstract long readUInt64();

  public abstract byte readByte();

  public abstract int read();

  public abstract int readUInt16();

  public abstract long size();

  public abstract byte[] read(int paramInt);

  public abstract double readFixedPoint1616();

  public abstract float readFixedPoint88();

  public abstract int readUInt16BE();

  public abstract long readUInt32BE();

  public abstract int readBits(int paramInt);

  public abstract int getReadBitsRemaining();
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.h264.BufferWrapper
 * JD-Core Version:    0.6.2
 */