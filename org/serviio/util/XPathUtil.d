module org.serviio.util.XPathUtil;

import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import javax.xml.namespace.NamespaceContext;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

public class XPathUtil
{
  private static XPathFactory factory = XPathFactory.newInstance();

  public static synchronized Node getRootNode(InputStream xmlDocument)
  {
    return getNode(xmlDocument, "/");
  }

  public static synchronized Node getRootNode(String xmlDocument)
  {
    return getNode(xmlDocument, "/");
  }

  public static synchronized NodeList getNodeSet(InputStream xmlDocument, String path)
  {
    NodeList result = null;
    if (xmlDocument.markSupported())
      try {
        xmlDocument.reset();
      }
      catch (IOException e)
      {
      }
    InputSource source = new InputSource(xmlDocument);
    source.setSystemId(UUID.randomUUID().toString());

    XPath xpath = factory.newXPath();
    result = cast(NodeList)xpath.evaluate(path, source, XPathConstants.NODESET);
    return result;
  }

  public static synchronized NodeList getNodeSet(Node context, String path)
  {
    return getNodeSet(context, path, null);
  }

  public static synchronized NodeList getNodeSet(Node context, String path, NamespaceContext namespaceContext)
  {
    NodeList result = null;

    XPath xpath = factory.newXPath();
    if (namespaceContext !is null) {
      xpath.setNamespaceContext(namespaceContext);
    }
    result = cast(NodeList)xpath.evaluate(path, context, XPathConstants.NODESET);
    return result;
  }

  public static synchronized Node getNode(InputStream xmlDocument, String path)
  {
    Node result = null;
    if (xmlDocument.markSupported())
      try {
        xmlDocument.reset();
      }
      catch (IOException e)
      {
      }
    InputSource source = new InputSource(xmlDocument);
    result = evaluateXPath(source, path);
    return result;
  }

  public static synchronized Node getNode(String xmlDocument, String path)
  {
    Node result = null;
    InputSource source = new InputSource(new StringReader(xmlDocument));
    result = evaluateXPath(source, path);
    return result;
  }

  public static synchronized Node getNode(Node context, String path)
  {
    return getNode(context, path, null);
  }

  public static synchronized Node getNode(Node context, String path, NamespaceContext namespaceContext)
  {
    Node result = null;

    XPath xpath = factory.newXPath();
    if (namespaceContext !is null) {
      xpath.setNamespaceContext(namespaceContext);
    }
    result = cast(Node)xpath.evaluate(path, context, XPathConstants.NODE);
    return result;
  }

  public static String getNodeValue(Node context, String path)
  {
    return getNodeValue(context, path, null);
  }

  public static String getNodeValue(Node context, String path, NamespaceContext namespaceContext)
  {
    Node node = getNode(context, path, namespaceContext);
    if (node !is null) {
      return node.getTextContent();
    }
    return null;
  }

  public static List!(Node) getListOfNodes(NodeList nodeList)
  {
    List!(Node) result = new ArrayList!(Node)();

    if ((nodeList !is null) && (nodeList.getLength() > 0)) {
      for (int i = 0; i < nodeList.getLength(); i++) {
        Node node = nodeList.item(i);
        result.add(node);
      }
    }
    return result;
  }

  private static synchronized Node evaluateXPath(InputSource sourceXML, String path) {
    sourceXML.setSystemId(UUID.randomUUID().toString());

    XPath xpath = factory.newXPath();
    return cast(Node)xpath.evaluate(path, sourceXML, XPathConstants.NODE);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.XPathUtil
 * JD-Core Version:    0.6.2
 */