module org.serviio.upnp.service.contentdirectory.definition.i18n.BrowsingCategoriesLanguages;

import java.lang.String;
import java.util.ArrayList;
import java.util.List;
import org.serviio.i18n.Language;

public class BrowsingCategoriesLanguages
{
    public static const String DEFAULT_LANGUAGE_CODE = "en";
    private static List!(Language) languages;

    public static List!(Language) getLanguages()
    {
        return languages;
    }

    static this()
    {
        languages = new ArrayList!(Language)();
        languages.add(new Language("ar", "丕賱毓乇亘賷丞"));
        languages.add(new Language("bg", "斜褗谢谐邪褉褋泻懈 械蟹懈泻"));
        languages.add(new Language("ca", "Catal脿"));
        languages.add(new Language("cs", "膶e拧tina"));
        languages.add(new Language("da", "Dansk"));
        languages.add(new Language("de", "Deutsch"));
        languages.add(new Language("en", "English"));
        languages.add(new Language("es", "Espa帽ol"));
        languages.add(new Language("es-419", "Espa帽ol (Latin America)"));
        languages.add(new Language("el", "蔚位位畏谓喂魏维"));
        languages.add(new Language("et-EE", "Eesti"));
        languages.add(new Language("fi", "Suomi"));
        languages.add(new Language("fr", "Fran莽ais"));
        languages.add(new Language("gsw-CH", "Schwyzerd眉tsch"));
        languages.add(new Language("he", "注讘专讬转"));
        languages.add(new Language("hr", "Hrvatski"));
        languages.add(new Language("hu", "Magyar"));
        languages.add(new Language("id", "Bahasa Indonesia"));
        languages.add(new Language("it", "Italiano"));
        languages.add(new Language("ja-JP", "鏃ユ湰瑾�"));
        languages.add(new Language("ko", "頃滉淡鞏�"));
        languages.add(new Language("lt", "Lietuvi懦 kalba"));
        languages.add(new Language("lv", "Latvie拧u valoda"));
        languages.add(new Language("nl", "Nederlands"));
        languages.add(new Language("nl-BE", "Nederlands (Belgium)"));
        languages.add(new Language("no", "Norsk"));
        languages.add(new Language("pl", "Polski"));
        languages.add(new Language("pt-PT", "Portugu锚s"));
        languages.add(new Language("pt-BR", "Portugu锚s (Brazil)"));
        languages.add(new Language("ro", "Rom芒n膬"));
        languages.add(new Language("ru", "P褍褋褋泻懈泄 褟蟹褘泻"));
        languages.add(new Language("sk", "Sloven膷ina"));
        languages.add(new Language("sl", "Sloven拧膷ina"));
        languages.add(new Language("sv", "Svenska"));
        languages.add(new Language("sr", "褋褉锌褋泻懈 褬械蟹懈泻"));
        languages.add(new Language("tr", "T眉rk莽e"));
        languages.add(new Language("uk", "褍泻褉邪褩薪褋褜泻邪 屑芯胁邪"));
        languages.add(new Language("zh-CN", "中文(Simplified)"));
        languages.add(new Language("zh-HK", "中文(Traditional)"));
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.service.contentdirectory.definition.i18n.BrowsingCategoriesLanguages
* JD-Core Version:    0.6.2
*/