module org.serviio.upnp.service.contentdirectory.rest.representation.DirectoryObjectRepresentation;

import com.thoughtworks.xstream.annotations.XStreamAsAttribute;
import java.lang.String;
import java.lang.Integer;
import java.util.List;
import org.serviio.library.local.ContentType;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.upnp.service.contentdirectory.rest.representation.ContentURLRepresentation;
import org.serviio.upnp.service.contentdirectory.rest.representation.OnlineIdentifierRepresentation;

public class DirectoryObjectRepresentation
{

	//@XStreamAsAttribute
	private String id;

	//@XStreamAsAttribute
	private DirectoryObjectType type;

	//@XStreamAsAttribute
	private MediaFileType fileType;

	//@XStreamAsAttribute
	private Integer childCount;

	//@XStreamAsAttribute
	private String parentId;
	private String title;
	private String description;
	private String genre;
	private String date;
	private String artist;
	private String album;
	private Integer originalTrackNumber;
	private Integer duration;
	private String thumbnailUrl;
	private List!(ContentURLRepresentation) contentUrls;
	private String subtitlesUrl;
	private bool live;
	private List!(OnlineIdentifierRepresentation) onlineIdentifiers;
	private ContentType contentType;

	public this(DirectoryObjectType type, String title, String id)
	{
		this.type = type;
		this.title = title;
		this.id = id;
	}

	public DirectoryObjectType getType()
	{
		return type;
	}

	public void setType(DirectoryObjectType type) {
		this.type = type;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public Integer getChildCount() {
		return childCount;
	}

	public void setChildCount(Integer childrenCount) {
		childCount = childrenCount;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getParentId() {
		return parentId;
	}

	public void setParentId(String parentId) {
		this.parentId = parentId;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getGenre() {
		return genre;
	}

	public void setGenre(String genre) {
		this.genre = genre;
	}

	public String getThumbnailUrl() {
		return thumbnailUrl;
	}

	public List!(ContentURLRepresentation) getContentUrls() {
		return contentUrls;
	}

	public void setContentUrls(List!(ContentURLRepresentation) contentUrls) {
		this.contentUrls = contentUrls;
	}

	public void setThumbnailUrl(String thumbnailUrl) {
		this.thumbnailUrl = thumbnailUrl;
	}

	public String getDate() {
		return date;
	}

	public void setDate(String date) {
		this.date = date;
	}

	public Integer getOriginalTrackNumber() {
		return originalTrackNumber;
	}

	public void setOriginalTrackNumber(Integer originalTrackNumber) {
		this.originalTrackNumber = originalTrackNumber;
	}

	public MediaFileType getFileType() {
		return fileType;
	}

	public void setFileType(MediaFileType fileType) {
		this.fileType = fileType;
	}

	public String getSubtitlesUrl() {
		return subtitlesUrl;
	}

	public void setSubtitlesUrl(String subtitlesUrl) {
		this.subtitlesUrl = subtitlesUrl;
	}

	public String getArtist() {
		return artist;
	}

	public void setArtist(String artist) {
		this.artist = artist;
	}

	public String getAlbum() {
		return album;
	}

	public void setAlbum(String album) {
		this.album = album;
	}

	public Integer getDuration() {
		return duration;
	}

	public void setDuration(Integer duration) {
		this.duration = duration;
	}

	public bool getLive() {
		return live;
	}

	public void setLive(bool live) {
		this.live = live;
	}

	public List!(OnlineIdentifierRepresentation) getOnlineIdentifiers() {
		return onlineIdentifiers;
	}

	public void setOnlineIdentifiers(List!(OnlineIdentifierRepresentation) onlineIdentifiers) {
		this.onlineIdentifiers = onlineIdentifiers;
	}

	public ContentType getContentType() {
		return contentType;
	}

	public void setContentType(ContentType contentType) {
		this.contentType = contentType;
	}

	public static enum DirectoryObjectType
	{
		CONTAINER, ITEM
	}
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.service.contentdirectory.rest.representation.DirectoryObjectRepresentation
* JD-Core Version:    0.6.2
*/