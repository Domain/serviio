module org.serviio.library.playlist.PlaylistParser;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import org.serviio.util.FileUtils;
import org.serviio.util.HttpClient;
import org.serviio.util.HttpUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PlaylistParser
{
  private static final Logger log = LoggerFactory.getLogger!(PlaylistParser);
  private static final int ONLINE_MAX_BYTES_TO_READ = 102400;
  private static PlaylistParser instance;

  public static PlaylistParser getInstance()
  {
    if (instance is null) {
      instance = new PlaylistParser();
    }
    return instance;
  }

  public ParsedPlaylist parse(String playlistLocation)
  {
    log.debug_(String.format("Parsing playlist '%s'", cast(Object[])[ playlistLocation ]));
    byte[] playlistBytes = getPlaylistBytes(playlistLocation);
    PlaylistParserStrategy strategy = PlaylistStrategyFactory.getStrategy(playlistBytes, playlistLocation);
    if (strategy !is null) {
      log.debug_(String.format("Found a suitable playlist parser strategy: %s", cast(Object[])[ strategy.getClass().getSimpleName() ]));
      return strategy.parsePlaylist(playlistBytes, playlistLocation);
    }
    log.warn(String.format("Could not find a suitable playlist parser for file '%s', it is either not supported or the file is corrupted.", cast(Object[])[ playlistLocation ]));

    return null;
  }

  private byte[] getPlaylistBytes(String playlistLocation)
  {
    InputStream is_ = null;
    int maxLengthToRead = 2147483647;
    if (HttpUtils.isHttpUrl(playlistLocation)) {
      log.debug_("Reading playlist from URL");
      is_ = HttpClient.getStreamFromURL(playlistLocation);
      maxLengthToRead = ONLINE_MAX_BYTES_TO_READ;
    } else {
      log.debug_("Reading playlist from a local file");
      is_ = new FileInputStream(playlistLocation);
    }
    return FileUtils.readFileBytes(is_, maxLengthToRead);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.playlist.PlaylistParser
 * JD-Core Version:    0.6.2
 */