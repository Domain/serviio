module org.serviio.util.ObjectValidator;

import java.lang.String;
import java.lang.Number;
import java.util.Collection;

public class ObjectValidator
{
  public static bool isNotEmpty(String string)
  {
    return (string !is null) && (!string.trim().equals(""));
  }

  public static bool isEmpty(String string) {
    return (string is null) || (string.trim().equals(""));
  }

  public static bool isNotNullAndPositive(Number number) {
    return (number !is null) && (number.doubleValue() > 0.0);
  }

  public static bool isNotNullAndPositiveNumber(Object obj) {
    if (( cast(Number)obj !is null )) {
      return (cast(Number)obj).doubleValue() > 0.0;
    }
    return false;
  }

  public static bool isNotNullNorEmpty(Collection!(Object) collection)
  {
    return (collection !is null) && (collection.size() > 0);
  }

  public static bool isNotNullNorEmptyString(Object obj) {
    if (obj is null) {
      return false;
    }
    if (( cast(String)obj !is null )) {
      return !"".equals(obj);
    }
    return true;
  }

  public static bool isNotNullNorEmpty(Object[] array)
  {
    return (array !is null) && (array.length > 0);
  }

  public static bool isNullOrEmpty(Collection!(Object) collection)
  {
    if (collection is null) {
      return true;
    }
    if (collection.size() == 0) {
      return true;
    }
    return false;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.ObjectValidator
 * JD-Core Version:    0.6.2
 */