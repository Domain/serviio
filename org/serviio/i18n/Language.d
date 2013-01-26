module org.serviio.i18n.Language;

import java.lang.String;
import java.util.Locale;

public class Language
{
    private String code;
    private String name;

    public this(String code, String name)
    {
        this.code = code;
        this.name = name;
    }

    public String getCode() {
        return code;
    }

    public String getName() {
        return name;
    }

    public static Locale getLocale(String languageCode) {
        if (languageCode.contains("-")) {
            String[] locale = languageCode.split("-");
            return new Locale(locale[0], locale[1]);
        }
        return new Locale(languageCode);
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.i18n.Language
* JD-Core Version:    0.6.2
*/