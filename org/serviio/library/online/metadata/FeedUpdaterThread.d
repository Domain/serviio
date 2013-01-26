module org.serviio.library.online.metadata.FeedUpdaterThread;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import org.serviio.library.entities.OnlineRepository;
import org.serviio.library.local.metadata.AudioMetadata;
import org.serviio.library.local.metadata.ImageMetadata;
import org.serviio.library.local.metadata.VideoMetadata;
import org.serviio.library.local.metadata.extractor.InvalidMediaFormatException;
import org.serviio.library.metadata.AbstractLibraryCheckerThread;
import org.serviio.library.metadata.FFmpegMetadataRetriever;
import org.serviio.library.metadata.ImageMetadataRetriever;
import org.serviio.library.metadata.ItemMetadata;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.library.online.AbstractUrlExtractor;
import org.serviio.library.online.CannotRetrieveThumbnailException;
import org.serviio.library.online.ContentURLContainer;
import org.serviio.library.online.OnlineLibraryManager;
import org.serviio.library.online.service.OnlineRepositoryService;
import org.serviio.util.HttpClient;
import org.serviio.library.online.metadata.OnlineItem;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class FeedUpdaterThread : AbstractLibraryCheckerThread
{
    private static immutable Logger log;
    private static const int FEED_UPDATER_CHECK_INTERVAL = 1;
    private OnlineLibraryManager onlineManager;

    static this()
    {
        log = LoggerFactory.getLogger!(FeedUpdaterThread)();
    }

    public this()
    {
        onlineManager = OnlineLibraryManager.getInstance();
    }

    override public void run()
    {
        log.info("Started looking for information about online resources");
        workerRunning = true;
        while (workerRunning) {
            log.debug_("Checking for new and expired online resources");
            searchingForFiles = true;
            List!(OnlineRepository) repositories = OnlineRepositoryService.getAllRepositories();

            foreach (OnlineRepository repository ; repositories)
            {
                try
                {
                    if ((workerRunning) && (repository.isEnabled()) && (OnlineRepositoryService.getRepository(repository.getId()) !is null))
                    {
                        Iterator!(/*? : */OnlineItem) it = getOnlineItems(repository).iterator();
                        while ((workerRunning) && (it.hasNext())) {
                            OnlineItem feedItem = cast(OnlineItem)it.next();
                            try {
                                bool updated = false;
                                if (workerRunning) {
                                    updated = retrieveTechnicalMetadata(feedItem);
                                }
                                if (workerRunning) {
                                    try
                                    {
                                        onlineManager.findThumbnail(feedItem.getThumbnail());
                                    } catch (CannotRetrieveThumbnailException e) {
                                        log.warn("An error occured while retrieving thumbnail, will remove it from the item and will continue", e);

                                        feedItem.setThumbnail(null);
                                    }
                                }

                                if (updated)
                                {
                                    notifyListenersUpdate("Online item");
                                }
                            } catch (IOException e) {
                                log.warn(String.format("Failed to retrieve online item information for %s. It might not play.", cast(Object[])[ feedItem.getContentUrl().toString() ]), e);
                            } catch (Exception e) {
                                log.warn("An error occured while scanning for online item information, will remove the item from the feed and will continue", e);

                                it.remove();
                            }
                        }
                    }
                } catch (Exception e) {
                    log.warn("An error occured while scanning for online item information, will continue", e);
                }
            }

            searchingForFiles = false;
            try
            {
                if ((workerRunning) && (!dontSleep)) {
                    isSleeping = true;
                    Thread.sleep(FEED_UPDATER_CHECK_INTERVAL*60000L);
                    isSleeping = false;
                } else {
                    dontSleep = false;
                }
            } catch (InterruptedException e) {
                dontSleep = false;
                isSleeping = false;
            }
        }
        log.info("Finished looking for online resources information");
    }

    private List!(/*? : */OnlineItem) getOnlineItems(OnlineRepository repository)
    {
        if ((repository.getRepoType() == OnlineRepository.OnlineRepositoryType.FEED) || (repository.getRepoType() == OnlineRepository.OnlineRepositoryType.WEB_RESOURCE))
        {
            OnlineResourceContainer!(Object, Object) resource = onlineManager.findResourceInCacheOrParse(repository);
            return resource.getItems();
        }
        SingleURLItem item = onlineManager.findSingleURLItemInCacheOrParse(repository);
        return item is null ? new ArrayList!(SingleURLItem)() : Collections.singletonList(item);
    }

    private bool retrieveTechnicalMetadata(OnlineItem onlineItem)
    {
        bool updated = false;
        if ((!onlineItem.isCompletelyLoaded()) && (onlineItem.isValidEssence()))
        {
            TechnicalMetadata existingMetadata = onlineManager.findTechnicalMetadata(onlineItem.getCacheKey());
            if (existingMetadata !is null) {
                onlineItem.setTechnicalMD(existingMetadata.clone());
                updated = true;
            }
            else {
                if ((onlineItem.getTechnicalMD().getFileSize() is null) && (!onlineItem.isLive()))
                    try
                    {
                        URL contentUrl = new URL(onlineItem.getContentUrl());
                        log.debug_("Retrieving file size from the URL connection");
                        onlineItem.getTechnicalMD().setFileSize(new Long(HttpClient.getContentSize(contentUrl).intValue()));
                        updated = true;
                    }
                catch (MalformedURLException e)
                {
                }
                if (onlineItem.getType() == MediaFileType.VIDEO) {
                    VideoMetadata md = new VideoMetadata();
                    log.debug_(String.format("Retrieving information about the video stream '%s'", cast(Object[])[ onlineItem.getTitle() ]));
                    retrieveMetadata(md, onlineItem);
                    onlineItem.getTechnicalMD().setAudioBitrate(md.getAudioBitrate());
                    onlineItem.getTechnicalMD().setAudioCodec(md.getAudioCodec());
                    onlineItem.getTechnicalMD().setAudioStreamIndex(md.getAudioStreamIndex());
                    onlineItem.getTechnicalMD().setBitrate(md.getBitrate());
                    onlineItem.getTechnicalMD().setChannels(md.getChannels());
                    if ((!onlineItem.isLive()) && (onlineItem.getTechnicalMD().getDuration() is null) && (md.getDuration() !is null)) {
                        onlineItem.getTechnicalMD().setDuration(new Long(md.getDuration().intValue()));
                    }
                    onlineItem.getTechnicalMD().setFps(md.getFps());
                    onlineItem.getTechnicalMD().setHeight(md.getHeight());
                    onlineItem.getTechnicalMD().setSamplingRate(md.getFrequency());
                    onlineItem.getTechnicalMD().setVideoBitrate(md.getVideoBitrate());
                    onlineItem.getTechnicalMD().setVideoCodec(md.getVideoCodec());
                    onlineItem.getTechnicalMD().setVideoContainer(md.getContainer());
                    onlineItem.getTechnicalMD().setVideoStreamIndex(md.getVideoStreamIndex());
                    onlineItem.getTechnicalMD().setWidth(md.getWidth());
                    onlineItem.getTechnicalMD().setFtyp(md.getFtyp());
                    onlineItem.getTechnicalMD().setH264Levels(md.getH264Levels());
                    onlineItem.getTechnicalMD().setH264Profile(md.getH264Profile());
                    onlineItem.getTechnicalMD().setSar(md.getSar());
                    storeTechnicalMetadataToCache(onlineItem);
                    updated = true;
                } else if (onlineItem.getType() == MediaFileType.AUDIO) {
                    AudioMetadata md = new AudioMetadata();
                    log.debug_("Retrieving information about the audio stream");
                    retrieveMetadata(md, onlineItem);
                    onlineItem.getTechnicalMD().setAudioContainer(md.getContainer());
                    onlineItem.getTechnicalMD().setBitrate(md.getBitrate());
                    if ((!onlineItem.isLive()) && (onlineItem.getTechnicalMD().getDuration() is null) && (md.getDuration() !is null)) {
                        onlineItem.getTechnicalMD().setDuration(new Long(md.getDuration().intValue()));
                    }
                    onlineItem.getTechnicalMD().setSamplingRate(md.getSampleFrequency());
                    onlineItem.getTechnicalMD().setChannels(md.getChannels());
                    storeTechnicalMetadataToCache(onlineItem);
                    updated = true;
                } else if (onlineItem.getType() == MediaFileType.IMAGE) {
                    ImageMetadata md = new ImageMetadata();
                    log.debug_("Retrieving information about the online image");
                    retrieveMetadata(md, onlineItem);
                    onlineItem.getTechnicalMD().setImageContainer(md.getContainer());
                    onlineItem.getTechnicalMD().setWidth(md.getWidth());
                    onlineItem.getTechnicalMD().setHeight(md.getHeight());
                    storeTechnicalMetadataToCache(onlineItem);
                    updated = true;
                }
            }
        }
        return updated;
    }

    private void retrieveMetadata(ItemMetadata md, OnlineItem onlineItem) {
        bool run = true;
        int counter = 0;
        while (run)
            try {
                if (( cast(ImageMetadata)md !is null ))
                    ImageMetadataRetriever.retrieveImageMetadata(cast(ImageMetadata)md, onlineItem.getContentUrl(), false);
                else {
                    FFmpegMetadataRetriever.retrieveOnlineMetadata(md, onlineItem.getContentUrl(), onlineItem.deliveryContext());
                }
                run = false;
            } catch (InvalidMediaFormatException e) {
                if ((( cast(OnlineContainerItem)onlineItem !is null )) && ((cast(OnlineContainerItem!(Object))onlineItem).isExpiresImmediately()) && (counter == 0))
                {
                    OnlineContainerItem!(Object) containerItem = cast(OnlineContainerItem!(Object))onlineItem;
                    counter++;
                    log.debug_("Cannot get information about the URL, it might have expired already. Trying again.");
                    try {
                        ContentURLContainer container = AbstractUrlExtractor.extractItemUrl(containerItem.getPlugin(), containerItem);
                        if (container !is null)
                            onlineItem.setContentUrl(container.getContentUrl());
                    }
                    catch (Throwable t) {
                        log.debug_(String.format("Unexpected error during url extractor plugin invocation (%s) for item %s: %s", cast(Object[])[ containerItem.getPlugin().getExtractorName(), containerItem.getTitle(), t.getMessage() ]));

                        onlineItem.setValidEssence(false);
                    }
                }
                else {
                    onlineItem.setValidEssence(false);
                    throw new IOException(e);
                }
            }
    }

    private void storeTechnicalMetadataToCache(OnlineItem onlineItem)
    {
        onlineManager.storeTechnicalMetadata(onlineItem.getCacheKey(), onlineItem.getTechnicalMD().clone());
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.online.metadata.FeedUpdaterThread
* JD-Core Version:    0.6.2
*/