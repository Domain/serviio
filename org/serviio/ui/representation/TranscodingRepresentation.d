module org.serviio.ui.representation.TranscodingRepresentation;

import java.lang.String;
import java.lang.Integer;

public class TranscodingRepresentation
{
    private bool audioDownmixing;
    private Integer threadsNumber;
    private String transcodingFolderLocation;
    private bool transcodingEnabled;
    private bool bestVideoQuality;

    public bool isAudioDownmixing()
    {
        return audioDownmixing;
    }
    public void setAudioDownmixing(bool audioDownmixing) {
        this.audioDownmixing = audioDownmixing;
    }
    public Integer getThreadsNumber() {
        return threadsNumber;
    }
    public void setThreadsNumber(Integer threadsNumber) {
        this.threadsNumber = threadsNumber;
    }
    public String getTranscodingFolderLocation() {
        return transcodingFolderLocation;
    }
    public void setTranscodingFolderLocation(String transcodingFolderLocation) {
        this.transcodingFolderLocation = transcodingFolderLocation;
    }
    public bool isTranscodingEnabled() {
        return transcodingEnabled;
    }
    public void setTranscodingEnabled(bool transcodingEnabled) {
        this.transcodingEnabled = transcodingEnabled;
    }
    public bool isBestVideoQuality() {
        return bestVideoQuality;
    }
    public void setBestVideoQuality(bool bestVideoQuality) {
        this.bestVideoQuality = bestVideoQuality;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.ui.representation.TranscodingRepresentation
* JD-Core Version:    0.6.2
*/