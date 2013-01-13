module org.serviio.renderer.ActiveRenderer;

import java.util.Date;
import org.serviio.renderer.entities.Renderer;

public class ActiveRenderer
{
  private Renderer renderer;
  private int timeToLive = 0;
  private Date lastUpdated;

  public this(Renderer renderer, int timeToLive, Date lastUpdated)
  {
    this.renderer = renderer;
    this.timeToLive = timeToLive;
    this.lastUpdated = lastUpdated;
  }

  public Renderer getRenderer() {
    return renderer;
  }

  public void setRenderer(Renderer renderer) {
    this.renderer = renderer;
  }

  public int getTimeToLive() {
    return timeToLive;
  }

  public void setTimeToLive(int timeToLive) {
    this.timeToLive = timeToLive;
  }

  public Date getLastUpdated() {
    return lastUpdated;
  }

  public void setLastUpdated(Date lastUpdated) {
    this.lastUpdated = lastUpdated;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.renderer.ActiveRenderer
 * JD-Core Version:    0.6.2
 */