module org.serviio.library.local.metadata.extractor.video.OnlineVideoSourcesMetadataExtractor;

import java.io.File;
import java.io.IOException;
import java.util.Date;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.entities.MetadataDescriptor;
import org.serviio.library.entities.Repository;
import org.serviio.library.local.ContentType;
import org.serviio.library.local.metadata.LocalItemMetadata;
import org.serviio.library.local.metadata.VideoMetadata;
import org.serviio.library.local.metadata.extractor.ExtractorType;
import org.serviio.library.local.metadata.extractor.InvalidMediaFormatException;
import org.serviio.library.local.metadata.extractor.MetadataExtractor;
import org.serviio.library.local.metadata.extractor.MetadataFile;
import org.serviio.library.metadata.MediaFileType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class OnlineVideoSourcesMetadataExtractor : MetadataExtractor
{
  private static final Logger log = LoggerFactory.getLogger!(OnlineVideoSourcesMetadataExtractor);

  public ExtractorType getExtractorType()
  {
    return ExtractorType.ONLINE_VIDEO_SOURCES;
  }

  protected MetadataFile getMetadataFile(File mediaFile, MediaFileType fileType, Repository repository)
  {
    VideoDescription videoDescription = FileNameParser.parse(mediaFile, repository);
    if ((videoDescription.isSearchRecommended()) && (videoDescription.getType() != VideoDescription.VideoType.SPECIAL) && (fileType == MediaFileType.VIDEO)) {
      SearchSourceAdaptor adaptor = SearchSourceFactory.getSearchSourceAdaptor(videoDescription.getType());
      if (adaptor !is null) {
        String metadataId = adaptor.search(videoDescription);
        if (metadataId !is null) {
          MetadataFile metadataFile = new MetadataFile(getExtractorType(), new Date(), metadataId, adaptor);
          return metadataFile;
        }
        log.warn(String.format("Online metadata search returned no results for file %s [%s]", cast(Object[])[ mediaFile.getName(), videoDescription.toString() ]));
        return null;
      }

      return null;
    }

    return null;
  }

  public bool isMetadataUpdated(File mediaFile, MediaItem mediaItem, MetadataDescriptor metadataDescriptor)
  {
    if (metadataDescriptor !is null) {
      return false;
    }
    return true;
  }

  protected void retrieveMetadata(MetadataFile metadataDescriptor, LocalItemMetadata metadata)
  {
    SearchSourceAdaptor adaptor = cast(SearchSourceAdaptor)metadataDescriptor.getExtractable();
    adaptor.retrieveMetadata(metadataDescriptor.getIdentifier(), cast(VideoMetadata)metadata);

    setMetadataContentType(cast(VideoMetadata)metadata, cast(SearchSourceAdaptor)metadataDescriptor.getExtractable());
  }

  protected void setMetadataContentType(VideoMetadata metadata, SearchSourceAdaptor adaptor)
  {
    if (( cast(TheMovieDBSourceAdaptor)adaptor !is null ))
      metadata.setContentType(ContentType.MOVIE);
    else if (( cast(TheTVDBSourceAdaptor)adaptor !is null ))
      metadata.setContentType(ContentType.EPISODE);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.video.OnlineVideoSourcesMetadataExtractor
 * JD-Core Version:    0.6.2
 */