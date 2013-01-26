module org.serviio.ui.representation.OnlinePlugin;

import java.lang.Comparable;
import java.lang.String;

public class OnlinePlugin : Comparable!(OnlinePlugin)
{
    private String name;
    private int ver;

    public this()
    {
    }

    public this(String name, int ver)
    {
        this.name = name;
        this.ver = ver;
    }

    public String getName()
    {
        return name;
    }

    public int getVersion() {
        return ver;
    }

    public int compareTo(OnlinePlugin o)
    {
        return getName().compareTo(o.getName());
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.ui.representation.OnlinePlugin
* JD-Core Version:    0.6.2
*/