module org.serviio.upnp.service.contentdirectory.ProtocolInfo;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import org.serviio.library.metadata.MediaFileType;

public class ProtocolInfo
{
  private String protocol = "http-get";

  private String context = "*";
  private String mimeType;
  private List/*!(? : ProtocolAdditionalInfo)*/ additionalInfos;

  public this(String mimeType, List/*!(? : ProtocolAdditionalInfo)*/ additionalInfos)
  {
    this.mimeType = mimeType;
    this.additionalInfos = additionalInfos;
  }

  public Set!(String) getMediaProtocolInfo(bool transcoded, bool live, MediaFileType fileType, bool durationAvailable)
  {
    Set!(String) result = new LinkedHashSet!(String)();
    foreach (ProtocolAdditionalInfo additionalInfo ; additionalInfos) {
      String additionalInfoField = additionalInfo.buildMediaProtocolInfo(transcoded, live, fileType, durationAvailable);
      result.add(String.format("%s:%s:%s:%s", cast(Object[])[ protocol, context, mimeType, additionalInfoField ]));
    }
    return result;
  }

  public Set!(String) getProfileProtocolInfo(MediaFileType fileType)
  {
    Set!(String) result = new LinkedHashSet!(String)();
    foreach (ProtocolAdditionalInfo additionalInfo ; additionalInfos) {
      String additionalInfoField = additionalInfo.buildProfileProtocolInfo(fileType);
      result.add(String.format("%s:%s:%s:%s", cast(Object[])[ protocol, context, mimeType, additionalInfoField ]));
    }
    return result;
  }

  public List/*!(? : ProtocolAdditionalInfo)*/ getAdditionalInfos()
  {
    return additionalInfos;
  }

  public String getMimeType() {
    return mimeType;
  }

  public void setMimeType(String mimeType) {
    this.mimeType = mimeType;
  }

  public void setAdditionalInfos(List/*!(? : ProtocolAdditionalInfo)*/ additionalInfos) {
    this.additionalInfos = additionalInfos;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.ProtocolInfo
 * JD-Core Version:    0.6.2
 */