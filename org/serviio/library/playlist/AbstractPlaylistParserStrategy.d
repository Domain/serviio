module org.serviio.library.playlist.AbstractPlaylistParserStrategy;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import org.apache.commons.io.FilenameUtils;
import org.serviio.util.FileUtils;
import org.serviio.util.HttpUtils;
import org.serviio.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class AbstractPlaylistParserStrategy
  : PlaylistParserStrategy
{
  protected final Logger log = LoggerFactory.getLogger(getClass());

  protected String readPlaylistContent(byte[] playlistBytes)
  {
    try
    {
      return StringUtils.readStreamAsString(new ByteArrayInputStream(playlistBytes), "UTF-8");
    } catch (IOException e) {
      log.warn("Error reading playlist content.", e);
    }return null;
  }

  protected String getAbsoluteFilePath(String filePath, String playlistLocation)
  {
    if ((HttpUtils.isUri(filePath)) || (FileUtils.isPathAbsoulute(filePath))) {
      return filePath;
    }
    return FilenameUtils.concat(FilenameUtils.getFullPath(playlistLocation), filePath);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.playlist.AbstractPlaylistParserStrategy
 * JD-Core Version:    0.6.2
 */