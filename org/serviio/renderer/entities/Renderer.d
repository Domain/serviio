module org.serviio.renderer.entities.Renderer;

import java.lang.String;
import java.lang.Long;

public class Renderer
{
	private String uuid;
	private String ipAddress;
	private String name;
	private String profileId;
	private bool manuallyAdded;
	private bool forcedProfile;
	private bool enabled = true;
	private Long accessGroupId;

	public this(String uuid, String ipAddress, String name, String profileId, bool manuallyAdded, bool forcedProfile, bool enabled, Long accessGroupId)
	{
		this.uuid = uuid;
		this.ipAddress = ipAddress;
		this.name = name;
		this.profileId = profileId;
		this.manuallyAdded = manuallyAdded;
		this.forcedProfile = forcedProfile;
		this.enabled = enabled;
		this.accessGroupId = accessGroupId;
	}

	public String getUuid()
	{
		return uuid;
	}

	public String getIpAddress() {
		return ipAddress;
	}

	public String getName() {
		return name;
	}

	public String getProfileId() {
		return profileId;
	}

	public void setProfileId(String forcedProfileId) {
		profileId = forcedProfileId;
	}

	public void setIpAddress(String ipAddress) {
		this.ipAddress = ipAddress;
	}

	public bool isManuallyAdded() {
		return manuallyAdded;
	}

	public void setName(String name) {
		this.name = name;
	}

	public bool isForcedProfile() {
		return forcedProfile;
	}

	public void setForcedProfile(bool forcedProfile) {
		this.forcedProfile = forcedProfile;
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

	public override hash_t toHash()
	{
		int prime = 31;
		int result = 1;
		result = prime * result + (uuid is null ? 0 : uuid.hashCode());
		return result;
	}

	public override equals_t opEquals(Object obj)
	{
		if (this == obj)
			return true;
		if (obj is null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Renderer other = cast(Renderer)obj;
		if (uuid is null) {
			if (other.uuid !is null)
				return false;
		} else if (!uuid.equals(other.uuid))
			return false;
		return true;
	}

	override public String toString()
	{
		StringBuilder builder = new StringBuilder();
		builder.append("Renderer [uuid=").append(uuid).append(", ipAddress=").append(ipAddress).append(", name=").append(name).append(", profileId=").append(profileId).append(", manuallyAdded=").append(manuallyAdded).append(", forcedProfile=").append(forcedProfile).append(", enabled=").append(enabled).append(", accessGroupId=").append(accessGroupId).append("]");

		return builder.toString();
	}
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.renderer.entities.Renderer
* JD-Core Version:    0.6.2
*/