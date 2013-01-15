module org.serviio.upnp.service.contentdirectory.PacketVideoDLNAMessageBuilder;

import javax.xml.xpath.XPathExpressionException;
import org.serviio.upnp.service.contentdirectory.classes.ClassProperties;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObject;
import org.serviio.upnp.service.contentdirectory.classes.Resource;
import org.serviio.util.XPathUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

public class PacketVideoDLNAMessageBuilder : GenericDLNAMessageBuilder
{
  private static final Logger log = LoggerFactory.getLogger!(SamsungDLNAMessageBuilder)();
  private static final String PV_NAMESPACE_URL = "http://www.pv.com/pvns/";

  public this(String filter)
  {
    super(filter);
  }

  protected Node storeRootNode(Document document)
  {
    Element node = cast(Element)super.storeRootNode(document);
    node.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns:pv", PV_NAMESPACE_URL);
    return node;
  }

  protected void storeItemFields(Node itemNode, DirectoryObject object)
  {
    super.storeItemFields(itemNode, object);
    if ((isResourceRequired()) && (includedFieldsContainsAnyPropertyFilterName(ClassProperties.SUBTITLES_URL)))
      try
      {
        int i = 0;
        foreach (Resource resource ; object.getResources()) {
          if (resource.getResourceType() == Resource.ResourceType.MEDIA_ITEM) {
            Node resourceNode = XPathUtil.getNode(itemNode, "res[" + (i + 1) + "]");
            bool subtitleAdded = storeAttribute(resourceNode, object, ClassProperties.SUBTITLES_URL, "pv:subtitleFileUri", false);
            if (subtitleAdded) {
              storeStaticAttribute(resourceNode, "pv:subtitleFileType", PV_NAMESPACE_URL, "SRT");
            }
          }
          i++;
        }
      }
      catch (XPathExpressionException e)
      {
        log.warn("Cannot resolve resource elements for injection of subtitles information: " + e.getMessage());
      }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.PacketVideoDLNAMessageBuilder
 * JD-Core Version:    0.6.2
 */