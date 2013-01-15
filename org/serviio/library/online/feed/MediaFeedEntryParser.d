module org.serviio.library.online.feed.MediaFeedEntryParser;

import com.sun.syndication.feed.modules.mediarss.MediaEntryModule;
import com.sun.syndication.feed.modules.mediarss.types.MediaContent;
import com.sun.syndication.feed.modules.mediarss.types.MediaGroup;
import com.sun.syndication.feed.modules.mediarss.types.Metadata;
import com.sun.syndication.feed.modules.mediarss.types.Thumbnail;
import com.sun.syndication.feed.modules.mediarss.types.UrlReference;
import com.sun.syndication.feed.synd.SyndEntry;
import java.net.MalformedURLException;
import java.util.Arrays;
import java.util.Comparator;
import org.serviio.config.Configuration;
import org.serviio.library.local.metadata.ImageDescriptor;
import org.serviio.library.online.PreferredQuality;
import org.serviio.library.online.metadata.FeedItem;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MediaFeedEntryParser
  : FeedEntryParser
{
  private static final Logger log = LoggerFactory.getLogger!(MediaFeedEntryParser)();

  public void parseFeedEntry(SyndEntry entry, FeedItem item)
  {
    MediaEntryModule mod = cast(MediaEntryModule)entry.getModule("http://search.yahoo.com/mrss/");
    if (mod !is null) {
      Metadata md = findMetadata(mod);
      MediaContent con = findContents(mod);

      if ((ObjectValidator.isNotEmpty(md.getTitle())) && (ObjectValidator.isEmpty(item.getTitle())))
      {
        item.setTitle(StringUtils.trim(md.getTitle()));
      }

      if ((md.getCredits() !is null) && (md.getCredits().length > 0) && (ObjectValidator.isEmpty(item.getAuthor()))) {
        item.setAuthor(md.getCredits()[0].getName());
      }

      setThumbnail(con, md, item);
      setContentData(con, item);
    }
  }

  private Metadata findMetadata(MediaEntryModule mod)
  {
    if ((mod.getMediaGroups() !is null) && (mod.getMediaGroups().length > 0)) {
      return mod.getMediaGroups()[0].getMetadata();
    }
    return mod.getMetadata();
  }

  private MediaContent findContents(MediaEntryModule mod) {
    MediaContent[] availableContents = null;
    if ((mod.getMediaGroups() !is null) && (mod.getMediaGroups().length > 0)) {
      MediaGroup mg = mod.getMediaGroups()[0];
      if ((mg.getContents() !is null) && (mg.getContents().length > 0)) {
        if (mg.getDefaultContentIndex() !is null) {
          return mg.getContents()[mg.getDefaultContentIndex().intValue()];
        }
        availableContents = mg.getContents();
      }
    } else if ((mod.getMediaContents() !is null) && (mod.getMediaContents().length > 0)) {
      availableContents = mod.getMediaContents();
    }

    if (availableContents !is null) {
      MediaContent content = findDefaultMediaContent(availableContents);
      if (content is null) {
        MediaContent[] sortedContent = cast(MediaContent[])availableContents.clone();
        Arrays.sort(sortedContent, new MediaContentComparator());

        PreferredQuality prefQuality = Configuration.getOnlineFeedPreferredQuality();
        if (prefQuality == PreferredQuality.HIGH)
          return sortedContent[(sortedContent.length - 1)];
        if (prefQuality == PreferredQuality.LOW) {
          return sortedContent[0];
        }
        return sortedContent[(sortedContent.length / 2)];
      }

      return content;
    }
    return null;
  }

  private MediaContent findDefaultMediaContent(MediaContent[] contents)
  {
    foreach (MediaContent con ; contents) {
      if (con.isDefaultContent()) {
        return con;
      }
    }
    return null;
  }

  private void setThumbnail(MediaContent con, Metadata md, FeedItem item) {
    Thumbnail[] availableThumbnails = null;
    if ((md.getThumbnail() !is null) && (md.getThumbnail().length > 0))
      availableThumbnails = md.getThumbnail();
    else if ((con !is null) && (con.getMetadata() !is null)) {
      availableThumbnails = con.getMetadata().getThumbnail();
    }
    if ((availableThumbnails !is null) && (availableThumbnails.length > 0)) {
      Thumbnail selectedThumbnail = availableThumbnails[0];
      foreach (Thumbnail t ; availableThumbnails)
        if ((t.getWidth() !is null) && (t.getHeight() !is null) && (t.getWidth().intValue() <= 160) && (t.getHeight().intValue() <= 160))
        {
          selectedThumbnail = t;
        }
      try
      {
        ImageDescriptor thumbnail = new ImageDescriptor(selectedThumbnail.getUrl().toURL());
        thumbnail.setWidth(selectedThumbnail.getWidth());
        thumbnail.setHeight(selectedThumbnail.getHeight());
        item.setThumbnail(thumbnail);
      } catch (MalformedURLException e) {
        log.warn(String.format("Malformed url of a media feed thumbnail (%s), skipping this thumbnail", cast(Object[])[ selectedThumbnail.getUrl().toString() ]));
      }
    }
  }

  private void setContentData(MediaContent con, FeedItem item)
  {
    if ((con !is null) && (con.getReference() !is null) && (( cast(UrlReference)con.getReference() !is null ))) {
      String contentUrl = (cast(UrlReference)con.getReference()).getUrl().toString();
      if ((item.getContentUrl() is null) || (item.getContentUrl().equals(contentUrl)))
      {
        if (item.getType() is null) {
          item.setMediaType(con.getType(), contentUrl);
        }
        item.setContentUrl(contentUrl);
      }
    }
  }

  private class MediaContentComparator
    : Comparator!(MediaContent)
  {
    private this()
    {
    }

    public int compare(MediaContent o1, MediaContent o2)
    {
      if ((o1.getBitrate() !is null) && (o2.getBitrate() !is null))
        return o1.getBitrate().compareTo(o2.getBitrate());
      if (o1.getBitrate() is null) {
        return -1;
      }
      return 1;
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.feed.MediaFeedEntryParser
 * JD-Core Version:    0.6.2
 */