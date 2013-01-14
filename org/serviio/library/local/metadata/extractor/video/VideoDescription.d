module org.serviio.library.local.metadata.extractor.video.VideoDescription;

import java.lang.String;
import java.lang.Integer;
import java.util.Arrays;

public class VideoDescription
{
  private VideoType type;
  private bool searchRecommended;
  private String[] names;
  private Integer season;
  private Integer episode;
  private Integer year;

  public this(VideoType type, bool searchRecommended, String[] filmNames, Integer year)
  {
    this.type = type;
    this.searchRecommended = searchRecommended;
    names = filmNames;
    this.year = year;
  }

  public this(VideoType type, bool searchRecommended, String[] seriesNames, Integer season, Integer episode, Integer year)
  {
    this.type = type;
    this.searchRecommended = searchRecommended;
    names = seriesNames;
    this.season = season;
    this.episode = episode;
    this.year = year;
  }

  public this(VideoType type, bool searchRecommended)
  {
    this.type = type;
    this.searchRecommended = searchRecommended;
  }

  public VideoType getType()
  {
    return type;
  }

  public bool isSearchRecommended() {
    return searchRecommended;
  }

  public String[] getNames() {
    return names;
  }

  public Integer getSeason() {
    return season;
  }

  public Integer getEpisode() {
    return episode;
  }

  public Integer getYear() {
    return year;
  }

  override public String toString()
  {
    StringBuilder builder = new StringBuilder();
    builder.append("VideoDescription [type=").append(type).append(", names=").append(Arrays.toString(names)).append(", year=").append(year).append(", season=").append(season).append(", episode=").append(episode).append("]");

    return builder.toString();
  }

  public static enum VideoType
  {
    FILM, 

    EPISODE, 

    SPECIAL
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.video.VideoDescription
 * JD-Core Version:    0.6.2
 */