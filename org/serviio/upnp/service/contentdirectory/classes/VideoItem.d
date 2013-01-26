module org.serviio.upnp.service.contentdirectory.classes.VideoItem;

import java.lang.String;
import java.net.URI;
import java.util.Map;
import org.serviio.library.local.ContentType;
import org.serviio.library.local.OnlineDBIdentifier;
import org.serviio.upnp.service.contentdirectory.classes.Item;
import org.serviio.upnp.service.contentdirectory.classes.ObjectClassType;
import org.serviio.upnp.service.contentdirectory.classes.Resource;

public class VideoItem : Item
{
    protected String genre;
    protected String longDescription;
    protected String[] producers;
    protected String rating;
    protected String[] actors;
    protected String[] directors;
    protected String description;
    protected String[] publishers;
    protected String language;
    protected URI relation;
    protected String date;
    protected Resource subtitlesUrlResource;
    protected bool live;
    protected Map!(OnlineDBIdentifier, String) onlineIdentifiers;
    protected ContentType contentType;

    public this(String id, String title)
    {
        super(id, title);
    }

    override public ObjectClassType getObjectClass()
    {
        return ObjectClassType.VIDEO_ITEM;
    }

    public String getGenre()
    {
        return genre;
    }
    public void setGenre(String genre) {
        this.genre = genre;
    }
    public String getLongDescription() {
        return longDescription;
    }
    public void setLongDescription(String longDescription) {
        this.longDescription = longDescription;
    }
    public String[] getProducers() {
        return producers;
    }
    public void setProducers(String[] producer) {
        producers = producer;
    }
    public String getRating() {
        return rating;
    }
    public void setRating(String rating) {
        this.rating = rating;
    }
    public String[] getActors() {
        return actors;
    }
    public void setActors(String[] actor) {
        actors = actor;
    }
    public String[] getDirectors() {
        return directors;
    }
    public void setDirectors(String[] director) {
        directors = director;
    }
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }
    public String[] getPublishers() {
        return publishers;
    }
    public void setPublishers(String[] publisher) {
        publishers = publisher;
    }
    public String getLanguage() {
        return language;
    }
    public void setLanguage(String language) {
        this.language = language;
    }
    public URI getRelation() {
        return relation;
    }
    public void setRelation(URI relation) {
        this.relation = relation;
    }
    public String getDate() {
        return date;
    }
    public void setDate(String date) {
        this.date = date;
    }

    public Resource getSubtitlesUrlResource() {
        return subtitlesUrlResource;
    }

    public void setSubtitlesUrlResource(Resource subtitlesUrl) {
        subtitlesUrlResource = subtitlesUrl;
    }

    public bool getLive() {
        return live;
    }

    public void setLive(bool live) {
        this.live = live;
    }

    public Map!(OnlineDBIdentifier, String) getOnlineIdentifiers() {
        return onlineIdentifiers;
    }

    public void setOnlineIdentifiers(Map!(OnlineDBIdentifier, String) onlineIdentifiers) {
        this.onlineIdentifiers = onlineIdentifiers;
    }

    public ContentType getContentType() {
        return contentType;
    }

    public void setContentType(ContentType contentType) {
        this.contentType = contentType;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.VideoItem
* JD-Core Version:    0.6.2
*/