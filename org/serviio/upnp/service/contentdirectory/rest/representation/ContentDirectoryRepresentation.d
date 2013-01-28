module org.serviio.upnp.service.contentdirectory.rest.representation.ContentDirectoryRepresentation;

import com.thoughtworks.xstream.annotations.XStreamAsAttribute;
import java.lang.Integer;
import java.util.List;
import org.serviio.upnp.service.contentdirectory.rest.representation.DirectoryObjectRepresentation;

public class ContentDirectoryRepresentation
{
    private List!(DirectoryObjectRepresentation) objects;

    //@XStreamAsAttribute
    private Integer returnedSize;

    //@XStreamAsAttribute
    private Integer totalMatched;

    public List!(DirectoryObjectRepresentation) getObjects()
    {
        return objects;
    }

    public void setObjects(List!(DirectoryObjectRepresentation) objects) {
        this.objects = objects;
    }

    public Integer getReturnedSize() {
        return returnedSize;
    }

    public void setReturnedSize(Integer returnedSize) {
        this.returnedSize = returnedSize;
    }

    public Integer getTotalMatched() {
        return totalMatched;
    }

    public void setTotalMatched(Integer totalMatched) {
        this.totalMatched = totalMatched;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.service.contentdirectory.rest.representation.ContentDirectoryRepresentation
* JD-Core Version:    0.6.2
*/