module org.serviio.library.online.metadata.OnlineItem;

import java.lang.String;
import java.lang.Long;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Date;
import org.serviio.delivery.DeliveryContext;
import org.serviio.library.entities.Image;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.entities.MusicTrack;
import org.serviio.library.entities.Video;
import org.serviio.library.local.metadata.ImageDescriptor;
import org.serviio.library.metadata.InvalidMetadataException;
import org.serviio.library.metadata.ItemMetadata;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.library.online.OnlineItemId;
import org.serviio.util.FileUtils;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;
import org.serviio.library.online.metadata.TechnicalMetadata;

public abstract class OnlineItem : ItemMetadata
{
    private OnlineItemId id;
    private ImageDescriptor thumbnail;
    private String contentUrl;
    private MediaFileType type;
    private TechnicalMetadata technicalMD = new TechnicalMetadata();
    private String cacheKey;
    private bool validEssence = true;

    private bool live = false;
    private String userAgent;

    override public void validateMetadata()
    {
        super.validateMetadata();

        if (contentUrl is null) {
            throw new InvalidMetadataException("Unknown feed entry URL.");
        }

        if (type is null)
            throw new InvalidMetadataException("Unknown feed entry type.");
    }

    override public void fillInUnknownEntries()
    {
        if (ObjectValidator.isEmpty(author)) {
            setAuthor("Unknown");
        }
        if (ObjectValidator.isEmpty(title)) {
            setTitle("Unknown");
        }
        if (date is null) {
            setDate(new Date());
        }
        if (ObjectValidator.isEmpty(cacheKey))
            setCacheKey(contentUrl);
    }

    public MediaItem toMediaItem()
    {
        DeliveryContext deliveryContext = new DeliveryContext(false, userAgent);
        if (type == MediaFileType.IMAGE) {
            Image image = new Image(title, technicalMD.getImageContainer(), contentUrl, contentUrl, technicalMD.getFileSize(), null, null, date);
            image.setHeight(technicalMD.getHeight());
            image.setWidth(technicalMD.getWidth());
            image.setId(getId());
            image.setLive(false);
            if (getThumbnail() !is null) {
                image.setThumbnailId(image.getId());
            }
            image.setDeliveryContext(deliveryContext);
            return image;
        }if (type == MediaFileType.AUDIO) {
            MusicTrack track = new MusicTrack(title, technicalMD.getAudioContainer(), contentUrl, contentUrl, technicalMD.getFileSize(), null, null, date);
            track.setId(getId());
            if (getThumbnail() !is null) {
                track.setThumbnailId(track.getId());
            }
            track.setBitrate(technicalMD.getBitrate());
            track.setDuration(technicalMD.getDuration() !is null ? Integer.valueOf(technicalMD.getDuration().intValue()) : null);
            track.setSampleFrequency(technicalMD.getSamplingRate() !is null ? Integer.valueOf(technicalMD.getSamplingRate().intValue()) : null);
            track.setChannels(technicalMD.getChannels());
            track.setLive(live);
            track.setDeliveryContext(deliveryContext);
            return track;
        }if (type == MediaFileType.VIDEO) {
            Video video = new Video(title, technicalMD.getVideoContainer(), contentUrl, contentUrl, technicalMD.getFileSize(), null, null, date);
            video.setId(getId());
            if (getThumbnail() !is null) {
                video.setThumbnailId(video.getId());
            }
            video.setAudioBitrate(technicalMD.getAudioBitrate());
            video.setAudioCodec(technicalMD.getAudioCodec());
            video.setAudioStreamIndex(technicalMD.getAudioStreamIndex());
            video.setBitrate(technicalMD.getBitrate());
            video.setChannels(technicalMD.getChannels());
            video.setDuration(technicalMD.getDuration() !is null ? Integer.valueOf(technicalMD.getDuration().intValue()) : null);
            video.setFps(technicalMD.getFps());
            video.setFrequency(technicalMD.getSamplingRate());
            video.setHeight(technicalMD.getHeight());
            video.setVideoCodec(technicalMD.getVideoCodec());
            video.setVideoStreamIndex(technicalMD.getVideoStreamIndex());
            video.setWidth(technicalMD.getWidth());
            video.setFtyp(technicalMD.getFtyp());
            video.setH264Levels(technicalMD.getH264Levels());
            video.setH264Profile(technicalMD.getH264Profile());
            video.setSar(technicalMD.getSar());
            video.setLive(live);
            video.setDeliveryContext(deliveryContext);
            return video;
        }
        return null;
    }

    public void setMediaType(String mimeType, String contentUrl) {
        String normalizedMimeType = StringUtils.localeSafeToLowercase(mimeType);
        String extension = null;
        try {
            extension = StringUtils.localeSafeToLowercase(FileUtils.getFileExtension(new URL(contentUrl)));
        }
        catch (MalformedURLException e) {
        }
        type = MediaFileType.findMediaFileTypeByMimeType(normalizedMimeType);
        if ((type is null) && (extension !is null))
            type = MediaFileType.findMediaFileTypeByExtension(extension);
    }

    public bool isCompletelyLoaded()
    {
        if (type == MediaFileType.IMAGE)
            return (technicalMD !is null) && (technicalMD.getFileSize() !is null) && (technicalMD.getImageContainer() !is null);
        if (type == MediaFileType.AUDIO)
            return (technicalMD !is null) && (technicalMD.getFileSize() !is null) && (technicalMD.getAudioContainer() !is null);
        if (type == MediaFileType.VIDEO) {
            return (technicalMD !is null) && (technicalMD.getFileSize() !is null) && (technicalMD.getVideoContainer() !is null);
        }
        return false;
    }

    public DeliveryContext deliveryContext() {
        return new DeliveryContext(false, userAgent);
    }

    protected abstract OnlineItemId generateId();

    public Long getId()
    {
        if (id is null) {
            id = generateId();
        }
        return Long.valueOf(id.value());
    }

    public ImageDescriptor getThumbnail() {
        return thumbnail;
    }

    public void setThumbnail(ImageDescriptor thumbnail) {
        this.thumbnail = thumbnail;
    }

    public String getContentUrl() {
        return contentUrl;
    }

    public void setContentUrl(String contentUrl) {
        this.contentUrl = contentUrl;
    }

    public MediaFileType getType() {
        return type;
    }

    public void setType(MediaFileType type) {
        this.type = type;
    }

    public TechnicalMetadata getTechnicalMD() {
        return technicalMD;
    }

    public void setTechnicalMD(TechnicalMetadata technicalMD) {
        this.technicalMD = technicalMD;
    }

    public String getCacheKey() {
        return cacheKey;
    }

    public void setCacheKey(String cacheKey) {
        this.cacheKey = cacheKey;
    }

    public bool isValidEssence() {
        return validEssence;
    }

    public void setValidEssence(bool validEssence) {
        this.validEssence = validEssence;
    }

    public bool isLive() {
        return live;
    }

    public void setLive(bool live) {
        this.live = live;
    }

    public String getUserAgent() {
        return userAgent;
    }

    public void setUserAgent(String userAgent) {
        this.userAgent = userAgent;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.online.metadata.OnlineItem
* JD-Core Version:    0.6.2
*/