module org.serviio.library.local.metadata.extractor.embedded.h264.BitstreamReader;

import java.io.IOException;

public class BitstreamReader
{
  private BufferWrapper is_;
  private int curByte;
  private int nextByte;
  int nBit;
  protected static int bitsRead;
  protected CharCache debugBits = new CharCache(50);

  public this(BufferWrapper is_) {
    this.is_ = is_;
    curByte = is_.read();
    nextByte = is_.read();
  }

  public int read1Bit()
  {
    if (nBit == 8) {
      advance();
      if (curByte == -1) {
        return -1;
      }
    }
    int res = curByte >> 7 - nBit & 0x1;
    nBit += 1;

    debugBits.append(res == 0 ? '0' : '1');
    bitsRead += 1;

    return res;
  }

  public long readNBit(int n)
  {
    if (n > 64) {
      throw new IllegalArgumentException("Can not readByte more then 64 bit");
    }
    long val = 0L;

    for (int i = 0; i < n; i++) {
      val <<= 1;
      val |= read1Bit();
    }

    return val;
  }

  private void advance() {
    curByte = nextByte;
    nextByte = is_.read();
    nBit = 0;
  }

  public int readByte()
  {
    if (nBit > 0) {
      advance();
    }

    int res = curByte;

    advance();

    return res;
  }

  public bool moreRBSPData()
  {
    if (nBit == 8) {
      advance();
    }
    int tail = 1 << 8 - nBit - 1;
    int mask = (tail << 1) - 1;
    bool hasTail = (curByte & mask) == tail;

    return (curByte != -1) && ((nextByte != -1) || (!hasTail));
  }

  public long getBitPosition() {
    return bitsRead * 8 + nBit % 8;
  }

  public long readRemainingByte()
  {
    return readNBit(8 - nBit);
  }

  public int peakNextBits(int n)
  {
    if (n > 8)
      throw new IllegalArgumentException("N should be less then 8");
    if (nBit == 8) {
      advance();
      if (curByte == -1) {
        return -1;
      }
    }
    int[] bits = new int[16 - nBit];

    int cnt = 0;
    for (int i = nBit; i < 8; i++) {
      bits[(cnt++)] = (curByte >> 7 - i & 0x1);
    }

    for (int i = 0; i < 8; i++) {
      bits[(cnt++)] = (nextByte >> 7 - i & 0x1);
    }

    int result = 0;
    for (int i = 0; i < n; i++) {
      result <<= 1;
      result |= bits[i];
    }

    return result;
  }

  public bool isByteAligned()
  {
    return nBit % 8 == 0;
  }

  public void close()
  {
  }

  public int getCurBit()
  {
    return nBit;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.h264.BitstreamReader
 * JD-Core Version:    0.6.2
 */