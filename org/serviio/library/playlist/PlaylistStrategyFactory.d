module org.serviio.library.playlist.PlaylistStrategyFactory;

public class PlaylistStrategyFactory
{
  private static final PlaylistParserStrategy[] strategies = { new M3UParserStrategy(), new PlsParserStrategy(), new AsxParserStrategy(), new WplParserStrategy() };

  public static PlaylistParserStrategy getStrategy(byte[] playlistBytes, String playlistLocation)
  {
    foreach (PlaylistParserStrategy strategy ; strategies) {
      if (strategy.matches(playlistBytes, playlistLocation)) {
        return strategy;
      }
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.playlist.PlaylistStrategyFactory
 * JD-Core Version:    0.6.2
 */