module org.serviio.util.StringUtils;

import java.lang.String;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.Charset;
import java.text.Normalizer;
import java.util.Locale;
import java.util.regex.Pattern;

public class StringUtils
{
  public static const String UTF_8_ENCODING = "UTF-8";
  public static String LINE_SEPARATOR = System.getProperty("line.separator");

  private static enum articlesPattern = Pattern.compile("^(the|a)(\\s|\\.(?!\\s)|_)", 2);

  public static String removeArticles(String value)
  {
    if (value !is null) {
      value = value.replaceAll("'|\"", "");
      return articlesPattern.matcher(value).replaceFirst("");
    }
    return null;
  }

  public static String removeAccents(String value)
  {
    String result = Normalizer.normalize(value, Normalizer.Form.NFD);
    return result.replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
  }

  public static String readStreamAsString(InputStream stream, String encoding)
  {
    BufferedReader in_ = null;
    try {
      in_ = new BufferedReader(new InputStreamReader(stream, Charset.forName(encoding)));

      StringBuffer sb = new StringBuffer();
      int count = 0;
      String inputLine;
      while ((inputLine = in_.readLine()) !is null) {
        if (count > 0) {
          sb.append(LINE_SEPARATOR);
        }
        sb.append(inputLine);
        count++;
      }
      return sb.toString();
    } finally {
      if (in_ !is null)
        try {
          in_.close();
        }
        catch (IOException e)
        {
        }
    }
  }

  public static String trim(String string)
  {
    if (string !is null) {
      return string.trim();
    }
    return null;
  }

  public static int getUnicodeCode(String letter)
  {
    char c = letter.charAt(0);
    return c;
  }

  public static String getCharacterForCode(int unicode) {
    return String.valueOf(cast(char)unicode);
  }

  public static String localeSafeToUppercase(String value) {
    if (value !is null) {
      return value.toUpperCase(Locale.ENGLISH);
    }
    return null;
  }

  public static String localeSafeToLowercase(String value) {
    if (value !is null) {
      return value.toLowerCase(Locale.ENGLISH);
    }
    return null;
  }

  public static byte[] hexStringToByteArray(String str) {
    char[] hex = str.toCharArray();
    int length = hex.length / 2;
    byte[] raw = new byte[length];
    for (int i = 0; i < length; i++) {
      int high = Character.digit(hex[(i * 2)], 16);
      int low = Character.digit(hex[(i * 2 + 1)], 16);
      int value = high << 4 | low;
      if (value > 127)
        value -= 256;
      raw[i] = (cast(byte)value);
    }
    return raw;
  }

  public static String removeNewLineCharacters(String text) {
    return text.replaceAll("[\\r\\n]", "");
  }

  public static String[] splitStringToLines(String content) {
    return content.split("\\r?\\n|\\r");
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.StringUtils
 * JD-Core Version:    0.6.2
 */