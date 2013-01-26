module org.serviio.upnp.service.contentdirectory.classes.Person;

import java.lang.String;
import org.serviio.upnp.service.contentdirectory.classes.Container;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;

public class Person : Container
{
    protected String language;

    public this(String id, String title)
    {
        super(id, title);
    }

    override public ObjectClassType getObjectClass()
    {
        return ObjectClassType.PERSON;
    }

    public String getLanguage()
    {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.Person
* JD-Core Version:    0.6.2
*/