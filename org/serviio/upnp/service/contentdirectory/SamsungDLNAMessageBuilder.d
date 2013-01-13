module org.serviio.upnp.service.contentdirectory.SamsungDLNAMessageBuilder;

import org.serviio.upnp.service.contentdirectory.classes.ClassProperties;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObject;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

public class SamsungDLNAMessageBuilder : GenericDLNAMessageBuilder
{
  public this(String filter)
  {
    super(filter);
  }

  protected Node storeRootNode(Document document)
  {
    Element node = cast(Element)super.storeRootNode(document);
    node.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns:sec", "http://www.sec.co.kr/");
    return node;
  }

  protected void storeItemFields(Node itemNode, DirectoryObject object)
  {
    super.storeItemFields(itemNode, object);

    Node subtitlesNode = storeNode(itemNode, object, ClassProperties.SUBTITLES_URL, "sec:CaptionInfoEx", false);
    storeStaticAttribute(subtitlesNode, "sec:type", "http://www.sec.co.kr/", "srt");

    storeNode(itemNode, object, ClassProperties.DCM_INFO, false);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.SamsungDLNAMessageBuilder
 * JD-Core Version:    0.6.2
 */