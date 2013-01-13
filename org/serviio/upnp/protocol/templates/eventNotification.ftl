<?xml version="1.0"?>
<e:propertyset xmlns:e="urn:schemas-upnp-org:event-1-0">
<#list stateVariables as stateVariable>
<e:property>
<${stateVariable.name}>${stateVariable.stringValue?xml}</${stateVariable.name}>
</e:property>
</#list>
</e:propertyset>