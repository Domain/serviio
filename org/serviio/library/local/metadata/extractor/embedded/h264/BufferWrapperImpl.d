module org.serviio.library.local.metadata.extractor.embedded.h264.BufferWrapperImpl;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel.MapMode;
import java.util.ArrayList;
import java.util.List;
import org.serviio.library.local.metadata.extractor.embedded.h264.AbstractBufferWrapper;
import org.serviio.library.local.metadata.extractor.embedded.h264.BufferWrapper;

public class BufferWrapperImpl : AbstractBufferWrapper
{
    ByteBuffer[] parents;
    int activeParent = 0;

    public this(byte[] bytes)
    {
        this(ByteBuffer.wrap(bytes));
    }

    public this(ByteBuffer parent) {
        parents = cast(ByteBuffer[])[ parent ];
    }

    public this(ByteBuffer[] parents) {
        this.parents = parents;
    }

    public this(List!(ByteBuffer) parents) {
        this.parents = (cast(ByteBuffer[])parents.toArray(new ByteBuffer[parents.size()]));
    }

    public this(File file) {
        long filelength = file.length();
        int sliceSize = 134217728;

        RandomAccessFile raf = new RandomAccessFile(file, "r");
        ArrayList!(ByteBuffer) buffers = new ArrayList!(ByteBuffer)();
        long i = 0L;
        while (i < filelength) {
            if (filelength - i > sliceSize) {
                ByteBuffer bb;
                try {
                    bb = raf.getChannel().map(MapMode.READ_ONLY, i, sliceSize);
                }
                catch (IOException e1) {
                    try {
                        bb = raf.getChannel().map(MapMode.READ_ONLY, i, sliceSize);
                    }
                    catch (IOException e2) {
                        try {
                            bb = raf.getChannel().map(MapMode.READ_ONLY, i, sliceSize);
                        } catch (IOException e3) {
                            bb = raf.getChannel().map(MapMode.READ_ONLY, i, sliceSize);
                        }
                    }
                }
                buffers.add(bb);
                i += sliceSize;
            } else {
                buffers.add(raf.getChannel().map(MapMode.READ_ONLY, i, filelength - i).slice());
                i += filelength - i;
            }
        }
        parents = (cast(ByteBuffer[])buffers.toArray(new ByteBuffer[buffers.size()]));
        raf.close();
    }

    public long position() {
        if (activeParent >= 0) {
            long pos = 0L;
            for (int i = 0; i < activeParent; i++) {
                pos += parents[i].limit();
            }
            pos += parents[activeParent].position();
            return pos;
        }
        return size();
    }

    public void position(long position)
    {
        if (position == size()) {
            activeParent = -1;
        } else {
            int current = 0;
            while (position >= parents[current].limit()) {
                position -= parents[(current++)].limit();
            }
            parents[current].position(cast(int)position);
            activeParent = current;
        }
    }

    public long size() {
        long size = 0L;
        foreach (ByteBuffer parent ; parents) {
            size += parent.limit();
        }
        return size;
    }

    public long remaining()
    {
        if (activeParent == -1) {
            return 0L;
        }
        long remaining = 0L;
        for (int i = activeParent; i < parents.length; i++) {
            remaining += parents[i].remaining();
        }

        return remaining;
    }

    public int read()
    {
        if (parents[activeParent].remaining() == 0) {
            if (parents.length > activeParent + 1) {
                activeParent += 1;
                parents[activeParent].rewind();
                return read();
            }
            return -1;
        }

        int b = parents[activeParent].get();
        return b < 0 ? b + 256 : b;
    }

    public int read(byte[] b) {
        return read(b, 0, b.length);
    }

    public int read(byte[] b, int off, int len) {
        if (parents[activeParent].remaining() >= len) {
            parents[activeParent].get(b, off, len);
            return len;
        }
        int curRemaining = parents[activeParent].remaining();
        parents[activeParent].get(b, off, curRemaining);
        activeParent += 1;
        parents[activeParent].rewind();
        return curRemaining + read(b, off + curRemaining, len - curRemaining);
    }

    public BufferWrapper getSegment(long startPos, long length)
    {
        long savePos = position();
        ArrayList!(ByteBuffer) segments = new ArrayList!(ByteBuffer)();
        position(startPos);
        while (length > 0L) {
            ByteBuffer currentSlice = parents[activeParent].slice();
            if (currentSlice.remaining() >= length) {
                currentSlice.limit(cast(int)length);
                length -= length;
            }
            else {
                length -= currentSlice.remaining();
                parents[(++activeParent)].rewind();
            }
            segments.add(currentSlice);
        }
        position(savePos);
        return new BufferWrapperImpl(cast(ByteBuffer[])segments.toArray(new ByteBuffer[segments.size()]));
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.h264.BufferWrapperImpl
* JD-Core Version:    0.6.2
*/