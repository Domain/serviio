module org.serviio.ui.representation.OnlinePluginsRepresentation;

import com.thoughtworks.xstream.annotations.XStreamImplicit;
import java.util.Set;
import java.util.TreeSet;
import org.serviio.ui.representation.OnlinePlugin;

public class OnlinePluginsRepresentation
{
    //@XStreamImplicit
    private Set!(OnlinePlugin) plugins = new TreeSet!(OnlinePlugin)();

    public Set!(OnlinePlugin) getPlugins()
    {
        return plugins;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.ui.representation.OnlinePluginsRepresentation
* JD-Core Version:    0.6.2
*/