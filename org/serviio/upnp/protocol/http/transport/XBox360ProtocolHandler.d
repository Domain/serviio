module org.serviio.upnp.protocol.http.transport.XBox360ProtocolHandler;

import java.io.FileNotFoundException;
import org.serviio.library.entities.MediaItem;
import org.serviio.upnp.service.contentdirectory.HostInfo;
import org.serviio.upnp.service.contentdirectory.classes.InvalidResourceException;
import org.serviio.upnp.service.contentdirectory.classes.Resource;
import org.serviio.upnp.service.contentdirectory.classes.Resource : ResourceType;
import org.serviio.upnp.service.contentdirectory.command.ResourceValuesBuilder;

public class XBox360ProtocolHandler : DLNAProtocolHandler
{
  private static final String ALBUM_ART_TRUE = "?albumArt=true";

  public RequestedResourceDescriptor getRequestedResourceDescription(String requestUri)
  {
    bool showThumbnail = requestUri.endsWith(ALBUM_ART_TRUE);
    if (showThumbnail) {
      log.debug_("Found request for cover art, getting the cover art details");

      RequestedResourceDescriptor itemResourceDescriptor = getItemResourceDescriptor(requestUri);
      if (itemResourceDescriptor.getResourceType() == ResourceType.MEDIA_ITEM) {
        MediaItem item = getMediaItemResource(itemResourceDescriptor);
        if (item !is null) {
          Resource coverImageResource = ResourceValuesBuilder.generateThumbnailResource(item, null);
          if (coverImageResource !is null)
            try
            {
              String coverImageUrl = coverImageResource.getGeneratedURL(HostInfo.defaultHostInfo());
              return super.getRequestedResourceDescription(coverImageUrl);
            } catch (InvalidResourceException e) {
              log.warn("Cannot validate cover image resource");
            }
          else {
            throw new FileNotFoundException(String.format("Cover art doesn't exist for item %s", cast(Object[])[ item.getFileName() ]));
          }
        }
      }
      throw new InvalidResourceRequestException(String.format("Cannot retrieve resource specified by: %s", cast(Object[])[ requestUri ]));
    }

    return super.getRequestedResourceDescription(requestUri);
  }

  protected RequestedResourceDescriptor getItemResourceDescriptor(String uri)
  {
    String cleanUri = uri.substring(0, uri.indexOf(ALBUM_ART_TRUE));
    return super.getRequestedResourceDescription(cleanUri);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.http.transport.XBox360ProtocolHandler
 * JD-Core Version:    0.6.2
 */