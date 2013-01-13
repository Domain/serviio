module org.serviio.upnp.service.contentdirectory.definition.Definition;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import org.serviio.config.Configuration;
import org.serviio.util.CollectionUtils;

public class Definition
{
  public static final String ROOT_NODE_ID = "0";
  public static final String ROOT_NODE_PARENT_ID = "-1";
  public static final String NODE_ID_VIDEO = "V";
  public static final String NODE_ID_IMAGE = "I";
  public static final String NODE_ID_AUDIO = "A";
  public static final String SEGMENT_SEPARATOR = "^";
  private static final String SEGMENT_SEPARATOR_REGEX = "\\^";
  private static Definition instance;
  private ContainerNode rootNode;

  public this(ContainerNode rootNode)
  {
    this.rootNode = rootNode;
  }

  public static Definition instance()
  {
    if (instance is null) {
      InputStream definitionStream = Definition.class_.getResourceAsStream("contentDirectoryDef.xml");
      try {
        instance = ContentDirectoryDefinitionParser.parseDefinition(definitionStream);
      } catch (ContentDirectoryDefinitionException e) {
        throw new RuntimeException(String.format("Cannot initialize ContentDirectory service: %s", cast(Object[])[ e.getMessage() ]), e);
      }
    }
    return instance;
  }

  public static void setInstance(Definition instance)
  {
    Definition.instance = instance;
  }

  public static void reload() {
    setInstance(null);
  }

  public ContainerNode getContainer(String nodeId)
  {
    String[] idSegments = nodeId.split(SEGMENT_SEPARATOR_REGEX);
    ContainerNode staticNode = findStaticContainer(idSegments[0], rootNode);
    if (idSegments.length == 1)
    {
      return staticNode;
    }if (idSegments.length > 1) {
      ContainerNode contextNode = staticNode;

      for (int i = 1; (i < idSegments.length) && (contextNode !is null) && (
        (contextNode is null) || (!( cast(ActionNode)contextNode !is null )) || (!(cast(ActionNode)contextNode).isRecursive())); i++)
      {
        contextNode = findActionContainer(idSegments[i], contextNode);
      }

      return contextNode;
    }
    return null;
  }

  public String getParentNodeId(String objectId)
  {
    String[] idSegments = objectId.split(SEGMENT_SEPARATOR_REGEX);
    if (idSegments.length == 1)
    {
      ContainerNode staticNode = findStaticContainer(idSegments[0], rootNode);
      if ((staticNode is null) || (staticNode.getParent() is null)) {
        return "-1";
      }
      StaticContainerNode parent = cast(StaticContainerNode)staticNode.getParent();
      if (isEnabledContainer(parent.getId())) {
        return parent.getId();
      }
      return getParentNodeId(parent.getId());
    }

    String parentId = objectId.substring(0, objectId.indexOf(idSegments[(idSegments.length - 1)]) - 1);
    if (!parentId.contains("^"))
    {
      if (isEnabledContainer(parentId)) {
        return parentId;
      }
      return getParentNodeId(parentId);
    }

    return parentId;
  }

  public bool isEnabledContainer(String objectId)
  {
    return getContainerVisibility(objectId) == ContainerVisibilityType.DISPLAYED;
  }

  public bool isOnlyShowContentsOfContainer(String objectId) {
    return getContainerVisibility(objectId) == ContainerVisibilityType.CONTENT_DISPLAYED;
  }

  public bool isDisabledContainer(String objectId) {
    return getContainerVisibility(objectId) == ContainerVisibilityType.DISABLED;
  }

  public ContainerVisibilityType getContainerVisibility(String objectId) {
    Map!(String, String) itemDef = Configuration.getBrowseMenuItemOptions();
    if (!itemDef.containsKey(objectId)) {
      return ContainerVisibilityType.DISPLAYED;
    }
    return ContainerVisibilityType.valueOf(cast(String)itemDef.get(objectId));
  }

  public String getContentOnlyParentTitles(String objectId)
  {
    if (Configuration.isBrowseMenuShowNameOfParentCategory()) {
      if (objectId.contains("$"))
      {
        return null;
      }
      List!(String) parentTitles = new ArrayList!(String)();
      Definition def = instance();
      DefinitionNode object = getContainer(objectId);
      if (object !is null) {
        DefinitionNode parentNode = object.getParent();
        while ((parentNode !is null) && (( cast(StaticContainerNode)parentNode !is null )) && (def.isOnlyShowContentsOfContainer((cast(StaticContainerNode)parentNode).getId()))) {
          parentTitles.add((cast(StaticContainerNode)parentNode).getTitle());
          parentNode = parentNode.getParent();
        }
        if (parentTitles.size() > 0) {
          Collections.reverse(parentTitles);
          String parentsTitle = String.format("[%s]", cast(Object[])[ CollectionUtils.listToCSV(parentTitles, "/", true) ]);
          return parentsTitle;
        }
      }
    }
    return null;
  }

  private ContainerNode findStaticContainer(String nodeId, ContainerNode node)
  {
    if (( cast(StaticContainerNode)node !is null )) {
      if ((cast(StaticDefinitionNode)node).getId().equals(nodeId)) {
        return node;
      }

      foreach (DefinitionNode childNode ; node.getChildNodes()) {
        if (( cast(ContainerNode)childNode !is null )) {
          ContainerNode foundNode = findStaticContainer(nodeId, cast(ContainerNode)childNode);
          if (foundNode !is null) {
            return foundNode;
          }
        }
      }
    }

    return null;
  }

  private ActionNode findActionContainer(String nodeIdElement, ContainerNode node)
  {
    foreach (DefinitionNode childNode ; node.getChildNodes()) {
      if (( cast(ActionNode)childNode !is null )) {
        ActionNode actionNode = cast(ActionNode)childNode;
        if (nodeIdElement.startsWith(actionNode.getIdPrefix()))
        {
          return actionNode;
        }
      }
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.definition.Definition
 * JD-Core Version:    0.6.2
 */