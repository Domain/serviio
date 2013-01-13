module org.serviio.library.dao.PersonDAO;

import java.util.List;
import org.serviio.library.entities.Person;
import org.serviio.library.entities.Person : RoleType;

public abstract interface PersonDAO
{
  public abstract Person findPersonByName(String paramString);

  public abstract Person findPersonById(Long paramLong);

  public abstract Long addPersonToMedia(String paramString, RoleType paramRoleType, Long paramLong);

  public abstract Long addPersonToMusicAlbum(String paramString, RoleType paramRoleType, Long paramLong);

  public abstract void removeAllPersonsFromMedia(Long paramLong);

  public abstract void removeAllPersonsFromMusicAlbum(Long paramLong);

  public abstract void removePersonsAndRoles(List!(Long) paramList);

  public abstract List!(Person) retrievePersonsWithRole(RoleType paramRoleType, int paramInt1, int paramInt2);

  public abstract int getPersonsWithRoleCount(RoleType paramRoleType);

  public abstract int getRoleForPersonCount(Long paramLong);

  public abstract List!(Person) retrievePersonsWithRoleForMediaItem(RoleType paramRoleType, Long paramLong);

  public abstract List!(Person) retrievePersonsWithRoleForMusicAlbum(RoleType paramRoleType, Long paramLong);

  public abstract List!(Person) retrievePersonsForMediaItem(Long paramLong);

  public abstract List!(Person) retrievePersonsForMusicAlbum(Long paramLong);

  public abstract Long getPersonRoleForMediaItem(RoleType paramRoleType, Long paramLong1, Long paramLong2);

  public abstract Long getPersonRoleForMusicAlbum(RoleType paramRoleType, Long paramLong1, Long paramLong2);

  public abstract List!(Long) getRoleIDsForMediaItem(RoleType paramRoleType, Long paramLong);

  public abstract List!(String) retrievePersonInitials(RoleType paramRoleType, int paramInt1, int paramInt2);

  public abstract int retrievePersonInitialsCount(RoleType paramRoleType);

  public abstract List!(Person) retrievePersonsForInitial(String paramString, RoleType paramRoleType, int paramInt1, int paramInt2);

  public abstract int retrievePersonsForInitialCount(String paramString, RoleType paramRoleType);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.PersonDAO
 * JD-Core Version:    0.6.2
 */