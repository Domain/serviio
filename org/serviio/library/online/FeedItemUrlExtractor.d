module org.serviio.library.online.FeedItemUrlExtractor;

import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import org.serviio.config.Configuration;
import org.serviio.library.online.metadata.FeedItem;

public abstract class FeedItemUrlExtractor : AbstractUrlExtractor
{
  public final ContentURLContainer extractUrl(FeedItem feedItem)
  {
    log("Starting extraction of url for item: " + feedItem.getTitle());

    final Map!(String, URL) links = new HashMap!(String, URL)(feedItem.getLinks());
    if (feedItem.getThumbnail() !is null) {
      links.put("thumbnail", feedItem.getThumbnail().getImageUrl());
    }

    ContentURLContainer result = cast(ContentURLContainer)(new class() PluginExecutionProcessor!(Object)
    {
      protected ContentURLContainer executePluginMethod() {
        return extractUrl(links, Configuration.getOnlineFeedPreferredQuality());
      }
    })
    .execute(30000);

    bool valid = validate(result);

    if ((result !is null) && (valid)) {
      log("Finished extraction of url: " + result.toString());
      return result;
    }
    log("Finished extraction of url: no result");
    return null;
  }

  protected abstract ContentURLContainer extractUrl(Map!(String, URL) paramMap, PreferredQuality paramPreferredQuality);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.FeedItemUrlExtractor
 * JD-Core Version:    0.6.2
 */