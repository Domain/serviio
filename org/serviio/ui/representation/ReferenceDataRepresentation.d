module org.serviio.ui.representation.ReferenceDataRepresentation;

import java.lang.String;
import java.util.ArrayList;
import java.util.List;
import org.serviio.ui.representation.DataValue;

public class ReferenceDataRepresentation
{
    private List!(DataValue) values = new ArrayList!(DataValue)();

    public this()
    {
    }

    public this(String name, String value)
    {
        addValue(name, value);
    }

    public void addValue(String name, String value)
    {
        values.add(new DataValue(name, value));
    }

    public List!(DataValue) getValues() {
        return values;
    }

    public void setValues(List!(DataValue) values) {
        this.values = values;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.ui.representation.ReferenceDataRepresentation
* JD-Core Version:    0.6.2
*/