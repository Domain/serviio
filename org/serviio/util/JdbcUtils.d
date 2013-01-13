module org.serviio.util.JdbcUtils;

import java.lang.all;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.sql.Blob;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLDataException;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.Date;
import org.serviio.db.DatabaseManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class JdbcUtils
{
  private static immutable Logger log = LoggerFactory.getLogger!(JdbcUtils);

  public static void executeBatchStatement(String sqlFile)
  {
    Connection con = null;
    Statement s = null;
    String[] commands = sqlFile.split(";");
    foreach (String command ; commands) {
      command = command.trim();
      if (!command.equals(""))
        try {
          con = DatabaseManager.getConnection(true);
          s = con.createStatement();
          s.executeUpdate(command);
        } catch (SQLException e) {
          log.debug_("An exception occurend when executing SQL statement", e);
        } finally {
          closeStatement(s);
          DatabaseManager.releaseConnection(con);
        }
    }
  }

  public static void closeStatement(Statement s)
  {
    if (s !is null)
      try {
        s.close();
      } catch (SQLException e) {
        log.warn(String.format("Cannot close DB Statement", cast(Object[])[ e ]));
      }
  }

  public static void rollback(Connection con)
  {
    try
    {
      con.rollback();
    } catch (SQLException e) {
      log.error(String.format("Cannot perform rollback", cast(Object[])[ e ]));
    }
  }

  public static long retrieveGeneratedID(Statement s)
  {
    ResultSet rs = s.getGeneratedKeys();
    if (rs.next()) {
      long idColVar = rs.getLong(1);
      return idColVar;
    }
    throw new SQLException("Cannot retrieve generated id from the last Statement");
  }

  public static Integer getIntFromResultSet(ResultSet rs, String columnLabel)
  {
    String strValue = rs.getString(columnLabel);
    if (ObjectValidator.isNotEmpty(strValue)) {
      return new Integer(strValue);
    }
    return null;
  }

  public static Boolean getBooleanFromResultSet(ResultSet rs, String columnLabel)
  {
    String strValue = rs.getString(columnLabel);
    if (ObjectValidator.isNotEmpty(strValue)) {
      return strValue.equals("1") ? Boolean.TRUE : Boolean.FALSE;
    }
    return null;
  }

  public static Long getLongFromResultSet(ResultSet rs, String columnLabel)
  {
    String strValue = rs.getString(columnLabel);
    if (ObjectValidator.isNotEmpty(strValue)) {
      return new Long(strValue);
    }
    return null;
  }

  public static Float getFloatFromResultSet(ResultSet rs, String columnLabel)
  {
    String strValue = rs.getString(columnLabel);
    if (ObjectValidator.isNotEmpty(strValue)) {
      return new Float(strValue);
    }
    return null;
  }

  public static URL getURLFromResultSet(ResultSet rs, String columnLabel)
  {
    String strValue = rs.getString(columnLabel);
    if (ObjectValidator.isNotEmpty(strValue)) {
      return new URL(strValue);
    }
    return null;
  }

  public static void setLongValueOnStatement(PreparedStatement ps, int paramNumber, Long value)
  {
    if (value is null)
      ps.setNull(paramNumber, -5);
    else
      ps.setLong(paramNumber, value.longValue());
  }

  public static void setIntValueOnStatement(PreparedStatement ps, int paramNumber, Integer value)
  {
    if (value is null)
      ps.setNull(paramNumber, 4);
    else
      ps.setInt(paramNumber, value.intValue());
  }

  public static void setFloatValueOnStatement(PreparedStatement ps, int paramNumber, Float value)
  {
    if (value is null)
      ps.setNull(paramNumber, 7);
    else
      ps.setFloat(paramNumber, value.floatValue());
  }

  public static void setStringValueOnStatement(PreparedStatement ps, int paramNumber, String value)
  {
    if (value is null)
      ps.setNull(paramNumber, 12);
    else
      ps.setString(paramNumber, value);
  }

  public static void setBooleanValueOnStatement(PreparedStatement ps, int paramNumber, Boolean value)
  {
    if (value is null)
      ps.setNull(paramNumber, 16);
    else
      ps.setBoolean(paramNumber, value.boolValue());
  }

  public static void setURLValueOnStatement(PreparedStatement ps, int paramNumber, URL value)
  {
    if (value is null)
      setStringValueOnStatement(ps, paramNumber, null);
    else
      setStringValueOnStatement(ps, paramNumber, value.toString());
  }

  public static void setTimestampValueOnStatement(PreparedStatement ps, int paramNumber, Date value)
  {
    if (value is null)
      ps.setNull(paramNumber, 93);
    else
      try {
        ps.setTimestamp(paramNumber, new Timestamp(value.getTime()));
      }
      catch (SQLDataException e) {
        log.warn(String.format("Incorrect date: %s, using current date instead", cast(Object[])[ value.toString() ]), e);
        ps.setTimestamp(paramNumber, new Timestamp(System.currentTimeMillis()));
      }
  }

  public static byte[] convertBlob(Blob blob)
  {
    if (blob is null)
      return null;
    try
    {
      InputStream in_ = blob.getBinaryStream();
      int len = cast(int)blob.length();
      long pos = 1L;
      byte[] bytes = blob.getBytes(pos, len);
      in_.close();
      return bytes;
    } catch (Exception e) {
      log.error((new StringBuilder()).append("Cannot retrieve BLOB from database: ").append(e.getMessage()).toString());
    }
    return null;
  }

  public static String createInClause(int numberOfParameters)
  {
    StringBuilder inClause = new StringBuilder();
    bool firstValue = true;
    for (int i = 0; i < numberOfParameters; i++) {
      if (firstValue)
        firstValue = false;
      else {
        inClause.append(',');
      }
      inClause.append('?');
    }
    return inClause.toString();
  }

  public static String trimToMaxLength(String text, int maxLength) {
    if ((ObjectValidator.isNotEmpty(text)) && 
      (text.length() > maxLength)) {
      return text.substring(0, maxLength);
    }

    return text;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.JdbcUtils
 * JD-Core Version:    0.6.2
 */