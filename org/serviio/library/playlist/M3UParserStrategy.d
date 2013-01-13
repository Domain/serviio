module org.serviio.library.playlist.M3UParserStrategy;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import org.apache.commons.io.FilenameUtils;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;

public class M3UParserStrategy : AbstractPlaylistParserStrategy
{
  public ParsedPlaylist parsePlaylist(byte[] playlist, String playlistLocation)
  {
    String content = readPlaylistContent(playlist);
    BufferedReader reader = new BufferedReader(new StringReader(content));
    String inputLine = null;
    ParsedPlaylist pl = new ParsedPlaylist(FilenameUtils.getBaseName(playlistLocation));
    try {
      while ((inputLine = reader.readLine()) !is null) {
        if ((ObjectValidator.isNotEmpty(inputLine)) && (!inputLine.startsWith("#"))) {
          pl.addItem(getAbsoluteFilePath(inputLine.trim(), playlistLocation));
        }
      }
      return pl;
    } catch (IOException e) {
      throw new CannotParsePlaylistException(PlaylistType.M3U, playlistLocation, e.getMessage());
    }
  }

  public bool matches(byte[] playlist, String playlistLocation)
  {
    if (FilenameUtils.isExtension(StringUtils.localeSafeToLowercase(playlistLocation), PlaylistType.M3U.supportedFileExtensions()))
    {
      return true;
    }

    String content = readPlaylistContent(playlist);
    if (content !is null) {
      BufferedReader reader = new BufferedReader(new StringReader(content));
      try {
        String firstLine = reader.readLine();
        return firstLine.startsWith("#EXTM3U");
      } catch (IOException e) {
        return false;
      }
    }
    return false;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.playlist.M3UParserStrategy
 * JD-Core Version:    0.6.2
 */