module org.serviio.ui.representation.OnlineRepository;

import java.lang.Long;
import java.lang.String;
import java.lang.StringBuilder;
import java.util.LinkedHashSet;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.util.CollectionUtils;
import org.serviio.ui.representation.WithAccessGroups;
static import org.serviio.library.entities.OnlineRepository;

public class OnlineRepository : WithAccessGroups
{
    private Long id;
    private org.serviio.library.entities.OnlineRepository.OnlineRepository.OnlineRepositoryType repositoryType;
    private String contentUrl;
    private MediaFileType fileType;
    private String thumbnailUrl;
    private String repositoryName;
    private bool enabled;
    private LinkedHashSet!(Long) accessGroupIds;

    public this()
    {
    }

    public this(org.serviio.library.entities.OnlineRepository.OnlineRepository.OnlineRepositoryType repositoryType, String contentUrl, MediaFileType fileType, String thumbnailUrl, String repositoryName, bool enabled, LinkedHashSet!(Long) accessGroupIds)
    {
        this.repositoryType = repositoryType;
        this.contentUrl = contentUrl;
        this.fileType = fileType;
        this.thumbnailUrl = thumbnailUrl;
        this.repositoryName = repositoryName;
        this.enabled = enabled;
        this.accessGroupIds = accessGroupIds;
    }

    public Long getId()
    {
        return id;
    }

    public void setId(Long id)
    {
        this.id = id;
    }

    public org.serviio.library.entities.OnlineRepository.OnlineRepository.OnlineRepositoryType getRepositoryType()
    {
        return repositoryType;
    }

    public void setRepositoryType(org.serviio.library.entities.OnlineRepository.OnlineRepository.OnlineRepositoryType repositoryType)
    {
        this.repositoryType = repositoryType;
    }

    public String getContentUrl()
    {
        return contentUrl;
    }

    public void setContentUrl(String contentUrl)
    {
        this.contentUrl = contentUrl;
    }

    public MediaFileType getFileType()
    {
        return fileType;
    }

    public void setFileType(MediaFileType fileType)
    {
        this.fileType = fileType;
    }

    public String getThumbnailUrl()
    {
        return thumbnailUrl;
    }

    public void setThumbnailUrl(String thumbnailUrl)
    {
        this.thumbnailUrl = thumbnailUrl;
    }

    public String getRepositoryName() {
        return repositoryName;
    }

    public void setRepositoryName(String repositoryName) {
        this.repositoryName = repositoryName;
    }

    public bool isEnabled() {
        return enabled;
    }

    public void setEnabled(bool enabled) {
        this.enabled = enabled;
    }

    public LinkedHashSet!(Long) getAccessGroupIds()
    {
        return accessGroupIds;
    }

    public void setAccessGroupIds(LinkedHashSet!(Long) accessGroupIds) {
        this.accessGroupIds = accessGroupIds;
    }

    override public String toString()
    {
        StringBuilder builder = new StringBuilder();
        builder.append("OnlineRepository [id=").append(id).append(", repositoryType=").append(repositoryType).append(", contentUrl=").append(contentUrl).append(", fileType=").append(fileType).append(", thumbnailUrl=").append(thumbnailUrl).append(", repositoryName=").append(repositoryName).append(", enabled=").append(enabled).append(", accessGroupIds=").append(CollectionUtils.listToCSV(accessGroupIds, ",", true)).append("]");

        return builder.toString();
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.ui.representation.OnlineRepository
* JD-Core Version:    0.6.2
*/