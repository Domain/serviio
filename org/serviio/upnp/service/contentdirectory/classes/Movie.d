module org.serviio.upnp.service.contentdirectory.classes.Movie;

import java.util.Date;

public class Movie : VideoItem
{
  protected String storageMedium;
  protected String DVDRegionCode;
  protected String[] channelName;
  protected Date scheduledStartTime;
  protected Date scheduledEndTime;

  public this(String id, String title)
  {
    super(id, title);
  }

  public ObjectClassType getObjectClass()
  {
    return ObjectClassType.MOVIE;
  }

  public String getStorageMedium()
  {
    return storageMedium;
  }

  public void setStorageMedium(String storageMedium) {
    this.storageMedium = storageMedium;
  }

  public String getDVDRegionCode() {
    return DVDRegionCode;
  }

  public void setDVDRegionCode(String dVDRegionCode) {
    DVDRegionCode = dVDRegionCode;
  }

  public String[] getChannelName() {
    return channelName;
  }

  public void setChannelName(String[] channelName) {
    this.channelName = channelName;
  }

  public Date getScheduledStartTime() {
    return scheduledStartTime;
  }

  public void setScheduledStartTime(Date scheduledStartTime) {
    this.scheduledStartTime = scheduledStartTime;
  }

  public Date getScheduledEndTime() {
    return scheduledEndTime;
  }

  public void setScheduledEndTime(Date scheduledEndTime) {
    this.scheduledEndTime = scheduledEndTime;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.classes.Movie
 * JD-Core Version:    0.6.2
 */