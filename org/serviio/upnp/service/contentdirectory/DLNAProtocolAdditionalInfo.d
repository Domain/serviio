module org.serviio.upnp.service.contentdirectory.DLNAProtocolAdditionalInfo;

import java.util.ArrayList;
import java.util.List;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.util.CollectionUtils;

public class DLNAProtocolAdditionalInfo
  : ProtocolAdditionalInfo
{
  protected static final String ATTR_PN = "DLNA.ORG_PN";
  protected static final String ATTR_OP = "DLNA.ORG_OP";
  protected static final String ATTR_CI = "DLNA.ORG_CI";
  protected static final String ATTR_FLAGS = "DLNA.ORG_FLAGS";
  protected static final String FLAGS_RESERVED_DATA = "000000000000000000000000";
  protected String profileName;

  public this(String profileName)
  {
    this.profileName = profileName;
  }

  public String buildMediaProtocolInfo(bool transcoded, bool live, MediaFileType fileType, bool durationAvailable)
  {
    List!(String) fieldValues = new ArrayList!(String)();
    if (profileName !is null) {
      fieldValues.add("DLNA.ORG_PN=" + profileName);
    }
    fieldValues.add("DLNA.ORG_OP=" + getFileOperations(transcoded, live, fileType, durationAvailable));
    if (transcoded)
      fieldValues.add("DLNA.ORG_CI=1");
    else {
      fieldValues.add("DLNA.ORG_CI=0");
    }
    fieldValues.add("DLNA.ORG_FLAGS=" + getFileProfileFlags(transcoded, live, fileType));
    return CollectionUtils.listToCSV(fieldValues, ";", false);
  }

  public String buildProfileProtocolInfo(MediaFileType fileType)
  {
    List!(String) fieldValues = new ArrayList!(String)();
    if (profileName !is null) {
      fieldValues.add("DLNA.ORG_PN=" + profileName);
    }
    fieldValues.add("DLNA.ORG_OP=" + getProfileOperations(fileType));
    fieldValues.add("DLNA.ORG_FLAGS=" + getProfileFlags(fileType));
    return CollectionUtils.listToCSV(fieldValues, ";", false);
  }

  private String getFileOperations(bool transcoded, bool live, MediaFileType fileType, bool durationAvailable)
  {
    if (fileType == MediaFileType.IMAGE)
      return "00";
    if ((fileType == MediaFileType.AUDIO) || (fileType == MediaFileType.VIDEO)) {
      if (live)
      {
        return "00";
      }
      if (transcoded) {
        if (durationAvailable) {
          return "10";
        }
        return "00";
      }

      return "01";
    }

    return "00";
  }

  private String getProfileOperations(MediaFileType fileType)
  {
    if (fileType == MediaFileType.IMAGE)
      return "00";
    if (fileType == MediaFileType.AUDIO)
      return "01";
    if (fileType == MediaFileType.VIDEO) {
      return "11";
    }
    return "00";
  }

  private String getFileProfileFlags(bool transcoded, bool live, MediaFileType fileType)
  {
    if (fileType == MediaFileType.IMAGE)
      return generateFlagsHexNumber(Long.parseLong("00000000110100000000000000000000", 2));
    if ((fileType == MediaFileType.AUDIO) || (fileType == MediaFileType.VIDEO)) {
      if (live) {
        return generateFlagsHexNumber(Long.parseLong("10001101010100000000000000000000", 2));
      }
      return generateFlagsHexNumber(Long.parseLong("00000001010100000000000000000000", 2));
    }

    return "*";
  }

  private String getProfileFlags(MediaFileType fileType)
  {
    if (fileType == MediaFileType.IMAGE)
      return generateFlagsHexNumber(Long.parseLong("00000000110100000000000000000000", 2));
    if ((fileType == MediaFileType.AUDIO) || (fileType == MediaFileType.VIDEO)) {
      return generateFlagsHexNumber(Long.parseLong("10000001010100000000000000000000", 2));
    }
    return "*";
  }

  protected String generateFlagsHexNumber(long primaryFlags)
  {
    return String.format("%08X%s", cast(Object[])[ Long.valueOf(primaryFlags), "000000000000000000000000" ]);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.DLNAProtocolAdditionalInfo
 * JD-Core Version:    0.6.2
 */