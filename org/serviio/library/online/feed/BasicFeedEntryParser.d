module org.serviio.library.online.feed.BasicFeedEntryParser;

import com.sun.syndication.feed.synd.SyndEnclosure;
import com.sun.syndication.feed.synd.SyndEntry;
import com.sun.syndication.feed.synd.SyndLink;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;
import org.serviio.library.online.metadata.FeedItem;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class BasicFeedEntryParser
  : FeedEntryParser
{
  private static final Logger log = LoggerFactory.getLogger!(BasicFeedEntryParser);

  public void parseFeedEntry(SyndEntry entry, FeedItem item)
  {
    item.setAuthor(entry.getAuthor());
    item.setDate(entry.getPublishedDate());
    item.setTitle(StringUtils.trim(entry.getTitle()));
    setEnclosureInfo(entry, item);
    setLinks(entry, item);
  }

  private void setEnclosureInfo(SyndEntry entry, FeedItem item)
  {
    if ((entry.getEnclosures() !is null) && (entry.getEnclosures().size() > 0)) {
      bool validEnclosureFound = false;

      for (int i = 0; (i < entry.getEnclosures().size()) && (!validEnclosureFound); i++) {
        SyndEnclosure en = cast(SyndEnclosure)entry.getEnclosures().get(i);
        item.setContentUrl(en.getUrl());
        item.getTechnicalMD().setFileSize(en.getLength() != 0L ? Long.valueOf(en.getLength()) : null);
        item.setMediaType(en.getType(), item.getContentUrl());
        if (item.getType() !is null)
          validEnclosureFound = true;
      }
    }
  }

  private void setLinks(SyndEntry entry, FeedItem item)
  {
    
	List!(SyndLink) links = entry.getLinks();
    if ((links !is null) && (links.size() > 0))
      foreach (SyndLink link ; links) {
        String key = link.getRel();
        if (ObjectValidator.isEmpty(key)) {
          key = link.getType();
        }
        if (ObjectValidator.isEmpty(key)) {
          key = "default";
        }
        addLinkToItem(item, link.getHref(), key);
      }
    else if (ObjectValidator.isNotEmpty(entry.getLink()))
      addLinkToItem(item, entry.getLink(), "default");
  }

  private void addLinkToItem(FeedItem item, String url, String key)
  {
    try {
      item.getLinks().put(key, new URL(url));
    } catch (MalformedURLException e) {
      log.debug_(String.format("Invalid link href URL (%s), skipping", cast(Object[])[ url ]));
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.feed.BasicFeedEntryParser
 * JD-Core Version:    0.6.2
 */