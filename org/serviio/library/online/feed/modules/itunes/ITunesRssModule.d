module org.serviio.library.online.feed.modules.itunes.ITunesRssModule;

import com.sun.syndication.feed.modules.Module;
import java.util.Date;
import java.util.List;

public abstract interface ITunesRssModule : Module
{
  public static final String URI = "http://itunes.apple.com/rss";

  public abstract String getName();

  public abstract void setName(String paramString);

  public abstract String getArtist();

  public abstract void setArtist(String paramString);

  public abstract List!(Image) getImages();

  public abstract void setImages(List!(Image) paramList);

  public abstract Date getReleaseDate();

  public abstract void setReleaseDate(Date paramDate);

  public abstract Integer getDuration();

  public abstract void setDuration(Integer paramInteger);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.feed.modules.itunes.ITunesRssModule
 * JD-Core Version:    0.6.2
 */