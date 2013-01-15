module org.serviio.upnp.protocol.soap.ServiceInvoker;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.annotation.Annotation;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map : Entry;
import javax.xml.namespace.QName;
import javax.xml.soap.Detail;
import javax.xml.soap.DetailEntry;
import javax.xml.soap.MessageFactory;
import javax.xml.soap.MimeHeaders;
import javax.xml.soap.SOAPBody;
import javax.xml.soap.SOAPBodyElement;
import javax.xml.soap.SOAPElement;
import javax.xml.soap.SOAPEnvelope;
import javax.xml.soap.SOAPException;
import javax.xml.soap.SOAPFault;
import javax.xml.soap.SOAPMessage;
import org.serviio.renderer.entities.Renderer;
import org.serviio.upnp.Device;
import org.serviio.upnp.service.Service;
import org.serviio.upnp.service.StateVariable;
import org.serviio.util.XmlUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Node;

public class ServiceInvoker
{
  private static final Logger log = LoggerFactory.getLogger!(ServiceInvoker)();
  private static MessageFactory messageFactory;
  private static final String QUERY_STATE_VARIABLE = "QueryStateVariable";

  public static SOAPMessage invokeService(String soapAction, String soapMessage, Renderer renderer)
  {
    String serviceName = soapAction.substring(1, soapAction.indexOf("#"));
    String operationName = soapAction.substring(soapAction.indexOf("#") + 1, soapAction.length() - 1);
    SOAPMessage message = parseSOAPMessage(soapMessage);
    SOAPOperationVO operation = extractOperationValues(message);

    if (operation.getOperationName().equals(operationName))
    {
      OperationResult result = invokeOperation(serviceName, operation, renderer);
      return createSOAPResponse(result, serviceName, operationName);
    }
    throw new ServiceInvocationException("SOAPACTION specifies a different operation than the SOAP body_");
  }

  private static SOAPMessage parseSOAPMessage(String soapMessage)
  {
    MimeHeaders mimeHeaders = new MimeHeaders();
    mimeHeaders.addHeader("Content-Type", "text/xml; charset=UTF-8");

    InputStream stream = new ByteArrayInputStream(soapMessage.getBytes());
    try
    {
      SOAPMessage message = messageFactory.createMessage(mimeHeaders, stream);
      return message;
    } catch (IOException e) {
      throw new ServiceInvocationException("Cannot read SOAP message in order to process it", e);
    } catch (SOAPException e) {
      throw new ServiceInvocationException("The received SOAP message is not valid", e);
    } finally {
      try {
        stream.close();
      } catch (IOException e) {
      }
    }
  }

  private static SOAPMessage createSOAPResponse(OperationResult result, String serviceName, String operationName) {
    try {
      SOAPMessage message = messageFactory.createMessage();
      message.setProperty("javax.xml.soap.write-xml-declaration", "true");
      message.getSOAPHeader().detachNode();
      SOAPEnvelope envelope = message.getSOAPPart().getEnvelope();
      SOAPBody body_ = envelope.getBody();
      envelope.setEncodingStyle("http://schemas.xmlsoap.org/soap/encoding/");
      SOAPBodyElement responseNode;
      if (result.getError() !is null)
      {
        SOAPFault fault = body_.addFault(new QName(envelope.getNamespaceURI(), "Client"), "UPnPError");
        Detail faultDetail = fault.addDetail();
        DetailEntry detailEntry = faultDetail.addDetailEntry(new QName("urn:schemas-upnp-org:control-1-0", "UPnPError"));
        SOAPElement errorCodeNode = detailEntry.addChildElement(new QName("errorCode"));
        errorCodeNode.setTextContent(Integer.toString(result.getError().getCode()));
        SOAPElement errorDescription = detailEntry.addChildElement(new QName("errorDescription"));
        errorDescription.setTextContent(result.getError().getDescription());
      }
      else {
        responseNode = null;
        if (operationName.equals(QUERY_STATE_VARIABLE)) {
          responseNode = body_.addBodyElement(new QName("urn:schemas-upnp-org:control-1-0", "QueryStateVariableResponse", "u"));
          SOAPElement returnNode = responseNode.addChildElement(new QName("return"));
          returnNode.setTextContent(XmlUtils.objectToXMLType(result.getOutputParameters().values().iterator()));
        } else {
          responseNode = body_.addBodyElement(new QName(serviceName, operationName + "Response", "u"));
          foreach (Entry!(Object, Object) parameter ; result.getOutputParameters().entrySet()) {
            SOAPElement parameterNode = responseNode.addChildElement(new QName(cast(String)parameter.getKey()));
            parameterNode.setTextContent(XmlUtils.objectToXMLType(parameter.getValue()));
          }
        }
      }
      return message; } catch (SOAPException e) {
    }
    throw new ServiceInvocationException();
  }

  private static SOAPOperationVO extractOperationValues(SOAPMessage message)
  {
    SOAPOperationVO operation = new SOAPOperationVO();
    try
    {
      SOAPBody messageBody = message.getSOAPPart().getEnvelope().getBody();
      Document doc = messageBody.extractContentAsDocument();
      Node operationNode = doc.getFirstChild();
      String operationName = operationNode.getLocalName();
      operation.setOperationName(operationName);
      for (int i = 0; i < operationNode.getChildNodes().getLength(); i++) {
        Node parameterNode = operationNode.getChildNodes().item(i);
        if (parameterNode.getLocalName() !is null)
          operation.getParameters().put(parameterNode.getLocalName(), parameterNode.getTextContent());
      }
    }
    catch (SOAPException e) {
      throw new ServiceInvocationException("Cannot obtain SOAPBody in the SOAP message", e);
    }
    return operation;
  }

  private static OperationResult invokeOperation(String serviceName, SOAPOperationVO operation, Renderer renderer)
  {
    Service service = Device.getInstance().getServiceByType(serviceName);
    if (service !is null)
    {
      Class/*!(? : Service)*/ serviceClass = service.getClass();
      Method[] methods = serviceClass.getMethods();

      if (operation.getOperationName().equals("QueryStateVariable"))
      {
        OperationResult result = new OperationResult();
        String variableName = cast(String)operation.getParameters().keySet().iterator().next();
        StateVariable variable = service.getStateVariable(variableName);
        if (variable is null)
          result.setError(InvocationError.INVALID_VAR);
        else {
          result.addOutputParameter(variableName, variable.getValue());
        }
        return result;
      }
      bool operationNameFound = false;
      Method methodToExecute = null;
      bool methodIsRendererSensitive = false;
      foreach (Method method ; methods) {
        if (method.getName().equals(operation.getOperationName())) {
          operationNameFound = true;
          if (method.getParameterTypes().length == operation.getParameters().size())
          {
            methodToExecute = method;
            break;
          }
          if (method.getParameterTypes().length == operation.getParameters().size() + 1)
          {
            if (method.getParameterTypes()[(method.getParameterTypes().length - 1)] == Renderer.class_) {
              methodToExecute = method;
              methodIsRendererSensitive = true;
              break;
            }
          }
        }
      }
      if ((methodToExecute is null) && (!operationNameFound))
        return new OperationResult(InvocationError.INVALID_ACTION);
      if (methodToExecute is null) {
        return new OperationResult(InvocationError.INVALID_ARGS);
      }
      try
      {
        if (!methodIsRendererSensitive) {
          return cast(OperationResult)methodToExecute.invoke(service, castMethodParameters(operation.getParameters(), methodToExecute));
        }

        Object[] operationParams = castMethodParameters(operation.getParameters(), methodToExecute);
        Object[] methodParams = Arrays.copyOf(operationParams, operationParams.length + 1);
        methodParams[(methodParams.length - 1)] = renderer;
        return cast(OperationResult)methodToExecute.invoke(service, methodParams);
      }
      catch (IllegalArgumentException e) {
        log.error(String.format("Illegal parameters passed to operation %s", cast(Object[])[ operation.getOperationName() ]), e);

        return new OperationResult(InvocationError.INVALID_ARGS);
      } catch (IllegalAccessException e) {
        log.error(String.format("Operation %s is inaccessible", cast(Object[])[ operation.getOperationName() ]), e);

        return new OperationResult(InvocationError.INVALID_ACTION);
      } catch (InvocationTargetException e) {
        log.error(String.format("Operation %s threw an exception", cast(Object[])[ operation.getOperationName() ]), e.getTargetException());

        return new OperationResult(InvocationError.ACTION_FAILED);
      }

    }

    throw new ServiceInvocationException(String.format("Service %s is not registered", cast(Object[])[ serviceName ]));
  }

  private static Object[] castMethodParameters(Map!(String, String) stringParameters, Method method)
  {
    List!(Object) result = new ArrayList!(Object)();
    Class!(Object)[] parameterTypes = method.getParameterTypes();
    Annotation[][] parameterAnnotations = method.getParameterAnnotations();
    int i = 0;
    foreach (Annotation[] annotations ; parameterAnnotations) {
      Class!(Object) parameterType = parameterTypes[(i++)];
      if (parameterType != Renderer.class_) {
        String paramValue = null;
        SOAPParameter paramAnnotation = null;
        SOAPParameters groupAnnotation = null;
        bool found = false;
        foreach (Annotation annotation ; annotations) {
          if (( cast(SOAPParameter)annotation !is null )) {
            paramAnnotation = cast(SOAPParameter)annotation;

            paramValue = cast(String)stringParameters.get(paramAnnotation.value());
            found = true;
          } else if (( cast(SOAPParameters)annotation !is null )) {
            groupAnnotation = cast(SOAPParameters)annotation;
            SOAPParameter[] paramAnnotations = groupAnnotation.value();
            foreach (SOAPParameter alternateParamAnnotation ; paramAnnotations)
            {
              String alternateParamValue = cast(String)stringParameters.get(alternateParamAnnotation.value());
              if (alternateParamValue !is null) {
                paramAnnotation = alternateParamAnnotation;
                paramValue = alternateParamValue;
                found = true;
                break;
              }
            }
          }
          if (found) {
            break;
          }
        }
        if ((paramAnnotation is null) && (groupAnnotation is null))
        {
          throw new RuntimeException(String.format("Parameters of method %s are not properly annotated", cast(Object[])[ method.getName() ]));
        }

        Object castValue = paramValue;
        if ((paramValue !is null) && (
          (Integer.class_.isAssignableFrom(parameterType)) || (Integer.TYPE.isAssignableFrom(parameterType))))
        {
          castValue = Integer.valueOf(paramValue);
        }

        result.add(castValue);
      }
    }
    return result.toArray(new Object[result.size()]);
  }

  static this()
  {
    try
    {
      messageFactory = MessageFactory.newInstance();
    } catch (SOAPException e) {
      log.error("Cannot create instance of SOAP MessageFactory", e);
    }
  }

  private static class SOAPOperationVO
  {
    private String operationName;
    private Map!(String, String) parameters = new HashMap!(String, String)();

    public String getOperationName() {
      return operationName;
    }

    public void setOperationName(String operationName) {
      this.operationName = operationName;
    }

    public Map!(String, String) getParameters() {
      return parameters;
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.soap.ServiceInvoker
 * JD-Core Version:    0.6.2
 */