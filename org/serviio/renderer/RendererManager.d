module org.serviio.renderer.RendererManager;

import java.lang.String;
import java.io.IOException;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import javax.xml.namespace.NamespaceContext;
import javax.xml.xpath.XPathExpressionException;
import org.apache.http.Header;
import org.serviio.db.dao.DAOFactory;
import org.serviio.library.entities.AccessGroup;
import org.serviio.profile.Profile;
import org.serviio.profile.ProfileManager;
import org.serviio.renderer.dao.RendererDAO;
import org.serviio.renderer.entities.Renderer;
import org.serviio.upnp.discovery.RendererSearchSender;
import org.serviio.util.HttpClient;
import org.serviio.util.HttpUtils;
import org.serviio.util.ServiioThreadFactory;
import org.serviio.util.XPathUtil;
import org.serviio.renderer.ActiveRenderer;
import org.serviio.renderer.RendererExpirationChecker;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Node;

public class RendererManager
{
    private static const String UNKNOWN_DEVICE_NAME = "Unrecognized device";
    private static const bool RENDERER_ENABLED_BY_DEFAULT = true;
    private static RendererManager instance;
    private static immutable Logger log;

    private static immutable UPnPDeviceNamespaceContext nsContext;

    private Map!(String, ActiveRenderer) activeRenderers;
    private RendererExpirationChecker expirationChecker;
    private RendererSearchSender searchSender;

    private RendererDAO rendererDao;

    static this()
    {
        log = LoggerFactory.getLogger!(RendererManager)();
        nsContext = new UPnPDeviceNamespaceContext();
    }

    public this()
    {
        activeRenderers = Collections.synchronizedMap(new HashMap!(String, ActiveRenderer)());
        searchSender = new RendererSearchSender(4, 3);
        rendererDao = DAOFactory.getRendererDAO();
    }

    public static synchronized RendererManager getInstance()
    {
        if (instance is null) {
            instance = new RendererManager();
        }
        return instance;
    }

    public void rendererAvailable(String uuid, String ipAddress, int timeToKeep, String descriptionURL, String server)
    {
        synchronized (activeRenderers) {
            bool addRenderer = false;

            ActiveRenderer activeRenderer = cast(ActiveRenderer)activeRenderers.get(uuid);
            Renderer renderer = null;
            if (activeRenderer is null)
            {
                renderer = rendererDao.read(uuid);
                if (renderer !is null)
                {
                    updateRendererWithANewIPAddress(renderer, ipAddress);
                }
                else {
                    try {
                        renderer = getProfileByRendererDescriptionFromURL(uuid, ipAddress, server, descriptionURL);
                    } catch (CannotResolveRendererProfileException e) {
                        log.warn(String.format("Error while retrieving renderer description: %s", cast(Object[])[ e.getMessage() ]));
                        return;
                    }
                }
                addRenderer = true;
            } else {
                renderer = activeRenderer.getRenderer();

                if (updateRendererWithANewIPAddress(renderer, ipAddress)) {
                    addRenderer = true;
                }
            }

            if (addRenderer) {
                log.debug_(String.format("Adding renderer %s to list of active renderers", cast(Object[])[ renderer ]));
            }

            activeRenderer = new ActiveRenderer(renderer, timeToKeep, new Date());
            activeRenderers.put(uuid, activeRenderer);
        }
    }

    public synchronized void rendererAvailable(Header[] httpHeaders, String ipAddress)
    {
        try
        {
            Renderer existingRenderer = getStoredRendererByIPAddress(Inet4Address.getByName(ipAddress));

            log.debug_(String.format("Looking for a renderer profile for Http headers: %s", cast(Object[])[ HttpUtils.headersToString(httpHeaders) ]));
            Profile profileByDescription = ProfileManager.findProfileByHeader(httpHeaders);

            Renderer renderer = new Renderer(UUID.randomUUID().toString(), ipAddress, null, null, true, false, true, AccessGroup.NO_LIMIT_ACCESS_GROUP_ID);
            if (profileByDescription !is null) {
                renderer.setProfileId(profileByDescription.getId());
                renderer.setName(profileByDescription.getName());
            } else {
                renderer.setProfileId("1");
                renderer.setName(UNKNOWN_DEVICE_NAME);
            }

            if (existingRenderer is null)
            {
                createRenderer(renderer);
            }
            else if ((profileByDescription !is null) && (!existingRenderer.isForcedProfile()) && (!existingRenderer.getProfileId().equalsIgnoreCase(renderer.getProfileId()))) {
                log.debug_(String.format("Updating renderer on IP %s (forced: %s, profile: %s) with profile %s", cast(Object[])[ ipAddress, Boolean.valueOf(existingRenderer.isForcedProfile()), existingRenderer.getProfileId(), renderer.getProfileId() ]));

                removeRendererWithIPAddress(ipAddress);

                createRenderer(renderer);
            }
        }
        catch (UnknownHostException e) {
            log.warn("Invalid ip address of renderer, it will not be registered: " + e.getMessage());
        }
    }

    public void rendererUnavailable(String uuid) {
        synchronized (activeRenderers) {
            if (activeRenderers.containsKey(uuid)) {
                log.debug_(String.format("Removing renderer %s from list of active renderers", cast(Object[])[ uuid ]));
                activeRenderers.remove(uuid);
            }
        }
    }

    public void searchForActiveRenderers() {
        try {
            searchSender.searchForRenderers();
        } catch (IOException e) {
            log.warn(String.format("Exception during searching for active renderers: %s", cast(Object[])[ e.getMessage() ]));
        }
    }

    public Renderer getStoredRendererByIPAddress(InetAddress ipAddress) {
        List!(Renderer) renderers = rendererDao.findByIPAddress(ipAddress.getHostAddress());
        if (renderers.size() > 0)
        {
            return cast(Renderer)renderers.get(0);
        }
        return null;
    }

    public bool rendererHasAccess(InetAddress callerIp) {
        Renderer renderer = getStoredRendererByIPAddress(callerIp);
        if ((renderer !is null) && (!renderer.isEnabled())) {
            return false;
        }
        return RENDERER_ENABLED_BY_DEFAULT;
    }

    public List!(Renderer) getStoredRenderers()
    {
        return rendererDao.findAll();
    }

    public void removeRenderer(String uuid)
    {
        rendererDao.delete_(uuid);
        rendererUnavailable(uuid);
    }

    public void createRenderer(Renderer renderer)
    {
        rendererDao.create(renderer);

        log.info(String.format("Stored a new renderer: uuid='%s', name = '%s', ipAddress='%s', profile = '%s'", cast(Object[])[ renderer.getUuid(), renderer.getName(), renderer.getIpAddress(), renderer.getProfileId() ]));
    }

    public Renderer getStoredRendererByUuid(String uuid)
    {
        return rendererDao.read(uuid);
    }

    public void updateRenderer(Renderer renderer) {
        rendererDao.update(renderer);
    }

    public void startExpirationChecker() {
        if (expirationChecker is null) {
            expirationChecker = new RendererExpirationChecker();
            Thread expirationCheckerThread = ServiioThreadFactory.getInstance().newThread(expirationChecker, "RendererExpirationChecker", true);
            expirationCheckerThread.setPriority(10);
            expirationCheckerThread.start();
        }
    }

    public void stopExpirationChecker() {
        if (expirationChecker !is null)
            expirationChecker.stopWorker();
    }

    public Map!(String, ActiveRenderer) getActiveRenderers()
    {
        return activeRenderers;
    }

    protected Renderer getProfileByRendererDescriptionFromURL(String uuid, String ipAddress, String serverName, String descriptionURL)
    {
        log.debug_(String.format("Retrieve device description from %s", cast(Object[])[ descriptionURL ]));
        try {
            String descriptionXML = HttpClient.retrieveTextFileFromURL(descriptionURL, "UTF-8");
            Renderer renderer = getRendererByRendererDescription(uuid, ipAddress, serverName, descriptionXML);

            removeRendererWithIPAddress(ipAddress);

            createRenderer(renderer);
            return renderer;
        } catch (IOException e) {
            throw new CannotResolveRendererProfileException(String.format("Cannot retrieve device description from %s", cast(Object[])[ descriptionURL ]), e);
        }
    }

    protected Renderer getRendererByRendererDescription(String uuid, String ipAddress, String serverName, String descriptionXML) {
        try {
            Node rootNode = XPathUtil.getRootNode(descriptionXML);
            Node deviceNode = XPathUtil.getNode(rootNode, "d:root/d:device", nsContext);
            String nameSpacePrefix = "d:";
            if (deviceNode is null)
            {
                deviceNode = XPathUtil.getNode(rootNode, "root/device", nsContext);
                nameSpacePrefix = "";
            }

            String modelName = XPathUtil.getNodeValue(deviceNode, String.format("%smodelName", cast(Object[])[ nameSpacePrefix ]), nsContext);
            String modelNumber = XPathUtil.getNodeValue(deviceNode, String.format("%smodelNumber", cast(Object[])[ nameSpacePrefix ]), nsContext);
            String productCode = XPathUtil.getNodeValue(deviceNode, String.format("%sUPC", cast(Object[])[ nameSpacePrefix ]), nsContext);
            String friendlyName = XPathUtil.getNodeValue(deviceNode, String.format("%sfriendlyName", cast(Object[])[ nameSpacePrefix ]), nsContext);
            String manufacturer = XPathUtil.getNodeValue(deviceNode, String.format("%smanufacturer", cast(Object[])[ nameSpacePrefix ]), nsContext);

            log.debug_(String.format("Looking for a renderer profile for: friendly name = '%s', model name= '%s', model number = '%s', manufacturer = '%s', product code = '%s', server name = '%s'", cast(Object[])[ friendlyName, modelName, modelNumber, manufacturer, productCode, serverName ]));

            Profile profileByDescription = ProfileManager.findProfileByDescription(friendlyName, modelName, modelNumber, productCode, serverName, manufacturer);
            Renderer renderer = new Renderer(uuid, ipAddress, modelName, null, false, false, true, AccessGroup.NO_LIMIT_ACCESS_GROUP_ID);

            if (profileByDescription !is null)
                renderer.setProfileId(profileByDescription.getId());
            else {
                renderer.setProfileId("1");
            }
            return renderer;
        } catch (XPathExpressionException e) {
            throw new CannotResolveRendererProfileException("Cannot parse device description", e);
        }
    }

    private bool updateRendererWithANewIPAddress(Renderer renderer, String ipAddress)
    {
        if (!ipAddress.equals(renderer.getIpAddress())) {
            removeRendererWithIPAddress(ipAddress);
            renderer.setIpAddress(ipAddress);
            rendererDao.update(renderer);
            return true;
        }
        return false;
    }

    private void removeRendererWithIPAddress(String ipAddress)
    {
        List!(Renderer) existingRenderers = rendererDao.findByIPAddress(ipAddress);
        foreach (Renderer existingRenderer ; existingRenderers)
            removeRenderer(existingRenderer.getUuid());
    }

    private static class UPnPDeviceNamespaceContext
        : NamespaceContext
    {
        public String getNamespaceURI(String prefix)
        {
            if (prefix.equals("d"))
            {
                return "urn:schemas-upnp-org:device-1-0";
            }
            return "";
        }

        public String getPrefix(String uri)
        {
            throw new UnsupportedOperationException();
        }

        public Iterator!(Object) getPrefixes(String uri)
        {
            throw new UnsupportedOperationException();
        }
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.renderer.RendererManager
* JD-Core Version:    0.6.2
*/