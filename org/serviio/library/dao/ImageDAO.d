module org.serviio.library.dao.ImageDAO;

import java.util.List;
import org.serviio.db.dao.GenericDAO;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.Image;

public abstract interface ImageDAO : GenericDAO!(Image)
{
  public abstract List!(Image) retrieveImagesForFolder(Long paramLong, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveImagesForFolderCount(Long paramLong, AccessGroup paramAccessGroup);

  public abstract List!(Integer) retrieveImagesCreationYears(AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveImagesCreationYearsCount(AccessGroup paramAccessGroup);

  public abstract List!(Image) retrieveImagesForYear(Integer paramInteger, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveImagesForYearCount(Integer paramInteger, AccessGroup paramAccessGroup);

  public abstract List!(Integer) retrieveImagesCreationMonths(Integer paramInteger, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveImagesCreationMonthsCount(Integer paramInteger, AccessGroup paramAccessGroup);

  public abstract List!(Image) retrieveImagesForMonthOfYear(Integer paramInteger1, Integer paramInteger2, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveImagesForMonthOfYearCount(Integer paramInteger1, Integer paramInteger2, AccessGroup paramAccessGroup);

  public abstract List!(Image) retrieveAllImages(AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveAllImagesCount(AccessGroup paramAccessGroup);

  public abstract List!(Image) retrieveImagesForPlaylist(Long paramLong, AccessGroup paramAccessGroup, int paramInt1, int paramInt2);

  public abstract int retrieveImagesForPlaylistCount(Long paramLong, AccessGroup paramAccessGroup);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.ImageDAO
 * JD-Core Version:    0.6.2
 */