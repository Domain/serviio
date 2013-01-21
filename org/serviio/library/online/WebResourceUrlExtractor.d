module org.serviio.library.online.WebResourceUrlExtractor;

import java.net.URL;
import org.serviio.config.Configuration;
import org.serviio.library.online.AbstractUrlExtractor;
import org.serviio.library.online.WebResourceContainer;
import org.serviio.library.online.ContentURLContainer;
import org.serviio.library.online.WebResourceItem;
import org.serviio.library.online.PreferredQuality;

public abstract class WebResourceUrlExtractor : AbstractUrlExtractor
{
    public final WebResourceContainer parseWebResource(final URL resourceUrl, final int maxItemsToRetrieve)
    {
        log("Starting parsing resource: " ~ resourceUrl);
        return cast(WebResourceContainer)(new class() PluginExecutionProcessor!(Object)
                                          {
                                              protected WebResourceContainer executePluginMethod() {
                                                  return extractItems(resourceUrl, maxItemsToRetrieve);
                                              }
                                          })
            .execute(30000);
    }

    public final ContentURLContainer extractItemUrl(const WebResourceItem item)
    {
        log("Starting extraction of url for item: " ~ item.getTitle());

        ContentURLContainer result = cast(ContentURLContainer)(new class() PluginExecutionProcessor!(Object)
                                                               {
                                                                   protected ContentURLContainer executePluginMethod() {
                                                                       return extractUrl(item, Configuration.getOnlineFeedPreferredQuality());
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

    protected abstract WebResourceContainer extractItems(URL paramURL, int paramInt);

    protected abstract ContentURLContainer extractUrl(WebResourceItem paramWebResourceItem, PreferredQuality paramPreferredQuality);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.online.WebResourceUrlExtractor
* JD-Core Version:    0.6.2
*/