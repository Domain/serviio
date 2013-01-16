module org.serviio.profile.ProfileManager;

import java.lang.String;
import java.io.InputStream;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map : Entry;
import java.util.regex.Pattern;
import org.apache.http.Header;
import org.serviio.renderer.RendererManager;
import org.serviio.renderer.entities.Renderer;
import org.serviio.util.FileUtils;
import org.serviio.profile.Profile;
import org.serviio.profile.DetectionDefinition;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ProfileManager
{
	private static List!(Profile) profiles = new ArrayList!(Profile)();
	public static const String DEFAULT_PROFILE_ID = "1";
	private static const String PROFILES_XML_PATH = "/profiles.xml";
	private static const String APP_PROFILES_XML_PATH = "/application-profiles.xml";
	private static immutable Logger log;

	static this()
	{
		log = LoggerFactory.getLogger!(ProfileManager)();
	}

	public static Profile getProfile(InetAddress clientIPAddress)
	{
		Renderer renderer = RendererManager.getInstance().getStoredRendererByIPAddress(clientIPAddress);
		return getProfile(renderer);
	}

	public static Profile getProfile(String clientIPAddress) {
		try {
			return getProfile(Inet4Address.getByName(clientIPAddress));
		} catch (UnknownHostException e) {
			log.warn("Cannot parse IP address for: " + clientIPAddress);
		}return getProfileById(DEFAULT_PROFILE_ID);
	}

	public static Profile getProfile(Renderer renderer)
	{
		if (renderer !is null)
		{
			return getProfileById(renderer.getProfileId());
		}
		log.debug_("Cannot find stored renderer, using Generic");

		return getProfileById("1");
	}

	public static Profile findProfileByDescription(String friendlyName, String modelName, String modelNumber, String productCode, String serverName, String manufacturer)
	{
		foreach (Profile profile ; profiles) {
			DetectionDefinition detectionDef = getDetectionDefinitionByType(profile, DetectionDefinition.DetectionType.UPNP_SEARCH);
			if (detectionDef !is null) {
				bool profileMatches = true;
				foreach (Entry!(String, String) entry ; detectionDef.getFieldValues().entrySet()) {
					if ((cast(String)entry.getKey()).equalsIgnoreCase("FriendlyName"))
						profileMatches = (profileMatches) && (detectionFieldMatches(cast(String)entry.getValue(), friendlyName));
					else if ((cast(String)entry.getKey()).equalsIgnoreCase("ModelName"))
						profileMatches = (profileMatches) && (detectionFieldMatches(cast(String)entry.getValue(), modelName));
					else if ((cast(String)entry.getKey()).equalsIgnoreCase("ModelNumber"))
						profileMatches = (profileMatches) && (detectionFieldMatches(cast(String)entry.getValue(), modelNumber));
					else if ((cast(String)entry.getKey()).equalsIgnoreCase("Manufacturer"))
						profileMatches = (profileMatches) && (detectionFieldMatches(cast(String)entry.getValue(), manufacturer));
					else if ((cast(String)entry.getKey()).equalsIgnoreCase("ProductCode"))
						profileMatches = (profileMatches) && (detectionFieldMatches(cast(String)entry.getValue(), productCode));
					else if ((cast(String)entry.getKey()).equalsIgnoreCase("Server")) {
						profileMatches = (profileMatches) && (detectionFieldMatches(cast(String)entry.getValue(), serverName));
					}
				}
				if (profileMatches) {
					return profile;
				}
			}
		}
		return null;
	}

	public static Profile findProfileByHeader(Header[] headers) {
		for (Iterator!(Profile) i = profiles.iterator(); i.hasNext(); ) { Profile profile = cast(Profile)i.next();
			DetectionDefinition detectionDef = getDetectionDefinitionByType(profile, DetectionDefinition.DetectionType.HTTP_HEADERS);
			if (detectionDef !is null)
				foreach (Entry!(String, String) entry ; detectionDef.getFieldValues().entrySet())
					foreach (Header header ; headers)
						if (((cast(String)entry.getKey()).trim().equalsIgnoreCase(header.getName().trim())) && (Pattern.compile((cast(String)entry.getValue()).trim(), 2).matcher(header.getValue().trim()).matches()))
						{
							return profile;
						}
		}
		return null;
	}

	public static Profile getProfileById(String id)
	{
		foreach (Profile profile ; profiles) {
			if (profile.getId().equals(id)) {
				return profile;
			}
		}
		return null;
	}

	public static void loadProfiles()
	{
		profiles = parseProfilesFromFile(PROFILES_XML_PATH, new ArrayList!(Profile)());
		profiles = parseProfilesFromFile(APP_PROFILES_XML_PATH, profiles);
	}

	public static List!(Profile) getAllProfiles() {
		return profiles;
	}

	public static List!(Profile) getAllSelectableProfiles() {
		List!(Profile) selectableProfiles = new ArrayList!(Profile)();
		foreach (Profile profile ; profiles) {
			if (profile.isSelectable()) {
				selectableProfiles.add(profile);
			}
		}
		return selectableProfiles;
	}

	private static List!(Profile) parseProfilesFromFile(String fileName, List!(Profile) currentProfiles)
	{
		InputStream definitionStream = ProfileManager.class_.getResourceAsStream(fileName);
		try {
			return ProfilesDefinitionParser.parseDefinition(definitionStream, currentProfiles);
		} catch (ProfilesDefinitionException e) {
			throw new RuntimeException(e);
		} finally {
			FileUtils.closeQuietly(definitionStream);
		}
	}

	private static bool detectionFieldMatches(String detectionFieldValue, String fieldValue) {
		if ((fieldValue !is null) && (Pattern.compile(detectionFieldValue, 2).matcher(fieldValue).matches())) {
			return true;
		}
		return false;
	}

	private static DetectionDefinition getDetectionDefinitionByType(Profile profile, DetectionDefinition.DetectionType type) {
		if (profile.getDetectionDefinitions() !is null) {
			foreach (DetectionDefinition dd ; profile.getDetectionDefinitions()) {
				if (dd.getType() == type) {
					return dd;
				}
			}
		}
		return null;
	}
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.profile.ProfileManager
* JD-Core Version:    0.6.2
*/