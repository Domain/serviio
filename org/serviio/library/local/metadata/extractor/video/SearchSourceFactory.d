module org.serviio.library.local.metadata.extractor.video.SearchSourceFactory;

public class SearchSourceFactory
{
  public static SearchSourceAdaptor getSearchSourceAdaptor(VideoDescription.VideoType videoType)
  {
    if (videoType == VideoDescription.VideoType.EPISODE)
      return new TheTVDBSourceAdaptor();
    if (videoType == VideoDescription.VideoType.FILM) {
      return new TheMovieDBSourceAdaptor();
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.video.SearchSourceFactory
 * JD-Core Version:    0.6.2
 */