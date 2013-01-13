module org.serviio.util.DateUtils;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Locale;
import java.util.TimeZone;

public class DateUtils
{
  private static DateFormat dateFormatRFC1123;
  private static DateFormat dateFormatISO8601YYYYMMDD = new SimpleDateFormat("yyyy-MM-dd");
  private static DateFormat dateFormatHHMMSS;

  public static String formatRFC1123(Date date)
  {
    return dateFormatRFC1123.format(date);
  }

  public static String formatISO8601YYYYMMDD(Date date) {
    return dateFormatISO8601YYYYMMDD.format(date);
  }

  public static Integer timeToSeconds(String time)
  {
    if (ObjectValidator.isNotEmpty(time)) {
      if (time.indexOf(".") > -1)
      {
        time = time.substring(0, time.indexOf("."));
      }
      String[] elements = time.split(":");
      if (elements.length == 3) {
        try {
          int seconds = Integer.parseInt(elements[0]) * 3600 + Integer.parseInt(elements[1]) * 60 + Integer.parseInt(elements[2]);
          return Integer.valueOf(seconds);
        } catch (NumberFormatException e) {
          return null;
        }
      }
      return null;
    }

    return null;
  }

  public static Double timeToSecondsPrecise(String time)
  {
    Double milliseconds = Double.valueOf(0.0);
    if (ObjectValidator.isNotEmpty(time)) {
      if (time.indexOf(".") > -1) {
        milliseconds = Double.valueOf(Double.parseDouble("0" + time.substring(time.indexOf("."))));

        time = time.substring(0, time.indexOf("."));
      }
      String[] elements = time.split(":");
      if (elements.length == 3) {
        try {
          double seconds = Integer.parseInt(elements[0]) * 3600 + Integer.parseInt(elements[1]) * 60 + Integer.parseInt(elements[2]) + milliseconds.doubleValue();
          return Double.valueOf(seconds);
        } catch (NumberFormatException e) {
          return null;
        }
      }
      return null;
    }

    return null;
  }

  public static String timeToHHMMSS(long time)
  {
    return dateFormatHHMMSS.format(new Date(time));
  }

  public static Date minusMinutes(Date date, int minutes) {
    Calendar c = new GregorianCalendar();
    c.setTime(date);
    c.add(12, minutes * -1);
    return c.getTime();
  }

  public static int getYear(Date date) {
    Calendar cal = Calendar.getInstance();
    if (date !is null)
      cal.setTime(date);
    else {
      cal.setTime(new Date());
    }
    return cal.get(1);
  }

  static this()
  {
    dateFormatRFC1123 = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss zzz", Locale.US);
    dateFormatRFC1123.setTimeZone(TimeZone.getTimeZone("GMT"));

    dateFormatHHMMSS = new SimpleDateFormat("HH:mm:ss", Locale.US);
    dateFormatHHMMSS.setTimeZone(TimeZone.getTimeZone("GMT"));
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.DateUtils
 * JD-Core Version:    0.6.2
 */