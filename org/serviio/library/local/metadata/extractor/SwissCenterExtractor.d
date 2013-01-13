module org.serviio.library.local.metadata.extractor.SwissCenterExtractor;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import javax.xml.namespace.NamespaceContext;
import javax.xml.xpath.XPathExpressionException;
import org.serviio.library.entities.Repository;
import org.serviio.library.local.ContentType;
import org.serviio.library.local.metadata.LocalItemMetadata;
import org.serviio.library.local.metadata.VideoMetadata;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.util.FileUtils;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;
import org.serviio.util.XPathUtil;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class SwissCenterExtractor : AbstractLocalFileExtractor
{
  private static final NamespaceContext namespaceContext = new SwissCenterNamespaceContext();

  public ExtractorType getExtractorType()
  {
    return ExtractorType.SWISSCENTER;
  }

  protected MetadataFile getMetadataFile(File mediaFile, MediaFileType fileType, Repository repository)
  {
    if (fileType == MediaFileType.VIDEO)
    {
      File folder = mediaFile.getParentFile();
      if ((folder !is null) && (folder.exists()) && (folder.isDirectory()))
      {
        String fileName = FileUtils.getFileNameWithoutExtension(mediaFile) + ".xml";
        File xmlFile = findFileInFolder(folder, fileName, false);
        if (xmlFile !is null)
        {
          bool validFile = validateSwisscenterFile(xmlFile);
          if (validFile) {
            MetadataFile metadataFile = new MetadataFile(getExtractorType(), FileUtils.getLastModifiedDate(xmlFile), xmlFile.getName(), mediaFile);

            return metadataFile;
          }

          return null;
        }

        return null;
      }

      return null;
    }

    return null;
  }

  protected void retrieveMetadata(LocalItemMetadata metadata, File xmlFile, File mediaFile)
  {
    InputStream xmlStream = null;
    try {
      xmlStream = new FileInputStream(xmlFile);
      Node rootNode = XPathUtil.getRootNode(xmlStream);
      if (rootNode !is null) {
        Node movieNode = XPathUtil.getNode(rootNode, "sc:movie", namespaceContext);
        Node tvNode = XPathUtil.getNode(rootNode, "sc:tv", namespaceContext);
        if (movieNode !is null)
          retrieveMovieMetadata(cast(VideoMetadata)metadata, movieNode);
        else if (tvNode !is null)
          retrieveEpisodeMetadata(cast(VideoMetadata)metadata, tvNode);
      }
    }
    catch (XPathExpressionException e) {
      throw new InvalidMediaFormatException(String.format("File '%s' couldn't be parsed: %s", cast(Object[])[ xmlFile.getPath(), e.getMessage() ]));
    } finally {
      FileUtils.closeQuietly(xmlStream);
    }
  }

  private bool validateSwisscenterFile(File xmlFile)
  {
    log.debug_(String.format("Checking if file '%s' is a Swisscenter file", cast(Object[])[ xmlFile.getName() ]));
    InputStream xmlStream = null;
    try {
      xmlStream = new FileInputStream(xmlFile);
      Node rootNode = XPathUtil.getRootNode(xmlStream);
      if (rootNode !is null) {
        Node movieNode = XPathUtil.getNode(rootNode, "sc:movie", namespaceContext);
        Node tvNode = XPathUtil.getNode(rootNode, "sc:tv", namespaceContext);
        if ((movieNode !is null) || (tvNode !is null)) {
          log.debug_(String.format("File '%s' is a valid Swisscenter file", cast(Object[])[ xmlFile.getName() ]));
          return true;
        }
      }
      log.debug_(String.format("File '%s' is not a Swisscenter file", cast(Object[])[ xmlFile.getName() ]));
      return false;
    }
    catch (XPathExpressionException e)
    {
      log.error(String.format("File '%s' couldn't be parsed:%s", cast(Object[])[ xmlFile.getPath(), e.getMessage() ]));
      return false;
    } finally {
      FileUtils.closeQuietly(xmlStream);
    }
  }

  private void retrieveMovieMetadata(VideoMetadata metadata, Node movieNode) {
    log.debug_("Parsing XML file for movie metadata");
    try {
      retrieveSharedData(metadata, movieNode);
      metadata.setContentType(ContentType.MOVIE);
    } catch (XPathExpressionException e) {
      throw new InvalidMediaFormatException(String.format("Error during parsing SwissCenter movie XML file: %s", cast(Object[])[ e.getMessage() ]));
    }
  }

  private void retrieveEpisodeMetadata(VideoMetadata metadata, Node tvNode) {
    log.debug_("Parsing XML file for TV metadata");
    try {
      retrieveSharedData(metadata, tvNode);

      metadata.setSeriesName(StringUtils.trim(XPathUtil.getNodeValue(tvNode, "sc:programme", namespaceContext)));
      String seasonNumber = StringUtils.trim(XPathUtil.getNodeValue(tvNode, "sc:series", namespaceContext));
      String episodeNumber = StringUtils.trim(XPathUtil.getNodeValue(tvNode, "sc:episode", namespaceContext));
      metadata.setSeasonNumber(ObjectValidator.isNotEmpty(seasonNumber) ? Integer.valueOf(seasonNumber) : null);
      metadata.setEpisodeNumber(ObjectValidator.isNotEmpty(episodeNumber) ? Integer.valueOf(episodeNumber) : null);
      metadata.setContentType(ContentType.EPISODE);
    } catch (XPathExpressionException e) {
      throw new InvalidMediaFormatException(String.format("Error during parsing SwissCenter TV XML file: %s", cast(Object[])[ e.getMessage() ]));
    }
  }

  private void retrieveSharedData(VideoMetadata metadata, Node rootNode) {
    metadata.setTitle(StringUtils.trim(XPathUtil.getNodeValue(rootNode, "sc:title", namespaceContext)));
    metadata.setDescription(StringUtils.trim(XPathUtil.getNodeValue(rootNode, "sc:synopsis", namespaceContext)));
    metadata.setActors(getActors(XPathUtil.getNodeSet(rootNode, "sc:actors/sc:actor", namespaceContext)));
    metadata.setDirectors(getDirectors(XPathUtil.getNodeSet(rootNode, "sc:directors/sc:director", namespaceContext)));
    metadata.setGenre(StringUtils.trim(XPathUtil.getNodeValue(rootNode, "sc:genres/sc:genre[1]", namespaceContext)));
  }

  private List!(String) getActors(NodeList actorsNodeList) {
    List!(String) result = new ArrayList!(String)();
    if ((actorsNodeList !is null) && (actorsNodeList.getLength() > 0)) {
      for (int i = 0; i < actorsNodeList.getLength(); i++) {
        Node castNode = actorsNodeList.item(i);
        result.add(StringUtils.trim(XPathUtil.getNodeValue(castNode, "sc:name", namespaceContext)));
      }
    }
    return result;
  }

  private List!(String) getDirectors(NodeList directorsNodeList) {
    List!(String) result = new ArrayList!(String)();
    if ((directorsNodeList !is null) && (directorsNodeList.getLength() > 0)) {
      for (int i = 0; i < directorsNodeList.getLength(); i++) {
        Node castNode = directorsNodeList.item(i);
        result.add(StringUtils.trim(XPathUtil.getNodeValue(castNode, ".", namespaceContext)));
      }
    }
    return result;
  }

  private static class SwissCenterNamespaceContext
    : NamespaceContext
  {
    public String getNamespaceURI(String prefix)
    {
      if (prefix.equals("sc"))
      {
        return "http://www.swisscenter.co.uk";
      }
      return "";
    }

    public String getPrefix(String uri)
    {
      throw new UnsupportedOperationException();
    }

    public Iterator!(Object) getPrefixes(String uri)
    {
      throw new UnsupportedOperationException();
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.SwissCenterExtractor
 * JD-Core Version:    0.6.2
 */