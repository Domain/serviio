module org.serviio.library.playlist.AsxParserStrategy;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import org.apache.commons.io.FilenameUtils;
import org.jdom.Attribute;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;
import org.serviio.util.StringUtils;

public class AsxParserStrategy : AbstractPlaylistParserStrategy
{
  public ParsedPlaylist parsePlaylist(byte[] playlist, String playlistLocation)
  {
    String title = FilenameUtils.getBaseName(playlistLocation);
    SAXBuilder builder = new SAXBuilder();
    List!(String) files = new ArrayList!(String)();
    try {
      Document doc = builder.build(new ByteArrayInputStream(playlist));
      Element root = doc.getRootElement();
      if ((root !is null) && (StringUtils.localeSafeToLowercase(root.getName()).equals("asx"))) {
        
		List!(Element) children = root.getChildren();
        foreach (Element entryNode ; children) {
          if (StringUtils.localeSafeToLowercase(entryNode.getName()).equals("title")) {
            title = entryNode.getValue();
          }
          if (StringUtils.localeSafeToLowercase(entryNode.getName()).equals("entry")) {
            
			List!(Element) refNodes = entryNode.getChildren();
            foreach (Element refNode ; refNodes) {
              if (StringUtils.localeSafeToLowercase(refNode.getName()).equals("ref")) {
                
				List!(Attribute) attributes = refNode.getAttributes();
                foreach (Attribute attribute ; attributes) {
                  if (StringUtils.localeSafeToLowercase(attribute.getName()).equals("href")) {
                    files.add(attribute.getValue().trim());
                    break;
                  }
                }
                break;
              }
            }
          }
        }
        ParsedPlaylist pl = new ParsedPlaylist(title);
        foreach (String file ; files) {
          pl.addItem(file);
        }
        return pl;
      }
      throw new CannotParsePlaylistException(PlaylistType.ASX, playlistLocation, "Cannot find root ASX element");
    } catch (JDOMException e) {
      throw new CannotParsePlaylistException(PlaylistType.ASX, playlistLocation, e.getMessage());
    } catch (IOException e) {
      throw new CannotParsePlaylistException(PlaylistType.ASX, playlistLocation, e.getMessage());
    }
  }

  public bool matches(byte[] playlist, String playlistLocation)
  {
    String content = readPlaylistContent(playlist);
    if (content !is null) {
      return StringUtils.localeSafeToLowercase(content).indexOf("<asx") > -1;
    }
    return false;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.playlist.AsxParserStrategy
 * JD-Core Version:    0.6.2
 */