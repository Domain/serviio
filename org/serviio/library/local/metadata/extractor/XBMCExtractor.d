module org.serviio.library.local.metadata.extractor.XBMCExtractor;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import javax.xml.xpath.XPathExpressionException;
import org.serviio.library.entities.Repository;
import org.serviio.library.local.ContentType;
import org.serviio.library.local.OnlineDBIdentifier;
import org.serviio.library.local.metadata.LocalItemMetadata;
import org.serviio.library.local.metadata.VideoMetadata;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.util.FileUtils;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;
import org.serviio.util.XPathUtil;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class XBMCExtractor : AbstractLocalFileExtractor
{
  private static final DateFormat DATE_FORMAT = new SimpleDateFormat("dd/MM/yyyy");
  private static final DateFormat DATE_FORMAT2 = new SimpleDateFormat("yyyy-MM-dd");

  public ExtractorType getExtractorType()
  {
    return ExtractorType.XBMC;
  }

  protected MetadataFile getMetadataFile(File mediaFile, MediaFileType fileType, Repository repository)
  {
    if (fileType == MediaFileType.VIDEO)
    {
      File folder = mediaFile.getParentFile();
      if ((folder !is null) && (folder.exists()) && (folder.isDirectory()))
      {
        File nfoFile = findFileInFolder(folder, "movie.nfo", false);
        if (nfoFile is null) {
          nfoFile = findFileInFolder(folder, FileUtils.getFileNameWithoutExtension(mediaFile) + ".nfo", false);
        }
        if (nfoFile !is null)
        {
          bool validFile = validateXBMCNfoFile(nfoFile);
          if (validFile) {
            log.debug_(String.format("Found XBMC NFO file %s. Will try to extract metadata from it.", cast(Object[])[ nfoFile.getName() ]));
            MetadataFile metadataFile = new MetadataFile(getExtractorType(), FileUtils.getLastModifiedDate(nfoFile), nfoFile.getName(), mediaFile);

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
        Node movieNode = XPathUtil.getNode(rootNode, "//movie");
        Node tvNode = XPathUtil.getNode(rootNode, "//episodedetails");
        if (movieNode !is null)
          retrieveMovieMetadata(cast(VideoMetadata)metadata, movieNode);
        else if (tvNode !is null)
          retrieveEpisodeMetadata(cast(VideoMetadata)metadata, tvNode, mediaFile);
      }
    }
    catch (XPathExpressionException e) {
      throw new InvalidMediaFormatException(String.format("File '%s' couldn't be parsed: %s", cast(Object[])[ xmlFile.getPath(), e.getMessage() ]));
    } finally {
      FileUtils.closeQuietly(xmlStream);
    }
  }

  protected bool validateXBMCNfoFile(File xmlFile)
  {
    log.debug_(String.format("Checking if file '%s' is a XBMC NFO file", cast(Object[])[ xmlFile.getName() ]));
    InputStream xmlStream = null;
    try {
      xmlStream = new FileInputStream(xmlFile);
      Node rootNode = XPathUtil.getRootNode(xmlStream);
      if (rootNode !is null) {
        Node movieNode = XPathUtil.getNode(rootNode, "//movie");
        Node tvNode = XPathUtil.getNode(rootNode, "//episodedetails");
        if ((movieNode !is null) || (tvNode !is null)) {
          log.debug_(String.format("File '%s' is a valid XBMC file", cast(Object[])[ xmlFile.getName() ]));
          return true;
        }
      }
      log.debug_(String.format("File '%s' is not a XBMC file", cast(Object[])[ xmlFile.getName() ]));
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
    log.debug_("Parsing NFO file for movie metadata");
    try {
      retrieveSharedData(metadata, movieNode);
      metadata.setGenre(StringUtils.trim(XPathUtil.getNodeValue(movieNode, "genre[1]")));
      metadata.setContentType(ContentType.MOVIE);
    } catch (XPathExpressionException e) {
      throw new InvalidMediaFormatException(String.format("Error during parsing XBMC movie NFO file: %s", cast(Object[])[ e.getMessage() ]));
    }
  }

  private void retrieveEpisodeMetadata(VideoMetadata metadata, Node tvNode, File mediaFile) {
    log.debug_("Parsing NFO file for TV metadata");
    try
    {
      Node showNode = getSeriesFileRootNode(mediaFile);

      retrieveSharedData(metadata, tvNode);

      metadata.setGenre(StringUtils.trim(XPathUtil.getNodeValue(showNode, "genre[1]")));
      metadata.setSeriesName(StringUtils.trim(XPathUtil.getNodeValue(showNode, "title")));
      String seasonNumber = StringUtils.trim(XPathUtil.getNodeValue(tvNode, "season"));
      String episodeNumber = StringUtils.trim(XPathUtil.getNodeValue(tvNode, "episode"));
      metadata.setSeasonNumber(ObjectValidator.isNotEmpty(seasonNumber) ? Integer.valueOf(seasonNumber) : null);
      metadata.setEpisodeNumber(ObjectValidator.isNotEmpty(episodeNumber) ? Integer.valueOf(episodeNumber) : null);
      String airedDate = StringUtils.trim(XPathUtil.getNodeValue(tvNode, "aired"));
      Date aired = parseDate(airedDate);
      if (aired !is null) {
        metadata.setDate(aired);
      }
      metadata.setContentType(ContentType.EPISODE);
    } catch (XPathExpressionException e) {
      throw new InvalidMediaFormatException(String.format("Error during parsing XBMC TV NFO file: %s", cast(Object[])[ e.getMessage() ]));
    }
  }

  private void retrieveSharedData(VideoMetadata metadata, Node rootNode) {
    metadata.setTitle(StringUtils.trim(XPathUtil.getNodeValue(rootNode, "title")));
    metadata.setDescription(StringUtils.trim(XPathUtil.getNodeValue(rootNode, "plot")));
    metadata.setActors(getActors(XPathUtil.getNodeSet(rootNode, "actor")));
    metadata.setDirectors(Collections.singletonList(XPathUtil.getNodeValue(rootNode, "director")));
    String releaseDate = StringUtils.trim(XPathUtil.getNodeValue(rootNode, "releasedate"));
    metadata.setDate(parseDate(releaseDate));
    String imdbId = XPathUtil.getNodeValue(rootNode, "id");
    if ((ObjectValidator.isNotEmpty(imdbId)) && (imdbId.startsWith("tt")))
      metadata.getOnlineIdentifiers().put(OnlineDBIdentifier.IMDB, imdbId.trim());
  }

  private List!(String) getActors(NodeList actorsNodeList)
  {
    List!(String) result = new ArrayList!(String)();
    if ((actorsNodeList !is null) && (actorsNodeList.getLength() > 0)) {
      for (int i = 0; i < actorsNodeList.getLength(); i++) {
        Node castNode = actorsNodeList.item(i);
        result.add(StringUtils.trim(XPathUtil.getNodeValue(castNode, "name")));
      }
    }
    return result;
  }

  private Node getSeriesFileRootNode(File mediaFile)
  {
    File seriesNfo = findShowNfoFile(mediaFile);
    InputStream xmlStream = null;
    try {
      xmlStream = new FileInputStream(seriesNfo);
      Node rootNode = XPathUtil.getRootNode(xmlStream);
      if (rootNode !is null) {
        Node showNode = XPathUtil.getNode(rootNode, "tvshow");
        if (showNode !is null) {
          return showNode;
        }
      }
      throw new IOException(String.format("File '%s' is not a XBMC show file", cast(Object[])[ seriesNfo.getPath() ]));
    } catch (XPathExpressionException e) {
      throw new IOException(String.format("File '%s' couldn't be parsed: %s", cast(Object[])[ seriesNfo.getPath(), e.getMessage() ]));
    } finally {
      FileUtils.closeQuietly(xmlStream);
    }
  }

  private File findShowNfoFile(File mediaFile)
  {
    File folder = mediaFile.getParentFile();
    File seriesNfo = null;
    while ((seriesNfo is null) && (folder !is null)) {
      seriesNfo = findFileInFolder(folder, "tvshow.nfo", false);
      folder = folder.getParentFile();
    }
    if (seriesNfo is null) {
      throw new IOException(String.format("Cannot find tvshow.nfo file for %s, skipping XBMC metadata extraction", cast(Object[])[ mediaFile.getPath() ]));
    }
    return seriesNfo;
  }

  private Date parseDate(String date) {
    if (ObjectValidator.isNotEmpty(date)) {
      try {
        return DATE_FORMAT.parse(date);
      } catch (ParseException e) {
        try {
          return DATE_FORMAT2.parse(date);
        } catch (ParseException e2) {
          log.debug_("Cannot parse release date: " + date);
        }
      }
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.XBMCExtractor
 * JD-Core Version:    0.6.2
 */