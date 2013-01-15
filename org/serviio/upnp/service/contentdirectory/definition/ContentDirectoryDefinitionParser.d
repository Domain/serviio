module org.serviio.upnp.service.contentdirectory.definition.ContentDirectoryDefinitionParser;

import java.io.InputStream;
import javax.xml.xpath.XPathExpressionException;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.util.ObjectValidator;
import org.serviio.util.XPathUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class ContentDirectoryDefinitionParser
{
  private static final Logger log = LoggerFactory.getLogger!(ContentDirectoryDefinitionParser)();
  private static final String TAG_ACTION = "action";
  private static final String TAG_CONTAINER = "container";

  public static Definition parseDefinition(InputStream definitionStream)
  {
    if (definitionStream is null)
      throw new ContentDirectoryDefinitionException("ContentDirectory definition is not present.");
    try
    {
      Node definitionRoot = XPathUtil.getRootNode(definitionStream);

      Node rootContainerNode = XPathUtil.getNode(definitionRoot, TAG_CONTAINER);
      if (rootContainerNode is null) {
        throw new ContentDirectoryDefinitionException("ContentDirectory definition doesn't contain a root node.");
      }

      log.info("Parsing ContentDirectory definition");

      ContainerNode root = createContainerNode(rootContainerNode, null);
      processNodeChildren(rootContainerNode, root);

      return new Definition(root);
    } catch (XPathExpressionException e) {
    }
    throw new ContentDirectoryDefinitionException("Cannot parse definition XML. It is corrupted.");
  }

  private static void processNodeChildren(Node parentNode, ContainerNode parentDefinitionNode)
  {
    NodeList childNodes = XPathUtil.getNodeSet(parentNode, "./*");
    for (int i = 0; i < childNodes.getLength(); i++)
    {
      Node childNode = childNodes.item(i);
      DefinitionNode childDefinitionNode;
      if (childNode.getLocalName().equals(TAG_CONTAINER)) {
        childDefinitionNode = createContainerNode(childNode, parentDefinitionNode);
      }
      else
      {
        if (childNode.getLocalName().equals(TAG_ACTION))
          childDefinitionNode = createActionNode(childNode, parentDefinitionNode);
        else
          throw new ContentDirectoryDefinitionException(String.format("Unsupported tag encountered: %s", cast(Object[])[ childNode.getLocalName() ]));
      }
      parentDefinitionNode.getChildNodes().add(childDefinitionNode);
      if (( cast(ContainerNode)childDefinitionNode !is null ))
      {
        processNodeChildren(childNode, cast(ContainerNode)childDefinitionNode);
      }
    }
  }

  private static ContainerNode createContainerNode(Node node, DefinitionNode parent)
  {
    String nodeId = XPathUtil.getNodeValue(node, "@id");
    String nodeTitleKey = XPathUtil.getNodeValue(node, "@title_key");
    String nodeContainerClass = XPathUtil.getNodeValue(node, "@containerClass");
    String nodeBrowsable = XPathUtil.getNodeValue(node, "@browsable");
    String nodeEditable = XPathUtil.getNodeValue(node, "@editable");
    String nodeCacheRegion = XPathUtil.getNodeValue(node, "@cacheRegion");

    log.debug_(String.format("Found Container node with attributes: id=%s, titleKey=%s, class=%s, cacheRegion=%s, browsable = %s, editable = %s", cast(Object[])[ nodeId, nodeTitleKey, nodeContainerClass, nodeCacheRegion, nodeBrowsable, nodeEditable ]));
    try
    {
      StaticContainerNode container = new StaticContainerNode(nodeId, nodeTitleKey, ObjectClassType.valueOf(nodeContainerClass), parent, nodeCacheRegion);

      if (ObjectValidator.isNotEmpty(nodeBrowsable)) {
        container.setBrowsable(Boolean.parseBoolean(nodeBrowsable));
      }
      if (ObjectValidator.isNotEmpty(nodeEditable)) {
        container.setEditable(Boolean.parseBoolean(nodeEditable));
      }
      container.validate();
      return container;
    }
    catch (IllegalArgumentException e) {
      throw new ContentDirectoryDefinitionException(String.format("Object class %s doesn't exist", cast(Object[])[ nodeContainerClass ]), e);
    }
  }

  private static ActionNode createActionNode(Node node, DefinitionNode parent)
  {
    String nodeCommandClass = XPathUtil.getNodeValue(node, "@command");
    String nodeContainerClass = XPathUtil.getNodeValue(node, "@containerClass");
    String nodeItemClass = XPathUtil.getNodeValue(node, "@itemClass");
    String nodeIdPrefix = XPathUtil.getNodeValue(node, "@idPrefix");
    bool recursive = Boolean.valueOf(XPathUtil.getNodeValue(node, "@recursive")).boolValue();
    String nodeCacheRegion = XPathUtil.getNodeValue(node, "@cacheRegion");

    log.debug_(String.format("Found Action node with attributes: command=%s, containerClass=%s, itemClass=%s, idPrefix=%s, recursive=%s, cacheRegion=%s", cast(Object[])[ nodeCommandClass, nodeContainerClass, nodeItemClass, nodeIdPrefix, Boolean.valueOf(recursive), nodeCacheRegion ]));
    try
    {
      ObjectClassType containerClassType = ObjectValidator.isNotEmpty(nodeContainerClass) ? ObjectClassType.valueOf(nodeContainerClass) : null;
      ObjectClassType itemClassType = ObjectValidator.isNotEmpty(nodeItemClass) ? ObjectClassType.valueOf(nodeItemClass) : null;
      ActionNode action = new ActionNode(nodeCommandClass, nodeIdPrefix, containerClassType, itemClassType, parent, nodeCacheRegion, recursive);
      action.validate();
      return action;
    }
    catch (IllegalArgumentException e) {
      throw new ContentDirectoryDefinitionException(String.format("Object class doesn't exist: %s", cast(Object[])[ e.getMessage() ]), e);
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.definition.ContentDirectoryDefinitionParser
 * JD-Core Version:    0.6.2
 */