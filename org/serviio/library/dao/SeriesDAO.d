module org.serviio.library.dao.SeriesDAO;

import java.util.List;
import org.serviio.db.dao.GenericDAO;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Series;

public abstract interface SeriesDAO : GenericDAO!(Series)
{
  public abstract Series findSeriesByName(String paramString);

  public abstract int getNumberOfEpisodes(Long paramLong);

  public abstract List!(Series) retrieveSeries(int paramInt1, int paramInt2);

  public abstract int getSeriesCount();

  public abstract List!(Integer) retrieveSeasonsForSeries(Long paramLong, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int getSeasonsForSeriesCount(Long paramLong, AccessGroup paramAccessGroup);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.SeriesDAO
 * JD-Core Version:    0.6.2
 */