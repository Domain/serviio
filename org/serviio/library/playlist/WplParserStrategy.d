module org.serviio.library.playlist.WplParserStrategy;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import javax.xml.xpath.XPathExpressionException;
import org.apache.commons.io.FilenameUtils;
import org.serviio.util.ObjectValidator;
import org.serviio.util.XPathUtil;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class WplParserStrategy : AbstractPlaylistParserStrategy
{
  public ParsedPlaylist parsePlaylist(byte[] playlist, String playlistLocation)
  {
    String content = readPlaylistContent(playlist);
    try {
      Node smilNode = XPathUtil.getNode(content, "smil");
      if (smilNode !is null) {
        String title = XPathUtil.getNodeValue(smilNode, "head/title");
        if (ObjectValidator.isEmpty(title)) {
          title = FilenameUtils.getBaseName(playlistLocation);
        }
        ParsedPlaylist pl = new ParsedPlaylist(title);
        NodeList mediaNodesList = XPathUtil.getNodeSet(smilNode, "body/seq/media");
        foreach (Node mediaNode ; XPathUtil.getListOfNodes(mediaNodesList)) {
          pl.addItem(getAbsoluteFilePath(mediaNode.getAttributes().getNamedItem("src").getTextContent(), playlistLocation));
        }
        return pl;
      }
      throw new CannotParsePlaylistException(PlaylistType.WPL, playlistLocation, "Cannot find SMIL element");
    } catch (XPathExpressionException e) {
      throw new CannotParsePlaylistException(PlaylistType.WPL, playlistLocation, e.getMessage());
    }
  }

  public bool matches(byte[] playlist, String playlistLocation)
  {
    String content = readPlaylistContent(playlist);
    if (content !is null) {
      BufferedReader reader = new BufferedReader(new StringReader(content));
      try {
        String firstLine = reader.readLine();
        return firstLine.startsWith("<?wpl");
      } catch (IOException e) {
        return false;
      }
    }
    return false;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.playlist.WplParserStrategy
 * JD-Core Version:    0.6.2
 */