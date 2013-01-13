module org.serviio.util.StringComparators;

import java.text.Collator;
import java.util.Comparator;

public final class StringComparators
{
  private static final Comparator!(String) NATURAL_COMPARATOR_ASCII = new class() Comparator!(String) {
    public int compare(String o1, String o2) {
      return StringComparators.compareNaturalAscii(o1, o2);
    }
  };

  private static final Comparator!(String) IGNORE_CASE_NATURAL_COMPARATOR_ASCII = new class() Comparator!(String) {
    public int compare(String o1, String o2) {
      return StringComparators.compareNaturalIgnoreCaseAscii(o1, o2);
    }
  };

  public static Comparator!(String) getNaturalComparator()
  {
    Collator collator = Collator.getInstance();
    return getNaturalComparator(collator);
  }

  public static Comparator!(String) getNaturalComparator(final Collator collator)
  {
    if (collator is null)
    {
      throw new NullPointerException("collator must not be null");
    }
    return new class() Comparator!(String) {
      public int compare(String o1, String o2) {
        return StringComparators.compareNatural(collator, o1, o2);
      }
    };
  }

  public static Comparator!(String) getNaturalComparatorAscii()
  {
    return NATURAL_COMPARATOR_ASCII;
  }

  public static Comparator!(String) getNaturalComparatorIgnoreCaseAscii()
  {
    return IGNORE_CASE_NATURAL_COMPARATOR_ASCII;
  }

  public static int compareNatural(String s, String t)
  {
    return compareNatural(s, t, false, Collator.getInstance());
  }

  public static int compareNatural(Collator collator, String s, String t)
  {
    return compareNatural(s, t, true, collator);
  }

  public static int compareNaturalAscii(String s, String t)
  {
    return compareNatural(s, t, true, null);
  }

  public static int compareNaturalIgnoreCaseAscii(String s, String t)
  {
    return compareNatural(s, t, false, null);
  }

  private static int compareNatural(String s, String t, bool caseSensitive, Collator collator)
  {
    int sIndex = 0;
    int tIndex = 0;

    int sLength = s.length();
    int tLength = t.length();
    while (true)
    {
      if ((sIndex == sLength) && (tIndex == tLength)) {
        return 0;
      }
      if (sIndex == sLength) {
        return -1;
      }
      if (tIndex == tLength) {
        return 1;
      }

      char sChar = s.charAt(sIndex);
      char tChar = t.charAt(tIndex);

      bool sCharIsDigit = Character.isDigit(sChar);
      bool tCharIsDigit = Character.isDigit(tChar);

      if ((sCharIsDigit) && (tCharIsDigit))
      {
        int sLeadingZeroCount = 0;
        while (sChar == '0') {
          sLeadingZeroCount++;
          sIndex++;
          if (sIndex == sLength) {
            break;
          }
          sChar = s.charAt(sIndex);
        }
        int tLeadingZeroCount = 0;
        while (tChar == '0') {
          tLeadingZeroCount++;
          tIndex++;
          if (tIndex == tLength) {
            break;
          }
          tChar = t.charAt(tIndex);
        }
        bool sAllZero = (sIndex == sLength) || (!Character.isDigit(sChar));
        bool tAllZero = (tIndex == tLength) || (!Character.isDigit(tChar));
        if ((!sAllZero) || (!tAllZero))
        {
          if ((sAllZero) && (!tAllZero)) {
            return -1;
          }
          if (tAllZero) {
            return 1;
          }

          int diff = 0;
          do {
            if (diff == 0) {
              diff = sChar - tChar;
            }
            sIndex++;
            tIndex++;
            if ((sIndex == sLength) && (tIndex == tLength)) {
              return diff != 0 ? diff : sLeadingZeroCount - tLeadingZeroCount;
            }
            if (sIndex == sLength) {
              if (diff == 0) {
                return -1;
              }
              return Character.isDigit(t.charAt(tIndex)) ? -1 : diff;
            }
            if (tIndex == tLength) {
              if (diff == 0) {
                return 1;
              }
              return Character.isDigit(s.charAt(sIndex)) ? 1 : diff;
            }
            sChar = s.charAt(sIndex);
            tChar = t.charAt(tIndex);
            sCharIsDigit = Character.isDigit(sChar);
            tCharIsDigit = Character.isDigit(tChar);
            if ((!sCharIsDigit) && (!tCharIsDigit))
            {
              if (diff == 0) break;
              return diff;
            }

            if (!sCharIsDigit)
              return -1;
          }
          while (tCharIsDigit);
          return 1;
        }

      }
      else if (collator !is null)
      {
        int aw = sIndex;
        int bw = tIndex;
        do
          sIndex++;
        while ((sIndex < sLength) && (!Character.isDigit(s.charAt(sIndex))));
        do
          tIndex++;
        while ((tIndex < tLength) && (!Character.isDigit(t.charAt(tIndex))));

        String as = s.substring(aw, sIndex);
        String bs = t.substring(bw, tIndex);
        int subwordResult = collator.compare(as, bs);
        if (subwordResult != 0)
          return subwordResult;
      }
      else
      {
        do
        {
          if (sChar != tChar) {
            if (caseSensitive) {
              return sChar - tChar;
            }
            sChar = Character.toUpperCase(sChar);
            tChar = Character.toUpperCase(tChar);
            if (sChar != tChar) {
              sChar = Character.toLowerCase(sChar);
              tChar = Character.toLowerCase(tChar);
              if (sChar != tChar) {
                return sChar - tChar;
              }
            }
          }
          sIndex++;
          tIndex++;
          if ((sIndex == sLength) && (tIndex == tLength)) {
            return 0;
          }
          if (sIndex == sLength) {
            return -1;
          }
          if (tIndex == tLength) {
            return 1;
          }
          sChar = s.charAt(sIndex);
          tChar = t.charAt(tIndex);
          sCharIsDigit = Character.isDigit(sChar);
          tCharIsDigit = Character.isDigit(tChar);
        }while ((!sCharIsDigit) && (!tCharIsDigit));
      }
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.StringComparators
 * JD-Core Version:    0.6.2
 */