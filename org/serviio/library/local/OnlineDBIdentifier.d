module org.serviio.library.local.OnlineDBIdentifier;

import java.util.Map;

public class OnlineDBIdentifier
{
	enum OnlineDBIdentifierEnum
	{
		IMDB, TVDB, TMDB
	}

	OnlineDBIdentifierEnum onlineDBIdentifier;
	alias onlineDBIdentifier this;

  private static EnumMapConverter!(OnlineDBIdentifier) converter = new class() EnumMapConverter!(OnlineDBIdentifier)
  {
    protected OnlineDBIdentifier enumValue(String name) {
      return OnlineDBIdentifier.valueOf(name);
    }
  };

  public static Map!(OnlineDBIdentifier, String) parseFromString(String identifiersCSV)
  {
    return converter.convert(identifiersCSV);
  }

  public static String parseToString(Map!(OnlineDBIdentifier, String) identifiers) {
    return converter.parseToString(identifiers);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.OnlineDBIdentifier
 * JD-Core Version:    0.6.2
 */