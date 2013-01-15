module org.serviio.library.dao.PersonDAOImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import org.serviio.db.DatabaseManager;
import org.serviio.db.dao.InvalidArgumentException;
import org.serviio.db.dao.PersistenceException;
import org.serviio.library.entities.Person;
import org.serviio.library.entities.Person : RoleType;
import org.serviio.util.JdbcUtils;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PersonDAOImpl : AbstractSortableItemDao
  , PersonDAO
{
  private static final Logger log = LoggerFactory.getLogger!(PersonDAOImpl)();

  public Person findPersonByName(String name)
  {
    log.debug_(String.format("Reading a Person (name = %s)", cast(Object[])[ name ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, name, sort_name, initial FROM person where name = ?");
      ps.setString(1, name);
      ResultSet rs = ps.executeQuery();
      return mapSingleResult(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read Person with name = %s", cast(Object[])[ name ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public Person findPersonById(Long id)
  {
    log.debug_(String.format("Reading a Person (id = %s)", cast(Object[])[ id ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT id, name, sort_name, initial FROM person where id = ?");
      ps.setLong(1, id.longValue());
      ResultSet rs = ps.executeQuery();
      return mapSingleResult(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read Person with id = %s", cast(Object[])[ id ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public Long addPersonToMedia(String personName, RoleType role, Long mediaItemId)
  {
    if ((ObjectValidator.isEmpty(personName)) || (mediaItemId is null)) {
      log.debug_("Cannot add person to media item. Required data is missing.");
      return null;
    }
    log.debug_(String.format("Adding a Person %s to media item %s as %s", cast(Object[])[ personName, mediaItemId, role.toString() ]));

    Person person = findPersonByName(personName);

    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      Long personId = null;
      if (person is null)
      {
        personId = Long.valueOf(createPerson(con, new Person(personName, createSortName(personName), createInitial(personName))));
      }
      else personId = person.getId();

      Long roleId = getPersonRoleForMediaItem(role, personId, mediaItemId);
      if (roleId is null)
      {
        ps = con.prepareStatement("INSERT INTO person_role (ROLE_TYPE, PERSON_ID, MEDIA_ITEM_ID) VALUES (?,?,?)", 1);
        ps.setString(1, role.toString());
        ps.setLong(2, personId.longValue());
        ps.setLong(3, mediaItemId.longValue());
        ps.executeUpdate();
        return Long.valueOf(JdbcUtils.retrieveGeneratedID(ps));
      }
      return roleId;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot add Person with name %s to media item %s", cast(Object[])[ personName, mediaItemId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public Long addPersonToMusicAlbum(String personName, RoleType role, Long albumId) {
    if ((ObjectValidator.isEmpty(personName)) || (albumId is null)) {
      log.debug_("Cannot add person to media item. Required data is missing.");
      return null;
    }
    log.debug_(String.format("Adding a Person %s to album %s as %s", cast(Object[])[ personName, albumId, role.toString() ]));

    Person person = findPersonByName(personName);

    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      Long personId = null;
      if (person is null)
      {
        personId = Long.valueOf(createPerson(con, new Person(personName, createSortName(personName), createInitial(personName))));
      }
      else personId = person.getId();

      Long roleId = getPersonRoleForMusicAlbum(role, personId, albumId);
      if (roleId is null)
      {
        ps = con.prepareStatement("INSERT INTO person_role (ROLE_TYPE, PERSON_ID, MUSIC_ALBUM_ID) VALUES (?,?,?)", 1);
        ps.setString(1, role.toString());
        ps.setLong(2, personId.longValue());
        ps.setLong(3, albumId.longValue());
        ps.executeUpdate();
        return Long.valueOf(JdbcUtils.retrieveGeneratedID(ps));
      }
      return roleId;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot add Person with name %s to music album %s", cast(Object[])[ personName, albumId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void removeAllPersonsFromMedia(Long mediaItemId)
  {
    if (mediaItemId is null) {
      throw new InvalidArgumentException("Cannot remove person from media item. Required data is missing.");
    }
    log.debug_(String.format("Removing all Persons from media item %s", cast(Object[])[ mediaItemId ]));

    List!(Person) persons = retrievePersonsForMediaItem(mediaItemId);

    log.debug_(String.format("Found all Persons (%s) for media item %s", cast(Object[])[ Integer.valueOf(persons.size()), mediaItemId ]));

    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();

      ps = con.prepareStatement("DELETE FROM person_role WHERE media_item_id = ?");
      ps.setLong(1, mediaItemId.longValue());
      ps.executeUpdate();

      foreach (Person person ; persons) {
        int rolesCount = getRoleForPersonCount(person.getId());
        if (rolesCount == 0)
        {
          deletePerson(con, person.getId());
        }
      }
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot remove all Persons from media item %s", cast(Object[])[ mediaItemId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void removeAllPersonsFromMusicAlbum(Long albumId)
  {
    if (albumId is null) {
      throw new InvalidArgumentException("Cannot remove person from music album. Required data is missing.");
    }
    log.debug_(String.format("Removing all Persons from album %s", cast(Object[])[ albumId ]));

    List!(Person) persons = retrievePersonsForMusicAlbum(albumId);

    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();

      ps = con.prepareStatement("DELETE FROM person_role WHERE music_album_id = ?");
      ps.setLong(1, albumId.longValue());
      ps.executeUpdate();

      foreach (Person person ; persons) {
        int rolesCount = getRoleForPersonCount(person.getId());
        if (rolesCount == 0)
        {
          deletePerson(con, person.getId());
        }
      }
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot remove all Persons from musicalbum %s", cast(Object[])[ albumId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public void removePersonsAndRoles(List!(Long) personRoleIds)
  {
    if ((personRoleIds !is null) && (personRoleIds.size() > 0)) {
      log.debug_("Removing person relationships");

      Connection con = null;
      PreparedStatement ps = null;
      try {
        con = DatabaseManager.getConnection();
        List!(Person) referencedPersons = findPersonForPersonRole(con, personRoleIds);

        ps = con.prepareStatement("DELETE FROM person_role WHERE id IN (" + JdbcUtils.createInClause(personRoleIds.size()) + ")");
        for (int i = 1; i <= personRoleIds.size(); i++) {
          ps.setLong(i, (cast(Long)personRoleIds.get(i - 1)).longValue());
        }
        ps.executeUpdate();

        foreach (Person person ; referencedPersons) {
          int rolesCount = getRoleForPersonCount(person.getId());
          if (rolesCount == 0)
          {
            deletePerson(con, person.getId());
          }
        }
      }
      catch (SQLException e) {
        throw new PersistenceException("Cannot remove Person relationships", e);
      } finally {
        JdbcUtils.closeStatement(ps);
        DatabaseManager.releaseConnection(con);
      }
    }
  }

  public List!(Person) retrievePersonsWithRole(RoleType roleType, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of persons with role %s (from=%s, count=%s)", cast(Object[])[ roleType, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount) ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT DISTINCT(p.id) as id, p.name as name, p.sort_name as sort_name, p.initial as initial FROM person p, person_role r WHERE r.person_id = p.id AND r.ROLE_TYPE = ? ORDER BY lower(p.sort_name) OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, roleType.toString());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of  persons with role %s", cast(Object[])[ roleType ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int getPersonsWithRoleCount(RoleType roleType)
  {
    log.debug_(String.format("Retrieving number of persons with role %s", cast(Object[])[ roleType ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT COUNT(DISTINCT p.id) as c FROM person p, person_role r WHERE r.person_id = p.id AND r.ROLE_TYPE = ?");
      ps.setString(1, roleType.toString());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of  persons with role %s", cast(Object[])[ roleType ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int getRoleForPersonCount(Long personId)
  {
    log.debug_(String.format("Retrieving number of roles for person %s", cast(Object[])[ personId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT COUNT(r.id) as count FROM person_role r WHERE r.person_id = ?");
      ps.setLong(1, personId.longValue());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("count"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of roles for person %s", cast(Object[])[ personId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Person) retrievePersonsWithRoleForMediaItem(RoleType roleType, Long mediaItemId)
  {
    log.debug_(String.format("Retrieving list of persons with role %s for MediaItem %s", cast(Object[])[ roleType, mediaItemId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT DISTINCT(p.id) as id, p.name as name, p.sort_name as sort_name, p.initial as initial FROM person p, person_role r WHERE r.person_id = p.id AND r.ROLE_TYPE = ? AND r.media_item_id = ?");

      ps.setString(1, roleType.toString());
      ps.setLong(2, mediaItemId.longValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of persons with role %s for media item %s", cast(Object[])[ roleType, mediaItemId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Person) retrievePersonsWithRoleForMusicAlbum(RoleType roleType, Long albumId)
  {
    log.debug_(String.format("Retrieving list of persons with role %s for MusicAlbum %s", cast(Object[])[ roleType, albumId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT DISTINCT(p.id) as id, p.name as name, p.sort_name as sort_name, p.initial as initial FROM person p, person_role r WHERE r.person_id = p.id AND r.ROLE_TYPE = ? AND r.music_album_id = ?");

      ps.setString(1, roleType.toString());
      ps.setLong(2, albumId.longValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of persons with role %s for music album %s", cast(Object[])[ roleType, albumId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Person) retrievePersonsForMediaItem(Long mediaItemId)
  {
    log.debug_(String.format("Retrieving list of persons for MediaItem %s", cast(Object[])[ mediaItemId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT DISTINCT(p.id) as id, p.name as name, p.sort_name as sort_name, p.initial as initial FROM person p, person_role r WHERE r.person_id = p.id AND r.media_item_id = ?");

      ps.setLong(1, mediaItemId.longValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of persons for media item %s", cast(Object[])[ mediaItemId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Person) retrievePersonsForMusicAlbum(Long albumId)
  {
    log.debug_(String.format("Retrieving list of persons for MusicAlbum %s", cast(Object[])[ albumId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT DISTINCT(p.id) as id, p.name as name, p.sort_name as sort_name, p.initial as initial FROM person p, person_role r WHERE r.person_id = p.id AND r.music_album_id = ?");

      ps.setLong(1, albumId.longValue());
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of persons for music album %s", cast(Object[])[ albumId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public Long getPersonRoleForMediaItem(RoleType role, Long personId, Long mediaItemId)
  {
    if ((personId is null) || (mediaItemId is null) || (role is null)) {
      throw new InvalidArgumentException("Cannot check for person role. Required data is missing.");
    }
    log.debug_(String.format("Checking if person %s has a role %s for media item %s", cast(Object[])[ personId, role.toString(), mediaItemId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT person_role.id as id FROM person_role WHERE person_role.person_id = ? AND person_role.media_item_id = ? AND person_role.role_type = ?");

      ps.setLong(1, personId.longValue());
      ps.setLong(2, mediaItemId.longValue());
      ps.setString(3, role.toString());

      ResultSet rs = ps.executeQuery();
      Long roleId = null;
      if (rs.next()) {
        roleId = Long.valueOf(rs.getLong("id"));
      }
      return roleId;
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot check if person %s has a role %s for media item %s", cast(Object[])[ personId, role.toString(), mediaItemId ]), e);
    }
    finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public Long getPersonRoleForMusicAlbum(RoleType role, Long personId, Long albumId)
  {
    if ((personId is null) || (albumId is null) || (role is null)) {
      throw new InvalidArgumentException("Cannot check for person role. Required data is missing.");
    }
    log.debug_(String.format("Checking if person %s has a role %s for album %s", cast(Object[])[ personId, role.toString(), albumId ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT person_role.id as id FROM person_role WHERE person_role.person_id = ? AND person_role.music_album_id = ? AND person_role.role_type = ?");

      ps.setLong(1, personId.longValue());
      ps.setLong(2, albumId.longValue());
      ps.setString(3, role.toString());

      ResultSet rs = ps.executeQuery();
      Long roleId = null;
      if (rs.next()) {
        roleId = Long.valueOf(rs.getLong("id"));
      }
      return roleId;
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot check if person %s has a role %s for music album %s", cast(Object[])[ personId, role.toString(), albumId ]), e);
    }
    finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Long) getRoleIDsForMediaItem(RoleType role, Long mediaItemId)
  {
    if ((mediaItemId is null) || (role is null)) {
      throw new InvalidArgumentException("Cannot get list of roles. Required data is missing.");
    }
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT person_role.id as id FROM person_role WHERE person_role.media_item_id = ? AND person_role.role_type = ?");

      ps.setLong(1, mediaItemId.longValue());
      ps.setString(2, role.toString());

      ResultSet rs = ps.executeQuery();
      List!(Long) result = new ArrayList!(Long)();
      while (rs.next()) {
        result.add(Long.valueOf(rs.getLong("id")));
      }
      return result;
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot retrieve list or role IDs for role %s for media item %s", cast(Object[])[ role.toString(), mediaItemId ]), e);
    }
    finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(String) retrievePersonInitials(RoleType role, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of person initials (role = %s, from=%s, count=%s)", cast(Object[])[ role, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount) ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT DISTINCT initial as letter from person, person_role WHERE person_role.role_type = ?  and person_role.person_id = person.id ORDER BY letter OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, role.toString());
      ResultSet rs = ps.executeQuery();
      List!(String) result = new ArrayList!(String)();
      while (rs.next()) {
        result.add(rs.getString("letter"));
      }
      return result;
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of person initials for role %s", cast(Object[])[ role ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrievePersonInitialsCount(RoleType role)
  {
    log.debug_(String.format("Retrieving number of person initials for role %s", cast(Object[])[ role ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT COUNT(DISTINCT initial) as c from person, person_role WHERE person_role.role_type = ?  and person_role.person_id = person.id");

      ps.setString(1, role.toString());
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of person initials for role %s", cast(Object[])[ role ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public List!(Person) retrievePersonsForInitial(String initial, RoleType role, int startingIndex, int requestedCount)
  {
    log.debug_(String.format("Retrieving list of persons with initial %s and role %s (from=%s, count=%s)", cast(Object[])[ initial, role, Integer.valueOf(startingIndex), Integer.valueOf(requestedCount) ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT DISTINCT(p.id) as id, p.name as name, p.sort_name as sort_name, p.initial as initial FROM person p, person_role r WHERE r.person_id = p.id AND r.ROLE_TYPE = ? and p.initial = ? ORDER BY lower(p.sort_name) OFFSET " + startingIndex + " ROWS FETCH FIRST " + requestedCount + " ROWS ONLY");

      ps.setString(1, role.toString());
      ps.setString(2, StringUtils.localeSafeToUppercase(initial));
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read list of persons with initial %s and role %s", cast(Object[])[ initial, role ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  public int retrievePersonsForInitialCount(String initial, RoleType role)
  {
    log.debug_(String.format("Retrieving number of persons with initial %s and role %s", cast(Object[])[ initial, role ]));
    Connection con = null;
    PreparedStatement ps = null;
    try {
      con = DatabaseManager.getConnection();
      ps = con.prepareStatement("SELECT count(DISTINCT(p.id)) as c FROM person p, person_role r WHERE r.person_id = p.id AND r.ROLE_TYPE = ? and p.initial = ?");

      ps.setString(1, role.toString());
      ps.setString(2, StringUtils.localeSafeToUppercase(initial));
      ResultSet rs = ps.executeQuery();
      Integer count;
      if (rs.next()) {
        count = Integer.valueOf(rs.getInt("c"));
        return count.intValue();
      }
      return 0;
    }
    catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot read number of persons with initial %s and role %s", cast(Object[])[ initial, role ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
      DatabaseManager.releaseConnection(con);
    }
  }

  private String createInitial(String name)
  {
    if (name !is null) {
      return StringUtils.localeSafeToUppercase(createSortName(name).substring(0, 1));
    }
    return null;
  }

  protected Person mapSingleResult(ResultSet rs)
  {
    if (rs.next()) {
      return initPerson(rs);
    }
    return null;
  }

  protected List!(Person) mapResultSet(ResultSet rs)
  {
    List!(Person) result = new ArrayList!(Person)();
    while (rs.next()) {
      result.add(initPerson(rs));
    }
    return result;
  }

  private Person initPerson(ResultSet rs)
  {
    Long id = Long.valueOf(rs.getLong("id"));
    String name = rs.getString("name");
    String sortName = rs.getString("sort_name");
    String initial = rs.getString("initial");
    Person person = new Person(name, sortName, initial);
    person.setId(id);
    return person;
  }

  private long createPerson(Connection con, Person newInstance) {
    if ((newInstance is null) || (ObjectValidator.isEmpty(newInstance.getName()))) {
      throw new InvalidArgumentException("Cannot create Person. Required data is missing.");
    }
    log.debug_(String.format("Creating a new Person (name = %s)", cast(Object[])[ newInstance.getName() ]));
    PreparedStatement ps = null;
    try {
      ps = con.prepareStatement("INSERT INTO person (name,sort_name, initial) VALUES (?,?,?)", 1);

      ps.setString(1, JdbcUtils.trimToMaxLength(newInstance.getName(), 128));
      ps.setString(2, JdbcUtils.trimToMaxLength(newInstance.getSortName(), 128));
      ps.setString(3, newInstance.getInitial());
      ps.executeUpdate();
      return JdbcUtils.retrieveGeneratedID(ps);
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot create Person with name %s", cast(Object[])[ newInstance.getName() ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
    }
  }

  private void deletePerson(Connection con, Long personId) {
    log.debug_(String.format("Deleting a Person (id = %s)", cast(Object[])[ personId ]));
    PreparedStatement ps = null;
    try {
      ps = con.prepareStatement("DELETE FROM person WHERE id = ?");
      ps.setLong(1, personId.longValue());
      ps.executeUpdate();
    } catch (SQLException e) {
      throw new PersistenceException(String.format("Cannot delete Person with id = %s", cast(Object[])[ personId ]), e);
    } finally {
      JdbcUtils.closeStatement(ps);
    }
  }

  private List!(Person) findPersonForPersonRole(Connection con, List!(Long) personRoleIds)
  {
    PreparedStatement ps = null;
    try {
      ps = con.prepareStatement("SELECT DISTINCT(person.id) as id, name, sort_name, initial FROM person, person_role WHERE person_role.person_id = person.id AND person_role.id IN (" + JdbcUtils.createInClause(personRoleIds.size()) + ")");

      for (int i = 1; i <= personRoleIds.size(); i++) {
        ps.setLong(i, (cast(Long)personRoleIds.get(i - 1)).longValue());
      }
      ResultSet rs = ps.executeQuery();
      return mapResultSet(rs);
    } catch (SQLException e) {
      throw new PersistenceException("Cannot read Person for Role relationship", e);
    } finally {
      JdbcUtils.closeStatement(ps);
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.dao.PersonDAOImpl
 * JD-Core Version:    0.6.2
 */