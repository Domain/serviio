module org.serviio.library.playlist.PlsParserStrategy;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import org.apache.commons.io.FilenameUtils;
import org.serviio.util.ObjectValidator;

public class PlsParserStrategy : AbstractPlaylistParserStrategy
{
  public ParsedPlaylist parsePlaylist(byte[] playlist, String playlistLocation)
  {
    String content = readPlaylistContent(playlist);
    BufferedReader reader = new BufferedReader(new StringReader(content));
    String inputLine = null;
    ParsedPlaylist pl = new ParsedPlaylist(FilenameUtils.getBaseName(playlistLocation));
    try {
      while ((inputLine = reader.readLine()) !is null) {
        if ((ObjectValidator.isNotEmpty(inputLine)) && (inputLine.startsWith("File"))) {
          String filePath = inputLine.trim();
          filePath = filePath.substring(filePath.indexOf("=") + 1);
          pl.addItem(getAbsoluteFilePath(filePath, playlistLocation));
        }
      }
      return pl;
    } catch (IOException e) {
      throw new CannotParsePlaylistException(PlaylistType.PLS, playlistLocation, e.getMessage());
    }
  }

  public bool matches(byte[] playlist, String playlistLocation)
  {
    String content = readPlaylistContent(playlist);
    if (content !is null) {
      BufferedReader reader = new BufferedReader(new StringReader(content));
      try {
        String firstLine = reader.readLine();
        return firstLine.startsWith("[playlist]");
      } catch (IOException e) {
        return false;
      }
    }
    return false;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.playlist.PlsParserStrategy
 * JD-Core Version:    0.6.2
 */