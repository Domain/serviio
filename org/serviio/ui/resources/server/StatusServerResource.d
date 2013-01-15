module org.serviio.ui.resources.server.StatusServerResource;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.serviio.MediaServer;
import org.serviio.UPnPServerStatus;
import org.serviio.config.Configuration;
import org.serviio.library.entities.AccessGroup;
import org.serviio.licensing.LicensingManager;
import org.serviio.renderer.ActiveRenderer;
import org.serviio.renderer.RendererManager;
import org.serviio.renderer.entities.Renderer;
import org.serviio.restlet.AbstractServerResource;
import org.serviio.restlet.ResultRepresentation;
import org.serviio.restlet.ValidationException;
import org.serviio.ui.representation.RendererRepresentation;
import org.serviio.ui.representation.StatusRepresentation;
import org.serviio.ui.resources.StatusResource;
import org.serviio.upnp.Device;
import org.serviio.util.ObjectValidator;
import org.serviio.util.ServiioThreadFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class StatusServerResource : AbstractServerResource
  , StatusResource
{
  static final Pattern ipAddressPattern = Pattern.compile("\\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\b");

  private static final Logger log = LoggerFactory.getLogger!(StatusServerResource)();

  public StatusRepresentation load()
  {
    StatusRepresentation rep = new StatusRepresentation();
    rep.setBoundIPAddress(Configuration.getBoundIPAddress());
    rep.setServerStatus(MediaServer.getStatus());
    initRenderers(rep);
    return rep;
  }

  public ResultRepresentation save(StatusRepresentation rep)
  {
    if (!validateIPAddress(rep.getBoundIPAddress())) {
      throw new ValidationException(500);
    }
    bool restartRequired = false;
    bool cacheCleanupRequired = false;
    bool ipAddressChanged = false;

    if (updateRenderers(rep)) {
      restartRequired = true;
      cacheCleanupRequired = true;
    }

    if (updateBoundIPAddress(rep)) {
      restartRequired = true;
      ipAddressChanged = true;
    }

    if (restartRequired) {
      final bool refreshBoundIPAddress = ipAddressChanged;

      if (MediaServer.getStatus() != UPnPServerStatus.STOPPED) {
        ServiioThreadFactory.getInstance().newThread(new class() Runnable {
          public void run() {
            MediaServer.stopServer();
            if (refreshBoundIPAddress) {
              Device.getInstance().refreshBoundIPAddress();
            }
            MediaServer.startServer();
          }
        }).start();
      }

    }

    if (cacheCleanupRequired) {
      getCDS().incrementUpdateID();
    }
    return responseOk();
  }

  private bool updateBoundIPAddress(StatusRepresentation rep) {
    bool addressUpdated = false;
    String originalIPAddress = Configuration.getBoundIPAddress();
    String newIPAddress = (rep.getBoundIPAddress() !is null) && (ObjectValidator.isEmpty(rep.getBoundIPAddress())) ? null : rep.getBoundIPAddress();
    if ((originalIPAddress !is null) && (!originalIPAddress.equals(newIPAddress)))
      addressUpdated = true;
    else if ((originalIPAddress is null) && (newIPAddress !is null)) {
      addressUpdated = true;
    }
    if (addressUpdated) {
      Configuration.setBoundIPAddress(newIPAddress);
    }
    return addressUpdated;
  }

  private bool validateIPAddress(String ipAddress)
  {
    if (ObjectValidator.isNotEmpty(ipAddress)) {
      Matcher m = ipAddressPattern.matcher(ipAddress);
      return m.matches();
    }
    return true;
  }

  private void initRenderers(StatusRepresentation rep)
  {
    List!(RendererRepresentation) renderers = new ArrayList!(RendererRepresentation)();

    List!(Renderer) storedRenderers = RendererManager.getInstance().getStoredRenderers();
    Map!(String, ActiveRenderer) activeRenderers = RendererManager.getInstance().getActiveRenderers();

    Set!(Renderer) mergedRenderers = new HashSet!(Renderer)();
    mergedRenderers.addAll(storedRenderers);
    foreach (ActiveRenderer ar ; activeRenderers.values()) {
      mergedRenderers.add(ar.getRenderer());
    }

    foreach (Renderer renderer ; mergedRenderers) {
      RendererRepresentation rr = new RendererRepresentation();
      rr.setUuid(renderer.getUuid());
      rr.setIpAddress(renderer.getIpAddress());
      rr.setName(renderer.getName());
      rr.setProfileId(renderer.getProfileId());
      rr.setEnabled(renderer.isEnabled());
      rr.setAccessGroupId(getAccessGroupId(renderer.getAccessGroupId()));
      if (activeRenderers.containsKey(renderer.getUuid())) {
        rr.setStatus(RendererRepresentation.RendererStatus.ACTIVE);
      }
      else if (renderer.isManuallyAdded())
        rr.setStatus(RendererRepresentation.RendererStatus.UNKNOWN);
      else {
        rr.setStatus(RendererRepresentation.RendererStatus.INACTIVE);
      }

      renderers.add(rr);
    }
    Collections.sort(renderers);
    rep.setRenderers(renderers);
  }

  private Long getAccessGroupId(Long providedAccessGroupId)
  {
    return LicensingManager.getInstance().isProVersion() ? providedAccessGroupId : AccessGroup.NO_LIMIT_ACCESS_GROUP_ID;
  }

  private bool updateRenderers(StatusRepresentation rep)
  {
    bool restartRequired = false;

    validateRenderers(rep);
    List!(Renderer) storedRenderers = RendererManager.getInstance().getStoredRenderers();

    foreach (Renderer existingRenderer ; storedRenderers) {
      if (findRendererRepresentationByUuid(rep.getRenderers(), existingRenderer.getUuid()) is null) {
        RendererManager.getInstance().removeRenderer(existingRenderer.getUuid());
      }
    }

    foreach (RendererRepresentation rr ; rep.getRenderers()) {
      Renderer storedRenderer = RendererManager.getInstance().getStoredRendererByUuid(rr.getUuid());
      if (storedRenderer !is null) {
        bool profileUpdated = false;
        if (!storedRenderer.getProfileId().equalsIgnoreCase(rr.getProfileId())) {
          storedRenderer.setProfileId(rr.getProfileId());
          storedRenderer.setForcedProfile(true);
          profileUpdated = true;
        }
        if (storedRenderer.isEnabled() != rr.isEnabled()) {
          storedRenderer.setEnabled(rr.isEnabled());
          profileUpdated = true;
        }
        if ((ObjectValidator.isNotEmpty(rr.getName())) && (!storedRenderer.getName().equalsIgnoreCase(rr.getName()))) {
          storedRenderer.setName(rr.getName());
          profileUpdated = true;
        }
        if (storedRenderer.getAccessGroupId() != getAccessGroupId(rr.getAccessGroupId())) {
          storedRenderer.setAccessGroupId(fixAccessGroupId(rr.getAccessGroupId()));
          profileUpdated = true;
        }
        if (profileUpdated) {
          restartRequired = true;
          RendererManager.getInstance().updateRenderer(storedRenderer);
        }
      } else {
        log.warn("Adding new renderers is not supported. Ignoring the data.");
      }
    }
    return restartRequired;
  }

  private Long fixAccessGroupId(Long accessGroupId) {
    return accessGroupId is null ? AccessGroup.NO_LIMIT_ACCESS_GROUP_ID : getAccessGroupId(accessGroupId);
  }

  private void validateRenderers(StatusRepresentation rep) {
    foreach (RendererRepresentation rr ; rep.getRenderers())
      if (!validateIPAddress(rr.getIpAddress()))
        throw new ValidationException(500);
  }

  public RendererRepresentation findRendererRepresentationByUuid(List!(RendererRepresentation) reps, String uuid)
  {
    foreach (RendererRepresentation rr ; reps) {
      if (rr.getUuid().equalsIgnoreCase(uuid)) {
        return rr;
      }
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.resources.server.StatusServerResource
 * JD-Core Version:    0.6.2
 */