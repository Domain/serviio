module org.serviio.library.online.feed.GameTrailersExFeedEntryParser;

import com.sun.syndication.feed.synd.SyndEntry;
import java.net.MalformedURLException;
import java.net.URL;
import org.serviio.library.local.metadata.ImageDescriptor;
import org.serviio.library.online.feed.modules.gametrailers.GameTrailersExModule;
import org.serviio.library.online.metadata.FeedItem;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GameTrailersExFeedEntryParser
  : FeedEntryParser
{
  private static final Logger log = LoggerFactory.getLogger!(GameTrailersExFeedEntryParser);

  public void parseFeedEntry(SyndEntry entry, FeedItem item)
  {
    GameTrailersExModule mod = cast(GameTrailersExModule)entry.getModule("http://www.gametrailers.com/rssexplained.php");
    if (mod !is null)
    {
      if (mod.getThumbnailUrl() !is null) {
        try {
          ImageDescriptor thumbnail = new ImageDescriptor(new URL(mod.getThumbnailUrl()));
          item.setThumbnail(thumbnail);
        } catch (MalformedURLException e) {
          log.debug_(String.format("Invalid thumbnail URL: %s. Message: %s", cast(Object[])[ mod.getThumbnailUrl(), e.getMessage() ]));
        }
      }

      if (mod.getFileSize() !is null)
        item.getTechnicalMD().setFileSize(mod.getFileSize());
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.feed.GameTrailersExFeedEntryParser
 * JD-Core Version:    0.6.2
 */