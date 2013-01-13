module org.serviio.library.local.metadata.extractor.video.MetadataLanguages;

import java.util.ArrayList;
import java.util.List;
import org.serviio.i18n.Language;

public class MetadataLanguages
{
  private static List!(Language) languages = new ArrayList!(Language)();
  public static final String DEFAULT_LANGUAGE_CODE = "en";

  public static List!(Language) getLanguages()
  {
    return languages;
  }

  static this()
  {
    languages.add(new Language("cs", "膶e拧tina"));
    languages.add(new Language("da", "Dansk"));
    languages.add(new Language("de", "Deutsch"));
    languages.add(new Language("el", "螘位位畏谓喂魏维"));
    languages.add(new Language("en", "English"));
    languages.add(new Language("es", "Espa帽ol"));
    languages.add(new Language("fi", "Suomeksi"));
    languages.add(new Language("fr", "Fran莽ais"));
    languages.add(new Language("he", "注讘专讬转"));
    languages.add(new Language("hr", "Hrvatski"));
    languages.add(new Language("hu", "Magyar"));
    languages.add(new Language("it", "Italiano"));
    languages.add(new Language("ja", "鏃ユ湰瑾�"));
    languages.add(new Language("ko", "頃滉淡鞏�"));
    languages.add(new Language("nl", "Nederlands"));
    languages.add(new Language("no", "Norsk"));
    languages.add(new Language("pl", "Polski"));
    languages.add(new Language("pt", "Portugu锚s"));
    languages.add(new Language("ru", "P褍褋褋泻懈泄 褟蟹褘泻"));
    languages.add(new Language("sl", "Sloven拧膷ina"));
    languages.add(new Language("sv", "Svenska"));
    languages.add(new Language("tr", "T眉rk莽e"));
    languages.add(new Language("zh", "涓枃"));
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.video.MetadataLanguages
 * JD-Core Version:    0.6.2
 */