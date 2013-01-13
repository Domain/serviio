module org.serviio.ui.representation.RendererRepresentation;

public class RendererRepresentation
  : Comparable!(RendererRepresentation)
{
  private String uuid;
  private String ipAddress;
  private String name;
  private String profileId;
  private RendererStatus status;
  private bool enabled;
  private Long accessGroupId;

  public this()
  {
  }

  public this(String uuid, String ipAddress, String name, String profileId, RendererStatus status, bool enabled, Long accessGroupId)
  {
    this.uuid = uuid;
    this.ipAddress = ipAddress;
    this.name = name;
    this.profileId = profileId;
    this.status = status;
    this.enabled = enabled;
    this.accessGroupId = accessGroupId;
  }

  public String getIpAddress() {
    return ipAddress;
  }

  public void setIpAddress(String ipAddress) {
    this.ipAddress = ipAddress;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getProfileId() {
    return profileId;
  }

  public void setProfileId(String profileId) {
    this.profileId = profileId;
  }

  public RendererStatus getStatus() {
    return status;
  }

  public void setStatus(RendererStatus status) {
    this.status = status;
  }

  public String getUuid() {
    return uuid;
  }

  public void setUuid(String uuid) {
    this.uuid = uuid;
  }

  public bool isEnabled() {
    return enabled;
  }

  public void setEnabled(bool enabled) {
    this.enabled = enabled;
  }

  public Long getAccessGroupId() {
    return accessGroupId;
  }

  public void setAccessGroupId(Long accessGroupId) {
    this.accessGroupId = accessGroupId;
  }

  public int compareTo(RendererRepresentation o)
  {
    return ipAddress.compareTo(o.getIpAddress());
  }

  public static enum RendererStatus
  {
    ACTIVE, INACTIVE, UNKNOWN
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.representation.RendererRepresentation
 * JD-Core Version:    0.6.2
 */