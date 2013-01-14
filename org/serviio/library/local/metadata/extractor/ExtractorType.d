module org.serviio.library.local.metadata.extractor.ExtractorType;

import org.serviio.library.local.metadata.extractor.embedded.EmbeddedMetadataExtractor;
import org.serviio.library.local.metadata.extractor.video.OnlineVideoSourcesMetadataExtractor;
import org.serviio.library.local.metadata.extractor.MetadataExtractor;

public class ExtractorType
{
	enum ExtractorTypeEnum
	{
		EMBEDDED, 
		COVER_IMAGE_IN_FOLDER, 
		ONLINE_VIDEO_SOURCES, 
		SWISSCENTER, 
		XBMC, 
		MYMOVIES,
	}

	ExtractorTypeEnum extractorType;
	alias extractorType this;

  public MetadataExtractor getExtractorInstance()
  {
	  switch (extractorType)
	  {
		  case EMBEDDED:
			  return new EmbeddedMetadataExtractor(); 

		  case COVER_IMAGE_IN_FOLDER:
			  return new CoverImageInFolderExtractor(); 

		  case ONLINE_VIDEO_SOURCES:
			  return new OnlineVideoSourcesMetadataExtractor(); 

		  case SWISSCENTER:
			  return new SwissCenterExtractor(); 

		  case XBMC:
			  return new XBMCExtractor(); 

		  case MYMOVIES:
			  return new MyMoviesExtractor();
	  }
	  return null;
  }

  public int getDefaultPriority()
  {
	  switch (extractorType)
	  {
		  case EMBEDDED:
			  return 0; 

		  case COVER_IMAGE_IN_FOLDER:
			  return 10; 

		  case ONLINE_VIDEO_SOURCES:
			  return 1; 

		  case SWISSCENTER:
			  return 2; 

		  case XBMC:
			  return 2; 

		  case MYMOVIES:
			  return 2;
	  }

	  return 0;
  }

  public bool isDescriptiveMetadataExtractor()
  {
	  switch (extractorType)
	  {
		  case EMBEDDED:
			  return false; 

		  case COVER_IMAGE_IN_FOLDER:
			  return false; 

		  case ONLINE_VIDEO_SOURCES:
			  return true; 

		  case SWISSCENTER:
			  return true; 

		  case XBMC:
			  return true; 

		  case MYMOVIES:
			  return true;
	  }

	  return false;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.ExtractorType
 * JD-Core Version:    0.6.2
 */