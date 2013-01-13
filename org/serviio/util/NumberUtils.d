module org.serviio.util.NumberUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class NumberUtils
{
  public static final Random randomGenerator = new Random();

  public static int getRandomInInterval(int start, int end)
  {
    int base = end - start;
    if (base < 0)
      throw new RuntimeException("Invalid parameters passed into the random number generator");
    if (base == 0) {
      return 0;
    }
    int randomOffset = randomGenerator.nextInt(base);
    return start + randomOffset;
  }

  public static List!(Integer) getRandomSequenceInInterval(int start, int end, int count)
  {
    List!(Integer) sequence = new ArrayList!(Integer)(count);
    int base = start;
    for (int i = 0; i < count; i++) {
      base = getRandomInInterval(base, end);
      sequence.add(Integer.valueOf(base));
    }
    return sequence;
  }

  public static bool isNumber(String string)
  {
    try
    {
      new Integer(string);
      return true; } catch (NumberFormatException e) {
    }
    return false;
  }

  public static Integer stringToInt(String value)
  {
    if (value is null)
      return null;
    try
    {
      return new Integer(value); } catch (NumberFormatException e) {
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.NumberUtils
 * JD-Core Version:    0.6.2
 */