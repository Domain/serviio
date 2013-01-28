module org.serviio.ui.representation.SharedFolder;

import java.lang.Long;
import java.lang.String;
import java.lang.StringBuilder;
import java.util.LinkedHashSet;
import java.util.Set;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.util.CollectionUtils;
import org.serviio.ui.representation.WithAccessGroups;

public class SharedFolder : WithAccessGroups
{
    private Long id;
    private String folderPath;
    private Set!(MediaFileType) supportedFileTypes;
    private bool descriptiveMetadataSupported;
    private bool scanForUpdates;
    private LinkedHashSet!(Long) accessGroupIds;

    public this()
    {
    }

    public this(String folderPath, Set!(MediaFileType) supportedFileTypes, bool descMetadataEnabled, bool scanForUpdates, LinkedHashSet!(Long) accessGroupIds)
    {
        this.folderPath = folderPath;
        this.supportedFileTypes = supportedFileTypes;
        descriptiveMetadataSupported = descMetadataEnabled;
        this.scanForUpdates = scanForUpdates;
        this.accessGroupIds = accessGroupIds;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getId() {
        return id;
    }

    public String getFolderPath() {
        return folderPath;
    }

    public Set!(MediaFileType) getSupportedFileTypes() {
        return supportedFileTypes;
    }

    protected void setSupportedFileTypes(Set!(MediaFileType) supportedFileTypes) {
        this.supportedFileTypes = supportedFileTypes;
    }

    public bool isDescriptiveMetadataSupported() {
        return descriptiveMetadataSupported;
    }

    protected void setDescriptiveMetadataSupported(bool descriptiveMetadataSupported) {
        this.descriptiveMetadataSupported = descriptiveMetadataSupported;
    }

    public bool isScanForUpdates() {
        return scanForUpdates;
    }

    protected void setScanForUpdates(bool scanForUpdates) {
        this.scanForUpdates = scanForUpdates;
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
        builder.append("SharedFolder [id=").append(id).append(", folderPath=").append(folderPath).append(", scanForUpdates=").append(scanForUpdates).append(", supportedFileTypes=").append(supportedFileTypes).append(", descriptiveMetadataSupported=").append(descriptiveMetadataSupported).append(", accessGroupIds=").append(CollectionUtils.listToCSV(accessGroupIds, ",", true)).append("]");

        return builder.toString();
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.ui.representation.SharedFolder
* JD-Core Version:    0.6.2
*/