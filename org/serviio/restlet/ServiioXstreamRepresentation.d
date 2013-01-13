module org.serviio.restlet.ServiioXstreamRepresentation;

import com.thoughtworks.xstream.XStream;
import com.thoughtworks.xstream.converters.collections.CollectionConverter;
import com.thoughtworks.xstream.mapper.ClassAliasingMapper;
import org.restlet.data.CharacterSet;
import org.restlet.data.MediaType;
import org.restlet.ext.xstream.XstreamRepresentation;
import org.restlet.representation.Representation;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.ui.representation.ActionRepresentation;
import org.serviio.ui.representation.ApplicationRepresentation;
import org.serviio.ui.representation.BrowsingCategory;
import org.serviio.ui.representation.ConsoleSettingsRepresentation;
import org.serviio.ui.representation.DataValue;
import org.serviio.ui.representation.LibraryStatusRepresentation;
import org.serviio.ui.representation.LicenseRepresentation;
import org.serviio.ui.representation.MetadataRepresentation;
import org.serviio.ui.representation.OnlinePlugin;
import org.serviio.ui.representation.OnlinePluginsRepresentation;
import org.serviio.ui.representation.OnlineRepository;
import org.serviio.ui.representation.PresentationRepresentation;
import org.serviio.ui.representation.ReferenceDataRepresentation;
import org.serviio.ui.representation.RemoteAccessRepresentation;
import org.serviio.ui.representation.RendererRepresentation;
import org.serviio.ui.representation.RepositoryRepresentation;
import org.serviio.ui.representation.ServiceStatusRepresentation;
import org.serviio.ui.representation.SharedFolder;
import org.serviio.ui.representation.StatusRepresentation;
import org.serviio.ui.representation.TranscodingRepresentation;
import org.serviio.upnp.service.contentdirectory.rest.representation.ContentDirectoryRepresentation;
import org.serviio.upnp.service.contentdirectory.rest.representation.ContentURLRepresentation;
import org.serviio.upnp.service.contentdirectory.rest.representation.DirectoryObjectRepresentation;
import org.serviio.upnp.service.contentdirectory.rest.representation.OnlineIdentifierRepresentation;

public class ServiioXstreamRepresentation(T) : XstreamRepresentation!(T)
{
  public this(T object)
  {
    super(object);
  }

  public this(MediaType mediaType, T object) {
    super(mediaType, object);
  }

  public this(Representation representation) {
    super(representation);
  }

  public MediaType getMediaType()
  {
    return MediaType.APPLICATION_XML;
  }

  protected XStream createXstream(MediaType arg0)
  {
    XStream xs = super.createXstream(arg0);
	/// FIXME:
	//xs.alias("serviceStatus", ServiceStatusRepresentation.class_);
	//xs.alias("action", ActionRepresentation.class_);
	//xs.alias("application", ApplicationRepresentation.class_);
	//xs.alias("license", LicenseRepresentation.class_);
	//xs.alias("libraryStatus", LibraryStatusRepresentation.class_);
	//xs.alias("metadata", MetadataRepresentation.class_);
	//xs.alias("refdata", ReferenceDataRepresentation.class_);
	//xs.alias("repository", RepositoryRepresentation.class_);
	//xs.alias("result", ResultRepresentation.class_);
	//xs.alias("status", StatusRepresentation.class_);
	//xs.alias("transcoding", TranscodingRepresentation.class_);
	//xs.alias("renderer", RendererRepresentation.class_);
	//xs.alias("presentation", PresentationRepresentation.class_);
	//xs.alias("consoleSettings", ConsoleSettingsRepresentation.class_);
	//xs.alias("remoteAccess", RemoteAccessRepresentation.class_);
	//xs.alias("plugins", OnlinePluginsRepresentation.class_);
	//
	//xs.alias("item", DataValue.class_);
	//xs.alias("sharedFolder", SharedFolder.class_);
	//xs.alias("fileType", MediaFileType.class_);
	//xs.alias("browsingCategory", BrowsingCategory.class_);
	//xs.alias("onlineRepository", OnlineRepository.class_);
	//xs.alias("onlinePlugin", OnlinePlugin.class_);
	//
	//xs.alias("contentDirectory", ContentDirectoryRepresentation.class_);
	//xs.alias("object", DirectoryObjectRepresentation.class_);
	//xs.alias("contentUrl", ContentURLRepresentation.class_);
	//xs.alias("identifier", OnlineIdentifierRepresentation.class_);

    ClassAliasingMapper mapper = new ClassAliasingMapper(xs.getMapper());
    mapper.addClassAlias("id", Long.class_);
    xs.registerLocalConverter(SharedFolder.class_, "accessGroupIds", new CollectionConverter(mapper));
    xs.registerLocalConverter(OnlineRepository.class_, "accessGroupIds", new CollectionConverter(mapper));

    return xs;
  }

  public CharacterSet getCharacterSet()
  {
    return CharacterSet.UTF_8;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.restlet.ServiioXstreamRepresentation
 * JD-Core Version:    0.6.2
 */