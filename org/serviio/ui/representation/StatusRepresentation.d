module org.serviio.ui.representation.StatusRepresentation;

import java.lang.String;
import java.util.List;
import org.serviio.UPnPServerStatus;
import org.serviio.ui.representation.RendererRepresentation;

public class StatusRepresentation
{
    private UPnPServerStatus serverStatus;
    private String boundIPAddress;
    private List!(RendererRepresentation) renderers;

    public UPnPServerStatus getServerStatus()
    {
        return serverStatus;
    }
    public void setServerStatus(UPnPServerStatus uPnPServerStatus) {
        serverStatus = uPnPServerStatus;
    }
    public String getBoundIPAddress() {
        return boundIPAddress;
    }
    public void setBoundIPAddress(String boundIPAddress) {
        this.boundIPAddress = boundIPAddress;
    }
    public List!(RendererRepresentation) getRenderers() {
        return renderers;
    }
    public void setRenderers(List!(RendererRepresentation) renderers) {
        this.renderers = renderers;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.ui.representation.StatusRepresentation
* JD-Core Version:    0.6.2
*/