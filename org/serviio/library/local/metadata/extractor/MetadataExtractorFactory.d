module org.serviio.library.local.metadata.extractor.MetadataExtractorFactory;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.serviio.library.entities.MetadataExtractorConfig;
import org.serviio.library.local.service.MediaService;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.library.local.metadata.extractor.MetadataExtractor;

public class MetadataExtractorFactory
{
    private static MetadataExtractorFactory instance;
    private Map!(MediaFileType, List!(MetadataExtractor)) extractors;

    private this()
    {
        extractors = new HashMap!(MediaFileType, List!(MetadataExtractor))();
        configure();
    }

    public static MetadataExtractorFactory getInstance()
    {
        if (instance is null) {
            instance = new MetadataExtractorFactory();
        }
        return instance;
    }

    public void configure()
    {
        extractors.clear();

        extractors.put(MediaFileType.AUDIO, buildExtractorsForMediaType(MediaFileType.AUDIO));
        extractors.put(MediaFileType.VIDEO, buildExtractorsForMediaType(MediaFileType.VIDEO));
        extractors.put(MediaFileType.IMAGE, buildExtractorsForMediaType(MediaFileType.IMAGE));
    }

    public List!(MetadataExtractor) getExtractors(MediaFileType fileType) {
        return cast(List!(MetadataExtractor))extractors.get(fileType);
    }

    private List!(MetadataExtractor) buildExtractorsForMediaType(MediaFileType type)
    {
        List!(MetadataExtractor) extractors = new ArrayList!(MetadataExtractor)();
        extractors.add(ExtractorType.EMBEDDED.getExtractorInstance());

        List!(MetadataExtractorConfig) configs = MediaService.getMetadataExtractorConfigs(type);
        foreach (MetadataExtractorConfig config ; configs) {
            extractors.add(config.getExtractorType().getExtractorInstance());
        }
        return extractors;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.local.metadata.extractor.MetadataExtractorFactory
* JD-Core Version:    0.6.2
*/