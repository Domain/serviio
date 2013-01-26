module org.serviio.library.local.metadata.extractor.embedded.h264.BTree;

import java.lang.String;

public class BTree
{
    private BTree zero;
    private BTree one;
    private Object value;

    public void addString(String path, Object value)
    {
        if (path.length() == 0) {
            this.value = value;
            return;
        }
        char charAt = path.charAt(0);
        BTree branch;
        if (charAt == '0') {
            if (zero is null)
                zero = new BTree();
            branch = zero;
        } else {
            if (one is null)
                one = new BTree();
            branch = one;
        }
        branch.addString(path.substring(1), value);
    }

    public BTree down(int b) {
        if (b == 0) {
            return zero;
        }
        return one;
    }

    public Object getValue() {
        return value;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.h264.BTree
* JD-Core Version:    0.6.2
*/