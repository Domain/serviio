module org.serviio.ui.resources.server.MetadataServerResource;

import java.lang.String;
import java.util.ArrayList;
import java.util.List;
import org.serviio.config.Configuration;
import org.serviio.library.entities.MetadataExtractorConfig;
import org.serviio.library.local.LibraryManager;
import org.serviio.library.local.metadata.extractor.ExtractorType;
import org.serviio.library.local.metadata.extractor.MetadataExtractorFactory;
import org.serviio.library.local.service.MediaService;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.restlet.AbstractServerResource;
import org.serviio.restlet.ResultRepresentation;
import org.serviio.ui.representation.MetadataRepresentation;
import org.serviio.ui.resources.MetadataResource;
import org.serviio.util.ServiioThreadFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MetadataServerResource : AbstractServerResource , MetadataResource
{
    private static immutable Logger log;
    private static const String DESCRIPTIVE_METADATA_EXTRACTOR_NONE = "NONE";

    static this()
    {
        log = LoggerFactory.getLogger!(MetadataServerResource)();
    }

    public MetadataRepresentation load()
    {
        MetadataRepresentation rep = new MetadataRepresentation();
        initAudioExtractors(rep);
        initVideoExtractors(rep);
        rep.setVideoOnlineArtExtractorEnabled(Configuration.isRetrieveArtFromOnlineSources());
        rep.setVideoGenerateLocalThumbnailEnabled(Configuration.isGenerateLocalThumbnailForVideos());
        rep.setImageGenerateLocalThumbnailEnabled(Configuration.isGenerateLocalThumbnailForImages());
        rep.setMetadataLanguage(Configuration.getMetadataPreferredLanguage());
        rep.setRetrieveOriginalTitle(Configuration.isMetadataUseOriginalTitle());
        return rep;
    }

    public ResultRepresentation save(MetadataRepresentation representation)
    {
        List!(ExtractorType) newVideoExtractors = createNewVideoExtractors(representation);
        bool audioExtractorsUpdated = MediaService.updateMetadataExtractorConfigs(createNewAudioExtractors(representation), MediaFileType.AUDIO);
        bool videoExtractorsUpdated = MediaService.updateMetadataExtractorConfigs(newVideoExtractors, MediaFileType.VIDEO);
        bool imageExtractorsUpdated = false;

        if ((newVideoExtractors.contains(ExtractorType.ONLINE_VIDEO_SOURCES)) && (Configuration.isRetrieveArtFromOnlineSources() != representation.isVideoOnlineArtExtractorEnabled()))
        {
            Configuration.setRetrieveArtFromOnlineSources(representation.isVideoOnlineArtExtractorEnabled());
            videoExtractorsUpdated = true;
        }

        if (Configuration.isGenerateLocalThumbnailForVideos() != representation.isVideoGenerateLocalThumbnailEnabled()) {
            Configuration.setGenerateLocalThumbnailForVideos(representation.isVideoGenerateLocalThumbnailEnabled());
            videoExtractorsUpdated = true;
        }

        if (Configuration.isGenerateLocalThumbnailForImages() != representation.isImageGenerateLocalThumbnailEnabled()) {
            Configuration.setGenerateLocalThumbnailForImages(representation.isImageGenerateLocalThumbnailEnabled());
            imageExtractorsUpdated = true;
        }

        Configuration.setMetadataPreferredLanguage(representation.getMetadataLanguage());
        Configuration.setMetadataUseOriginalTitle(representation.isRetrieveOriginalTitle());

        if ((audioExtractorsUpdated) || (videoExtractorsUpdated) || (imageExtractorsUpdated)) {
            immutable bool vu = videoExtractorsUpdated;
            immutable bool au = audioExtractorsUpdated;
            immutable bool iu = imageExtractorsUpdated;
            ServiioThreadFactory.getInstance().newThread(new class() Runnable {
                public void run() {
                    MetadataExtractorFactory.getInstance().configure();

                    LibraryManager.getInstance().pauseUpdates();

                    if (au) {
                        MediaService.markMediaItemsAsDirty(MediaFileType.AUDIO);
                    }
                    if (vu) {
                        MediaService.markMediaItemsAsDirty(MediaFileType.VIDEO);
                    }
                    if (iu) {
                        MediaService.markMediaItemsAsDirty(MediaFileType.IMAGE);
                    }

                    LibraryManager.getInstance().resumeUpdates();
                }
            }).start();
        }

        return responseOk();
    }

    private void initAudioExtractors(MetadataRepresentation representation)
    {
        List!(MetadataExtractorConfig) configs = MediaService.getMetadataExtractorConfigs(MediaFileType.AUDIO);
        foreach (MetadataExtractorConfig config ; configs)
            if (config.getExtractorType() == ExtractorType.COVER_IMAGE_IN_FOLDER)
                representation.setAudioLocalArtExtractorEnabled(true);
    }

    private void initVideoExtractors(MetadataRepresentation representation)
    {
        List!(MetadataExtractorConfig) configs = MediaService.getMetadataExtractorConfigs(MediaFileType.VIDEO);
        bool descriptiveMetadataExtractorSelected = false;
        foreach (MetadataExtractorConfig config ; configs) {
            if (config.getExtractorType() == ExtractorType.COVER_IMAGE_IN_FOLDER) {
                representation.setVideoLocalArtExtractorEnabled(true);
            } else if (config.getExtractorType().isDescriptiveMetadataExtractor()) {
                representation.setDescriptiveMetadataExtractor(config.getExtractorType().toString());
                descriptiveMetadataExtractorSelected = true;
            }
        }
        if (!descriptiveMetadataExtractorSelected)
            representation.setDescriptiveMetadataExtractor(DESCRIPTIVE_METADATA_EXTRACTOR_NONE);
    }

    private List!(ExtractorType) createNewAudioExtractors(MetadataRepresentation rep)
    {
        List!(ExtractorType) configs = new ArrayList!(ExtractorType)();
        if (rep.isAudioLocalArtExtractorEnabled()) {
            configs.add(ExtractorType.COVER_IMAGE_IN_FOLDER);
        }
        return configs;
    }

    private List!(ExtractorType) createNewVideoExtractors(MetadataRepresentation rep)
    {
        List!(ExtractorType) configs = new ArrayList!(ExtractorType)();
        if (rep.isVideoLocalArtExtractorEnabled()) {
            configs.add(ExtractorType.COVER_IMAGE_IN_FOLDER);
        }
        String descriptiveMDExtractor = rep.getDescriptiveMetadataExtractor();
        if (!descriptiveMDExtractor.equals("NONE")) {
            try {
                ExtractorType et = ExtractorType.valueOf(descriptiveMDExtractor);
                configs.add(et);
            }
            catch (Exception e) {
                log.warn(String.format("Unrecognised extractor type '%s', using NONE", cast(Object[])[ descriptiveMDExtractor ]));
            }
        }
        return configs;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.ui.resources.server.MetadataServerResource
* JD-Core Version:    0.6.2
*/