module org.serviio.util.XmlUtils;

import java.lang.String;
import java.lang.Integer;
import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.net.URL;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

public class XmlUtils
{
  private static immutable Logger log = LoggerFactory.getLogger!(XmlUtils);

  public static String objectToXMLType(Object object)
  {
    if (object !is null) {
      if (( cast(String)object !is null ))
        return cast(String)object;
      if (( cast(Integer)object !is null )) {
        return (cast(Integer)object).toString();
      }
      return object.toString();
    }

    return null;
  }

  public static String getStringFromDocument(Document doc)
  {
    DOMSource domSource = new DOMSource(doc);
    StringWriter writer = new StringWriter();
    StreamResult result = new StreamResult(writer);
    TransformerFactory tf = TransformerFactory.newInstance();
    try {
      Transformer transformer = tf.newTransformer();
      transformer.transform(domSource, result);
    } catch (TransformerException e) {
      throw new RuntimeException(e);
    }

    return writer.toString();
  }

  public static bool validateXML(String xmlId, URL schemaURL, String xml)
  {
    Source xmlFile = new StreamSource(new StringReader(xml));
    SchemaFactory schemaFactory = SchemaFactory.newInstance("http://www.w3.org/2001/XMLSchema");
    try {
      Schema schema = schemaFactory.newSchema(schemaURL);
      Validator validator = schema.newValidator();
      validator.validate(xmlFile);
      return true;
    } catch (SAXException e) {
      log.error(String.format("XML %s didn't pass validation, reason: %s", cast(Object[])[ xmlId, e.getLocalizedMessage() ]));
      return false;
    } catch (IOException e) {
      log.error(String.format("Cannot validate XML %s, reason: %s", cast(Object[])[ xmlId, e.getMessage() ]));
    }return false;
  }

  public static String decodeXml(String decodedXml)
  {
    String result = decodedXml.replaceAll("&lt;", "<");
    result = result.replaceAll("&gt;", ">");
    return result;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.XmlUtils
 * JD-Core Version:    0.6.2
 */