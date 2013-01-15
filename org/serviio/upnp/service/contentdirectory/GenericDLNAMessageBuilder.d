module org.serviio.upnp.service.contentdirectory.GenericDLNAMessageBuilder;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import org.serviio.upnp.service.contentdirectory.classes.ClassProperties;
import org.serviio.upnp.service.contentdirectory.classes.Container;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObject;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.classes.Resource;
import org.serviio.util.StringUtils;
import org.serviio.util.XmlUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

public class GenericDLNAMessageBuilder
  : ContentDirectoryMessageBuilder
{
  private static final Logger log = LoggerFactory.getLogger!(GenericDLNAMessageBuilder)();
  private static DocumentBuilder xmlBuilder;
  private Set!(String) includedFields;

  public this(String filter)
  {
    if (!filter.equals("*")) {
      includedFields = new HashSet!(String)();
      String[] fields = filter.split(",");
      foreach (String field ; fields)
        includedFields.add(StringUtils.localeSafeToLowercase(field.trim()));
    }
  }

  public Document buildXML(List!(DirectoryObject) objects)
  {
    Document xml = null;
    synchronized (xmlBuilder) {
      xml = xmlBuilder.newDocument();
    }
    Node rootNode = storeRootNode(xml);
    foreach (DirectoryObject object ; objects) {
      storeObjectNode(object, rootNode);
    }

    return xml;
  }

  protected HostInfo getHostInfo()
  {
    return HostInfo.defaultHostInfo();
  }

  protected Node storeRootNode(Document document) {
    Element rootNode = document.createElementNS("urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/", "DIDL-Lite");
    rootNode.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns:dc", "http://purl.org/dc/elements/1.1/");
    rootNode.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns:upnp", "urn:schemas-upnp-org:metadata-1-0/upnp/");
    rootNode.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns:dlna", "urn:schemas-dlna-org:metadata-1-0/");
    document.appendChild(rootNode);
    return rootNode;
  }

  protected void storeObjectNode(DirectoryObject object, Node rootNode) {
    Node objectNode = null;
    if (( cast(Container)object !is null )) {
      objectNode = getDocument(rootNode).createElement("container");
      storeContainerFields(objectNode, object);
    } else {
      objectNode = getDocument(rootNode).createElement("item");
      storeItemFields(objectNode, object);
    }
    rootNode.appendChild(objectNode);
  }

  protected void storeContainerFields(Node containerNode, DirectoryObject object)
  {
    storeAttribute(containerNode, object, ClassProperties.ID, true);
    storeAttribute(containerNode, object, ClassProperties.PARENT_ID, true);
    storeAttribute(containerNode, object, ClassProperties.RESTRICTED, true);

    storeAttribute(containerNode, object, ClassProperties.CHILD_COUNT, false);
    storeAttribute(containerNode, object, ClassProperties.SEARCHABLE, false);

    storeNode(containerNode, object, ClassProperties.TITLE, true);
    storeNode(containerNode, object, ClassProperties.OBJECT_CLASS, true);

    storeNode(containerNode, object, ClassProperties.ARTIST, false);
    Node albumArtNode = storeNode(containerNode, object, ClassProperties.ALBUM_ART_URI, false);
    storeStaticAttribute(albumArtNode, "dlna:profileID", "urn:schemas-dlna-org:metadata-1-0/", "JPEG_TN");
  }

  protected void storeItemFields(Node itemNode, DirectoryObject object)
  {
    storeAttribute(itemNode, object, ClassProperties.ID, true);
    storeAttribute(itemNode, object, ClassProperties.PARENT_ID, true);
    storeAttribute(itemNode, object, ClassProperties.RESTRICTED, true);

    storeAttribute(itemNode, object, ClassProperties.REF_ID, false);

    storeNode(itemNode, object, ClassProperties.TITLE, true);
    storeNode(itemNode, object, ClassProperties.OBJECT_CLASS, true);

    storeNode(itemNode, object, ClassProperties.CREATOR, false);

    Node albumArtNode = storeNode(itemNode, object, ClassProperties.ALBUM_ART_URI, false);
    storeStaticAttribute(albumArtNode, "dlna:profileID", "urn:schemas-dlna-org:metadata-1-0/", "JPEG_TN");

    storeNode(itemNode, object, ClassProperties.ORIGINAL_TRACK_NUMBER, false);

    storeNode(itemNode, object, ClassProperties.ICON, false);
    storeNode(itemNode, object, ClassProperties.ALBUM, false);
    storeNode(itemNode, object, ClassProperties.DATE, false);
    storeNode(itemNode, object, ClassProperties.GENRE, false);
    storeNode(itemNode, object, ClassProperties.DESCRIPTION, false);
    storeNode(itemNode, object, ClassProperties.RIGHTS, false);
    storeNode(itemNode, object, ClassProperties.PUBLISHER, false);
    storeNode(itemNode, object, ClassProperties.ARTIST, false);

    storeNode(itemNode, object, ClassProperties.RATING, false);
    storeNode(itemNode, object, ClassProperties.ACTOR, false);
    storeNode(itemNode, object, ClassProperties.DIRECTOR, false);
    storeNode(itemNode, object, ClassProperties.PRODUCER, false);
    if (isResourceRequired())
    {
      foreach (Resource resource ; object.getResources()) {
        Node resourceNode = storeNode(itemNode, resource, ClassProperties.RESOURCE_URL, true);
        storeAttribute(resourceNode, resource, ClassProperties.RESOURCE_DURATION, false);
        storeAttribute(resourceNode, resource, ClassProperties.RESOURCE_PROTOCOLINFO, true);
        storeAttribute(resourceNode, resource, ClassProperties.RESOURCE_SIZE, false);
        storeAttribute(resourceNode, resource, ClassProperties.RESOURCE_BITRATE, false);
        storeAttribute(resourceNode, resource, ClassProperties.RESOURCE_CHANNELS, false);
        storeAttribute(resourceNode, resource, ClassProperties.RESOURCE_SAMPLE_FREQUENCY, false);
        storeAttribute(resourceNode, resource, ClassProperties.RESOURCE_RESOLUTION, false);
        storeAttribute(resourceNode, resource, ClassProperties.RESOURCE_COLOR_DEPTH, false);
      }
    }
  }

  protected Node storeNode(Node parentNode, Object object, ClassProperties classAttribute, String propertyXMLName, bool mandatory) {
    if (parentNode !is null) {
      if ((mandatory) || (fieldIncluded(classAttribute))) {
        Object value = getObjectValue(classAttribute.getAttributeName(), object);
        if (value !is null) {
          Document document = getDocument(parentNode);
          if (value.getClass().isArray())
          {
            foreach (Object arrayItem ; cast(Object[])value) {
              Node node = document.createElement(propertyXMLName);
              node.setTextContent(castObjectValue(arrayItem));
              parentNode.appendChild(node);
            }
            return null;
          }

          Node node = document.createElement(propertyXMLName);
          node.setTextContent(castObjectValue(value));
          parentNode.appendChild(node);
          return node;
        }

        if (mandatory) {
          throw new RuntimeException(String.format("Missing required class attribute '%s'", cast(Object[])[ classAttribute ]));
        }
        return null;
      }

      return null;
    }

    return null;
  }

  protected Node storeNode(Node parentNode, Object object, ClassProperties classAttribute, bool mandatory)
  {
    return storeNode(parentNode, object, classAttribute, classAttribute.getFirstPropertyXMLName(), mandatory);
  }

  protected bool storeAttribute(Node parentNode, Object object, ClassProperties classAttribute, String propertyXMLName, bool mandatory)
  {
    if ((parentNode !is null) && (
      (mandatory) || (fieldIncluded(classAttribute)))) {
      Object value = getObjectValue(classAttribute.getAttributeName(), object);
      if (value !is null) {
        Document document = getDocument(parentNode);
        Attr attribute = document.createAttribute(propertyXMLName);
        attribute.setTextContent(castObjectValue(value));
        parentNode.getAttributes().setNamedItem(attribute);
        return true;
      }
      if (mandatory) {
        throw new RuntimeException(String.format("Missing required class attribute '%s' on object: %s", cast(Object[])[ classAttribute, object.toString() ]));
      }

    }

    return false;
  }

  protected void storeAttribute(Node parentNode, Object object, ClassProperties classAttribute, bool mandatory) {
    storeAttribute(parentNode, object, classAttribute, classAttribute.getFirstPropertyXMLName(), mandatory);
  }

  protected void storeStaticAttribute(Node parentNode, String attributeName, String namespace, Object value) {
    if (parentNode !is null) {
      Document document = getDocument(parentNode);
      Attr attribute = document.createAttributeNS(namespace, attributeName);
      attribute.setTextContent(castObjectValue(value));
      parentNode.getAttributes().setNamedItem(attribute);
    }
  }

  protected Object getObjectValue(String classAttribute, Object object)
  {
    if (object !is null) {
      if ((( cast(Resource)object !is null )) && (classAttribute.startsWith("resource.")))
      {
        classAttribute = classAttribute.substring(9);
      }
      String[] attributes = classAttribute.split("\\.");
      Object result = getObjectValueForAttribute(attributes[0], object);
      for (int i = 1; (i < attributes.length) && (result !is null); i++) {
        result = getObjectValueForAttribute(attributes[i], result);
      }
      return result;
    }
    return null;
  }

  private Object getObjectValueForAttribute(String classAttribute, Object object)
  {
    Class/*!(? : Object)*/ objectClass = object.getClass();
    Method getterMethod = null;
    String propertyName = capitalizePropertyName(classAttribute);
    try {
      getterMethod = findGetter(objectClass, "get" + propertyName);
      if (getterMethod is null)
      {
        getterMethod = findGetter(objectClass, "is" + propertyName);
      }
    } catch (SecurityException e) {
      log.error(String.format("Cannot access getter for class attribute %s: %s", cast(Object[])[ classAttribute, e.getMessage() ]));
    }
    if (getterMethod !is null) {
      try {
        Class!(Object)[] parameterTypes = getterMethod.getParameterTypes();
        if ((parameterTypes !is null) && (parameterTypes.length == 1) && (HostInfo.class_.isAssignableFrom(parameterTypes[0]))) {
          return getterMethod.invoke(object, cast(Object[])[ getHostInfo() ]);
        }
        return getterMethod.invoke(object, new Object[0]);
      }
      catch (InvocationTargetException e) {
        log.error(String.format("Getter for class attribute %s cannot be invoked: %s", cast(Object[])[ classAttribute, e.getTargetException().getMessage() ]));
      } catch (Exception e) {
        log.error(String.format("Getter for class attribute %s cannot be invoked: %s", cast(Object[])[ classAttribute, e.getMessage() ]));
      }
    }
    return null;
  }

  private Method findGetter(Class!(Object) objectClass, String methodName) {
    foreach (Method m ; objectClass.getMethods()) {
      if (m.getName().equals(methodName)) {
        return m;
      }
    }
    return null;
  }

  private String capitalizePropertyName(String s) {
    if (s.length() == 0) {
      return s;
    }

    char[] chars = s.toCharArray();
    chars[0] = Character.toUpperCase(chars[0]);
    return new String(chars);
  }

  private Document getDocument(Node parentNode)
  {
    Document document = parentNode.getOwnerDocument();
    if (document is null)
    {
      document = cast(Document)parentNode;
    }
    return document;
  }

  private bool fieldIncluded(ClassProperties fieldName) {
    if ((includedFields is null) || (includedFieldsContainsAnyPropertyFilterName(fieldName))) {
      return true;
    }
    return false;
  }

  protected bool isResourceRequired()
  {
    if ((includedFields is null) || (includedFieldsContainsAnyPropertyFilterName(ClassProperties.RESOURCE_URL)) || (includedFieldsContainsAnyPropertyFilterName(ClassProperties.RESOURCE_DURATION)) || (includedFieldsContainsAnyPropertyFilterName(ClassProperties.RESOURCE_PROTOCOLINFO)) || (includedFieldsContainsAnyPropertyFilterName(ClassProperties.RESOURCE_SIZE)) || (includedFieldsContainsAnyPropertyFilterName(ClassProperties.RESOURCE_BITRATE)) || (includedFieldsContainsAnyPropertyFilterName(ClassProperties.RESOURCE_CHANNELS)) || (includedFieldsContainsAnyPropertyFilterName(ClassProperties.RESOURCE_SAMPLE_FREQUENCY)) || (includedFieldsContainsAnyPropertyFilterName(ClassProperties.RESOURCE_RESOLUTION)) || (includedFieldsContainsAnyPropertyFilterName(ClassProperties.RESOURCE_COLOR_DEPTH)))
    {
      return true;
    }
    return false;
  }

  protected bool includedFieldsContainsAnyPropertyFilterName(ClassProperties field)
  {
    if (includedFields is null) {
      return true;
    }
    foreach (String fieldName ; field.getPropertyFilterNames()) {
      if (includedFields.contains(StringUtils.localeSafeToLowercase(fieldName))) {
        return true;
      }
    }
    return false;
  }

  private String castObjectValue(Object value) {
    if (( cast(ObjectClassType)value !is null ))
      return (cast(ObjectClassType)value).getClassName();
    if (( cast(Boolean)value !is null )) {
      return (cast(Boolean)value).boolValue() ? "1" : "0";
    }

    return XmlUtils.objectToXMLType(value);
  }

  
private String encodeString(String value)
  {
    value = value.replaceAll("\\\\", "\\\\\\\\");
    value = value.replaceAll(",", "\\\\,");
    return value;
  }

  static this()
  {
    try
    {
      xmlBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
    } catch (ParserConfigurationException e) {
      log.error("Cannot instantiate XML builder.", e);
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.GenericDLNAMessageBuilder
 * JD-Core Version:    0.6.2
 */