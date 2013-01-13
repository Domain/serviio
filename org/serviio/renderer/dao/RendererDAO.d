module org.serviio.renderer.dao.RendererDAO;

import java.util.List;
import org.serviio.db.dao.InvalidArgumentException;
import org.serviio.db.dao.PersistenceException;
import org.serviio.renderer.entities.Renderer;

public abstract interface RendererDAO
{
  public abstract void create(Renderer paramRenderer);

  public abstract Renderer read(String paramString);

  public abstract void update(Renderer paramRenderer);

  public abstract void delete_(String paramString);

  public abstract List!(Renderer) findByIPAddress(String paramString);

  public abstract List!(Renderer) findAll();
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.renderer.dao.RendererDAO
 * JD-Core Version:    0.6.2
 */