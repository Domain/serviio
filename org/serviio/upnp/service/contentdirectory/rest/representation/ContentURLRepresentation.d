module org.serviio.upnp.service.contentdirectory.rest.representation.ContentURLRepresentation;

import com.thoughtworks.xstream.annotations.XStreamConverter;
import com.thoughtworks.xstream.converters.extended.ToAttributedValueConverter;
import java.lang.String;
import java.lang.Long;
import org.serviio.profile.DeliveryQuality;

//@XStreamConverter(value=ToAttributedValueConverter.class_, strings={"url"})
public class ContentURLRepresentation
{
	private String quality;
	private String url;
	private String resolution;
	private bool preferred;
	private bool transcoded;
	private Long fileSize;

	public this(DeliveryQuality.QualityType quality, String url)
	{
		this.quality = quality.toString();
		this.url = url;
	}

	public String getQuality() {
		return quality;
	}

	public void setQuality(String quality) {
		this.quality = quality;
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public String getResolution() {
		return resolution;
	}

	public void setResolution(String resolution) {
		this.resolution = resolution;
	}

	public bool isPreferred() {
		return preferred;
	}

	public void setPreferred(bool preferred) {
		this.preferred = preferred;
	}

	public bool isTranscoded() {
		return transcoded;
	}

	public void setTranscoded(bool transcoded) {
		this.transcoded = transcoded;
	}

	public Long getFileSize() {
		return fileSize;
	}

	public void setFileSize(Long fileSize) {
		this.fileSize = fileSize;
	}
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.service.contentdirectory.rest.representation.ContentURLRepresentation
* JD-Core Version:    0.6.2
*/