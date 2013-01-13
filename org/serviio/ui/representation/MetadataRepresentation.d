module org.serviio.ui.representation.MetadataRepresentation;

public class MetadataRepresentation
{
  private bool audioLocalArtExtractorEnabled;
  private bool videoLocalArtExtractorEnabled;
  private bool videoOnlineArtExtractorEnabled;
  private bool videoGenerateLocalThumbnailEnabled;
  private bool imageGenerateLocalThumbnailEnabled;
  private String metadataLanguage;
  private String descriptiveMetadataExtractor;
  private bool retrieveOriginalTitle;

  public bool isAudioLocalArtExtractorEnabled()
  {
    return audioLocalArtExtractorEnabled;
  }
  public void setAudioLocalArtExtractorEnabled(bool audioLocalArtExtractorEnabled) {
    this.audioLocalArtExtractorEnabled = audioLocalArtExtractorEnabled;
  }
  public bool isVideoLocalArtExtractorEnabled() {
    return videoLocalArtExtractorEnabled;
  }
  public void setVideoLocalArtExtractorEnabled(bool videoLocalArtExtractorEnabled) {
    this.videoLocalArtExtractorEnabled = videoLocalArtExtractorEnabled;
  }
  public bool isVideoOnlineArtExtractorEnabled() {
    return videoOnlineArtExtractorEnabled;
  }
  public void setVideoOnlineArtExtractorEnabled(bool videoOnlineArtExtractorEnabled) {
    this.videoOnlineArtExtractorEnabled = videoOnlineArtExtractorEnabled;
  }
  public bool isVideoGenerateLocalThumbnailEnabled() {
    return videoGenerateLocalThumbnailEnabled;
  }
  public void setVideoGenerateLocalThumbnailEnabled(bool videoGenerateLocalThumbnailEnabled) {
    this.videoGenerateLocalThumbnailEnabled = videoGenerateLocalThumbnailEnabled;
  }
  public String getMetadataLanguage() {
    return metadataLanguage;
  }
  public void setMetadataLanguage(String metadataLanguage) {
    this.metadataLanguage = metadataLanguage;
  }
  public String getDescriptiveMetadataExtractor() {
    return descriptiveMetadataExtractor;
  }
  public void setDescriptiveMetadataExtractor(String descriptionMetadataExtractor) {
    descriptiveMetadataExtractor = descriptionMetadataExtractor;
  }
  public bool isRetrieveOriginalTitle() {
    return retrieveOriginalTitle;
  }
  public void setRetrieveOriginalTitle(bool retrieveOriginalTitle) {
    this.retrieveOriginalTitle = retrieveOriginalTitle;
  }
  public bool isImageGenerateLocalThumbnailEnabled() {
    return imageGenerateLocalThumbnailEnabled;
  }
  public void setImageGenerateLocalThumbnailEnabled(bool imageGenerateLocalThumbnailEnabled) {
    this.imageGenerateLocalThumbnailEnabled = imageGenerateLocalThumbnailEnabled;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.ui.representation.MetadataRepresentation
 * JD-Core Version:    0.6.2
 */