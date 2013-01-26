module org.serviio.ui.resources.ConsoleSettingsResource;

import org.restlet.resource.Get;
import org.restlet.resource.Put;
import org.serviio.restlet.ResultRepresentation;
import org.serviio.ui.representation.ConsoleSettingsRepresentation;

public abstract interface ConsoleSettingsResource
{
    //@Get("xml|json")
    public abstract ConsoleSettingsRepresentation load();

    //@Put("xml|json")
    public abstract ResultRepresentation save(ConsoleSettingsRepresentation paramConsoleSettingsRepresentation);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.resources.ConsoleSettingsResource
 * JD-Core Version:    0.6.2
 */