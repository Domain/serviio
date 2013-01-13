module org.serviio.library.dao.AbstractSortableItemDao;

import org.serviio.util.StringUtils;

public abstract class AbstractSortableItemDao : AbstractAccessibleDao
{
  protected String createSortName(String name)
  {
    if (name !is null) {
      return StringUtils.removeAccents(StringUtils.removeArticles(name)).trim();
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.AbstractSortableItemDao
 * JD-Core Version:    0.6.2
 */