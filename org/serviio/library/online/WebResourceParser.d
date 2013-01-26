module org.serviio.library.online.WebResourceParser;

import java.lang.Long;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import org.serviio.config.Configuration;
import org.serviio.library.entities.OnlineRepository;
import org.serviio.library.local.metadata.ImageDescriptor;
import org.serviio.library.metadata.InvalidMetadataException;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.library.online.metadata.WebResource;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;
import org.serviio.library.online.AbstractOnlineItemParser;
import org.serviio.library.online.WebResourceItem;
import org.serviio.library.online.WebResourceUrlExtractor;
import org.serviio.library.online.WebResourceContainer;
static import org.serviio.library.online.metadata.WebResourceItem;

public class WebResourceParser : AbstractOnlineItemParser
{
    public WebResource parse(URL resourceUrl, Long onlineRepositoryId, MediaFileType fileType)
    {
        log.debug_(String.format("Parsing web resource '%s'", cast(Object[])[ resourceUrl ]));
        WebResource resource = new WebResource(onlineRepositoryId);

        WebResourceUrlExtractor suitablePlugin = cast(WebResourceUrlExtractor)findSuitableExtractorPlugin(resourceUrl, OnlineRepository.OnlineRepositoryType.WEB_RESOURCE);
        if (suitablePlugin !is null) {
            WebResourceContainer container = null;
            try {
                container = suitablePlugin.parseWebResource(resourceUrl, Configuration.getMaxNumberOfItemsForOnlineFeeds().intValue());
            } catch (Throwable e) {
                throw new IOException(String.format("Unexpected error while invoking plugin (%s): %s", cast(Object[])[ suitablePlugin.getExtractorName(), e.getMessage() ]), e);
            }
            if (container !is null)
            {
                resource.setTitle(StringUtils.trim(container.getTitle()));
                resource.setDomain(resourceUrl.getHost());
                resource.setUsedExtractor(suitablePlugin);
                setContainerThumbnail(resource, container);

                if (container.getItems() !is null) {
                    int itemOrder = 1;
                    for (int i = 0; (i < container.getItems().size()) && (isAlive); i++) {
                        bool added = addResourceItem(resource, fileType, cast(WebResourceItem)container.getItems().get(i), itemOrder, suitablePlugin);
                        if (added) {
                            itemOrder++;
                        }
                    }
                }
            }
            else
            {
                log.warn("Plugin returned null container");
                return null;
            }
        } else {
            throw new InvalidMetadataException(String.format("No plugin for web resource %s has been found.", cast(Object[])[ resourceUrl.toString() ]));
        }
        return resource;
    }

    private bool addResourceItem(WebResource resource, MediaFileType fileType, WebResourceItem item, int order, WebResourceUrlExtractor suitablePlugin)
    {
        org.serviio.library.online.metadata.WebResourceItem resourceItem = new org.serviio.library.online.metadata.WebResourceItem(resource, order);
        try
        {
            resourceItem.setDate(item.getReleaseDate());
            resourceItem.setTitle(StringUtils.trim(item.getTitle()));
            try
            {
                extractContentUrlViaPlugin(suitablePlugin, resourceItem, item);
            } catch (Throwable e) {
                log.debug_(String.format("Unexpected error during url extractor plugin invocation (%s) for item %s: %s", cast(Object[])[ suitablePlugin.getExtractorName(), resourceItem.getTitle(), e.getMessage() ]));

                return false;
            }

            if (fileType == resourceItem.getType())
            {
                resourceItem.fillInUnknownEntries();
                resourceItem.validateMetadata();

                log.debug_(String.format("Added resource item %s: '%s' (%s)", cast(Object[])[ Integer.valueOf(order), resourceItem.getTitle(), resourceItem.getContentUrl() ]));
                resource.getItems().add(resourceItem);
                return true;
            }
            log.debug_(String.format("Skipping web resource item '%s' because it's not of type %s", cast(Object[])[ resourceItem.getTitle(), fileType ]));
            return false;
        }
        catch (InvalidMetadataException e) {
            log.debug_(String.format("Cannot add item of web resource %s because of invalid metadata. Message: %s", cast(Object[])[ resource.getTitle(), e.getMessage() ]));
        }
        return false;
    }

    private void extractContentUrlViaPlugin(WebResourceUrlExtractor urlExtractor, org.serviio.library.online.metadata.WebResourceItem.WebResourceItem resourceItem, WebResourceItem extractedItem)
    {
        ContentURLContainer extractedUrl = urlExtractor.extractItemUrl(extractedItem);
        applyContentUrlOnItem(extractedUrl, resourceItem, urlExtractor);

        resourceItem.getAdditionalInfo().putAll(extractedItem.getAdditionalInfo());
    }

    private void setContainerThumbnail(WebResource resource, WebResourceContainer container) 
    {
        if ((container !is null) && (ObjectValidator.isNotEmpty(container.getThumbnailUrl())))
            try {
                ImageDescriptor thumbnail = new ImageDescriptor(new URL(container.getThumbnailUrl()));
                resource.setThumbnail(thumbnail);
            } catch (MalformedURLException e) {
                log.warn(String.format("Malformed url of a web resource thumbnail (%s), skipping this thumbnail", cast(Object[])[ container.getThumbnailUrl() ]));
            }
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.online.WebResourceParser
* JD-Core Version:    0.6.2
*/