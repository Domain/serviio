module org.serviio.upnp.service.contentdirectory.command.video.ListVideoFoldersByNameCommand;

import org.serviio.library.entities.AccessGroup;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.command.AbstractListObjectsByFSHierarchyCommand;

public class ListVideoFoldersByNameCommand : AbstractListObjectsByFSHierarchyCommand
{
  public this(String objectId, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(objectId, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count, MediaFileType.VIDEO);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.video.ListVideoFoldersByNameCommand
 * JD-Core Version:    0.6.2
 */