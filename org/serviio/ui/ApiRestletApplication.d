module org.serviio.ui.ApiRestletApplication;

import java.lang.String;
import org.restlet.Application;
import org.restlet.Restlet;
import org.restlet.routing.Router;
import org.serviio.ui.resources.server.ActionsServerResource;
import org.serviio.ui.resources.server.ApplicationServerResource;
import org.serviio.ui.resources.server.ConsoleSettingsServerResource;
import org.serviio.ui.resources.server.LibraryStatusServerResource;
import org.serviio.ui.resources.server.LicenseUploadServerResource;
import org.serviio.ui.resources.server.MetadataServerResource;
import org.serviio.ui.resources.server.OnlinePluginsServerResource;
import org.serviio.ui.resources.server.PingServerResource;
import org.serviio.ui.resources.server.PresentationServerResource;
import org.serviio.ui.resources.server.ReferenceDataServerResource;
import org.serviio.ui.resources.server.RemoteAccessServerResource;
import org.serviio.ui.resources.server.RepositoryServerResource;
import org.serviio.ui.resources.server.ServiceStatusServerResource;
import org.serviio.ui.resources.server.StatusServerResource;
import org.serviio.ui.resources.server.TranscodingServerResource;

public class ApiRestletApplication : Application
{
    public static const String APP_CONTEXT = "/rest";

    public Restlet createInboundRoot()
    {
        Router router = new Router(getContext());

        router.attach("/metadata", MetadataServerResource.class_);
        router.attach("/transcoding", TranscodingServerResource.class_);
        router.attach("/refdata/{name}", ReferenceDataServerResource.class_);
        router.attach("/action", ActionsServerResource.class_);
        router.attach("/library-status", LibraryStatusServerResource.class_);
        router.attach("/repository", RepositoryServerResource.class_);
        router.attach("/status", StatusServerResource.class_);
        router.attach("/service-status", ServiceStatusServerResource.class_);
        router.attach("/application", ApplicationServerResource.class_);
        router.attach("/presentation", PresentationServerResource.class_);
        router.attach("/console-settings", ConsoleSettingsServerResource.class_);
        router.attach("/remote-access", RemoteAccessServerResource.class_);
        router.attach("/license-upload", LicenseUploadServerResource.class_);
        router.attach("/plugins", OnlinePluginsServerResource.class_);
        router.attach("/ping", PingServerResource.class_);

        return router;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.ui.ApiRestletApplication
* JD-Core Version:    0.6.2
*/