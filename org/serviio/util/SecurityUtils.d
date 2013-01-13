module org.serviio.util.SecurityUtils;

import java.io.UnsupportedEncodingException;
import java.security.Key;
import java.util.Arrays;
import javax.crypto.Cipher;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.restlet.engine.util.Base64;

public class SecurityUtils
{
  public static String generateMacAsHex(String privateKey, String input, String algorithm)
  {
    return byteArrayToHex(generateMac(privateKey, input, algorithm));
  }

  public static String generateMacAsBase64(String privateKey, String input, String algorithm) {
    return Base64.encode(generateMac(privateKey, input, algorithm), false);
  }

  public static byte[] decrypt(String privateKey, String input, String algorithm) {
    return decryptMethod(privateKey, input, algorithm);
  }

  public static String decryptAsHex(String privateKey, String input, String algorithm) {
    return byteArrayToHex(decryptMethod(privateKey, input, algorithm));
  }

  public static String decryptAES(String key, String iv, String hexText) {
    StringBuffer out_ = new StringBuffer();
    try {
      byte[] keyBytes = StringUtils.hexStringToByteArray(key);
      byte[] textBytes = StringUtils.hexStringToByteArray(hexText);
      byte[] result = AES.decrypt(textBytes, keyBytes);

      byte[] xorkey = iv.getBytes("ASCII");
      for (int i = 0; i < Math.ceil(textBytes.length / 16); i++) {
        String res = xor(xorkey, Arrays.copyOfRange(result, i * 16, i * 16 + 16));
        xorkey = Arrays.copyOfRange(textBytes, i * 16, i * 16 + 16);
        out_.append(res);
      }
    } catch (UnsupportedEncodingException e) {
      throw new RuntimeException(e);
    }
    return out_.toString().trim();
  }

  private static byte[] generateMac(String privateKey, String input, String algorithm) {
    byte[] keyBytes = privateKey.getBytes();
    Key key = new SecretKeySpec(keyBytes, 0, keyBytes.length, algorithm);
    Mac mac = Mac.getInstance(algorithm);
    mac.init(key);
    return mac.doFinal(input.getBytes());
  }

  private static byte[] decryptMethod(String input, String privateKey, String algorithm) {
    byte[] keyBytes = privateKey.getBytes();
    Key key = new SecretKeySpec(keyBytes, algorithm);
    Cipher c = Cipher.getInstance(algorithm);
    c.init(2, key);
    return c.doFinal(input.getBytes());
  }

  private static String xor(byte[] s1, byte[] s2) {
    StringBuilder sb = new StringBuilder();
    for (int i = 0; (i < s1.length) && (i < s2.length); i++) {
      sb.append(cast(char)(s1[i] ^ s2[i]));
    }
    return sb.toString();
  }

  private static String byteArrayToHex(byte[] a)
  {
    String hexDigitChars = "0123456789abcdef";
    StringBuffer buf = new StringBuffer(a.length * 2);
    for (int cx = 0; cx < a.length; cx++) {
      int hn = (a[cx] & 0xFF) / 16;
      int ln = a[cx] & 0xF;
      buf.append(hexDigitChars.charAt(hn));
      buf.append(hexDigitChars.charAt(ln));
    }
    return buf.toString();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.SecurityUtils
 * JD-Core Version:    0.6.2
 */