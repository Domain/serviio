module org.serviio.library.online.SingleURLParser;

import java.lang.String;
import org.serviio.library.entities.OnlineRepository;
import org.serviio.library.local.metadata.ImageDescriptor;
import org.serviio.library.metadata.InvalidMetadataException;
import org.serviio.library.online.metadata.SingleURLItem;
import org.serviio.library.online.AbstractOnlineItemParser;
import org.serviio.util.HttpUtils;

public class SingleURLParser : AbstractOnlineItemParser
{
    public SingleURLItem parseItem(OnlineRepository repository)
    {
        SingleURLItem item = new SingleURLItem(repository.getId());
        String[] credentials = null;

        item.setType(repository.getFileType());
        item.setContentUrl(repository.getRepositoryUrl());
        item.setTitle(repository.getRepositoryUrl());
        if (repository.getThumbnailUrl() !is null) {
            item.setThumbnail(new ImageDescriptor(repository.getThumbnailUrl()));
        }
        item.setLive(repository.getRepoType() == OnlineRepository.OnlineRepositoryType.LIVE_STREAM);

        if (HttpUtils.isHttpUrl(repository.getRepositoryUrl())) {
            credentials = HttpUtils.getCredentialsFormUrl(repository.getRepositoryUrl());
        }
        try
        {
            item.fillInUnknownEntries();
            item.validateMetadata();
            alterUrlsWithCredentials(credentials, item);
        } catch (InvalidMetadataException e) {
            log.debug_(String.format("Cannot parse online item %s because of invalid metadata. Message: %s", cast(Object[])[ item.getContentUrl(), e.getMessage() ]));

            return null;
        }
        return item;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.online.SingleURLParser
* JD-Core Version:    0.6.2
*/