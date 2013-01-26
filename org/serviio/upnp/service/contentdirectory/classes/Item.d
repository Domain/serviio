module org.serviio.upnp.service.contentdirectory.classes.Item;

import java.lang.String;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObject;
import org.serviio.upnp.service.contentdirectory.classes.Resource;

public abstract class Item : DirectoryObject
{
    protected String refID;
    protected Resource icon;
    private String dcmInfo;
    protected Resource albumArtURIResource;

    public this(String id, String title)
    {
        super(id, title);
    }

    public String getRefID()
    {
        return refID;
    }

    public void setRefID(String refID) {
        this.refID = refID;
    }

    public Resource getIcon() {
        return icon;
    }

    public void setIcon(Resource icon) {
        this.icon = icon;
    }

    public String getDcmInfo() {
        return dcmInfo;
    }

    public void setDcmInfo(String dcmInfo) {
        this.dcmInfo = dcmInfo;
    }

    public Resource getAlbumArtURIResource() {
        return albumArtURIResource;
    }

    public void setAlbumArtURIResource(Resource albumArtURI) {
        albumArtURIResource = albumArtURI;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.Item
* JD-Core Version:    0.6.2
*/