module org.serviio.util.CollectionUtils;

import java.lang.String;
import java.lang.Long;
import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map : Entry;
import java.util.Set;
import org.serviio.db.entities.PersistedEntity;

public class CollectionUtils
{
  public static String arrayToCSV(String[] array, String separator)
  {
    StringBuffer sb = new StringBuffer();
    if ((array !is null) && (array.length > 0)) {
      for (int i = 0; i < array.length - 1; i++) {
        sb.append(array[i]).append(separator);
      }
      sb.append(array[(array.length - 1)]);
    }
    return sb.toString();
  }

  public static String listToCSV(Collection!(Object) list, String separator, bool trim) {
    StringBuffer sb = new StringBuffer();
    if ((list !is null) && (list.size() > 0)) {
      Iterator!(Object) i = list.iterator();
      while (i.hasNext()) {
        String value = i.next().toString();
        sb.append(trim ? value.trim() : value);
        if (i.hasNext())
        {
          sb.append(separator);
        }
      }
    }
    return sb.toString();
  }

  public static String mapToCSV(Map!(Object, Object) map, String separator, bool trim) {
    StringBuffer sb = new StringBuffer();
    bool first;
    if ((map !is null) && (map.size() > 0)) {
      first = true;
      foreach (Entry!(Object, Object) entry ; map.entrySet()) {
        if (!first) {
          sb.append(separator);
        }
        sb.append(trim ? entry.getKey().toString().trim() : entry.getKey());
        sb.append("=");
        sb.append(trim ? entry.getValue().toString().trim() : entry.getValue());
        first = false;
      }
    }
    return sb.toString();
  }

  public static Map!(String, String) CSVToMap(String value, String separator) {
    Map!(String, String) result = new LinkedHashMap!(String, String)();
    if (ObjectValidator.isNotEmpty(value)) {
      String[] entries = value.split(separator);
      foreach (String entry ; entries) {
        String[] values = entry.split("=");
        result.put(values[0], values[1]);
      }
    }
    return result;
  }

  public static Object getFirstItem(Collection!(Object) collection)
  {
    if ((collection !is null) && (!collection.isEmpty())) {
      return collection.iterator().next();
    }
    return null;
  }

  
public static T[] setToArray(T)(Set!(T) set, Class!(T) elementClass)
  {
    if (set !is null) {
      T[] array = cast(T[])Array.newInstance(elementClass, set.size());
      List!(T) list = new ArrayList!(T)(set);
      return cast(T[]) list.toArray(array);
    }
    return null;
  }

  public static Set!(T) arrayToSet(T)(T[] array)
  {
    if (array !is null) {
      Set!(T) set = new HashSet!(T)(array.length);
      foreach (T element ; array) {
        set.add(element);
      }
      return set;
    }
    return null;
  }

  public static void addUniqueElementToArray(T)(T[] array, T element, Class!(T) elementClass)
  {
    Set!(T) set = arrayToSet(array);
    set.add(element);
    array = setToArray(set, elementClass);
  }

  public static void removeElementFromArray(T)(T[] array, T element, Class!(T) elementClass)
  {
    Set!(T) set = arrayToSet(array);
    set.remove(element);
    array = setToArray(set, elementClass);
  }

  public static int[] enumSetToOrdinalArray(Set!(Object) enums)
  {
    int[] result = new int[enums.size()];
    int i = 0;
    for (Iterator!(Object) i = enums.iterator(); i.hasNext(); ) { Object element = i.next();
      result[(i++)] = (cast(Enum!(Object))element).ordinal();
    }
    return result;
  }

  public static int[] addUniqueIntToArray(int[] array, int element)
  {
    if (array !is null)
    {
      Set!(Integer) set = new HashSet!(Integer)(array.length);
      foreach (int item ; array) {
        set.add(Integer.valueOf(item));
      }
      set.add(Integer.valueOf(element));
      int[] newArray = new int[set.size()];
      int i = 0;
      for (Iterator!(Integer) i = set.iterator(); i.hasNext(); ) { int item = (cast(Integer)i.next()).intValue();
        newArray[(i++)] = item;
      }
      return newArray;
    }
    return null;
  }

  public static int[] removeIntFromArray(int[] array, int element)
  {
    if (array !is null)
    {
      Set!(Integer) set = new HashSet!(Integer)(array.length);
      foreach (int item ; array) {
        set.add(Integer.valueOf(item));
      }
      set.remove(Integer.valueOf(element));
      int[] newArray = new int[set.size()];
      int i = 0;
      for (Iterator!(Integer) i = set.iterator(); i.hasNext(); ) { int item = (cast(Integer)i.next()).intValue();
        newArray[(i++)] = item;
      }
      return newArray;
    }
    return null;
  }

  public static bool arrayContainsInt(int[] array, int element)
  {
    foreach (int item ; array) {
      if (item == element) {
        return true;
      }
    }
    return false;
  }

  public static List!(T) getSubList(T)(List!(T) list, int startIndex, int count)
  {
    int endIndex = startIndex + count;
    if (endIndex > list.size()) {
      endIndex = list.size();
    }
    return list.subList(startIndex, endIndex);
  }

  public static Map!(K, V) getSubMap(K, V)(Map!(K, V) map, int startIndex, int count)
  {
    int endIndex = startIndex + count;
    if (endIndex > map.size()) {
      endIndex = map.size();
    }
    Map!(K, V) result = new LinkedHashMap!(K, V)();
    int i = 0;
    foreach (Entry!(K, V) entry ; map.entrySet()) {
      if ((i >= startIndex) && (i < endIndex)) {
        result.put(entry.getKey(), entry.getValue());
      }
    }
    return result;
  }

  public static List!(Long) extractEntityIDs(T : PersistedEntity)(List!(T) entities) {
    List!(Long) ids = new ArrayList!(Long)();
    foreach (PersistedEntity entity ; entities) {
      ids.add(entity.getId());
    }
    return ids;
  }

  public static void removeNulls(Collection!(Object) col) {
    col.remove(null);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.CollectionUtils
 * JD-Core Version:    0.6.2
 */