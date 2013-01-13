module org.serviio.upnp.service.contentdirectory.command.audio.ListSongInitialsCommand;

import java.util.List;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.local.service.AudioService;
import org.serviio.profile.Profile;
import org.serviio.upnp.service.contentdirectory.ObjectType;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.command.AbstractListInitialsCommand;
import org.serviio.upnp.service.contentdirectory.command.CommandExecutionException;

public class ListSongInitialsCommand : AbstractListInitialsCommand
{
  public this(String contextIdentifier, ObjectType objectType, ObjectClassType containerClassType, ObjectClassType itemClassType, Profile rendererProfile, AccessGroup accessGroup, String idPrefix, int startIndex, int count)
  {
    super(contextIdentifier, objectType, containerClassType, itemClassType, rendererProfile, accessGroup, idPrefix, startIndex, count);
  }

  protected List!(String) getListOfInitials(int startIndex, int count)
  {
    return AudioService.getListOfSongInitials(accessGroup, startIndex, count);
  }

  public int retrieveItemCount()
  {
    return AudioService.getNumberOfSongInitials(accessGroup);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.command.audio.ListSongInitialsCommand
 * JD-Core Version:    0.6.2
 */