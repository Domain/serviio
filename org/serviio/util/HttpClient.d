module org.serviio.util.HttpClient;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;

public class HttpClient
{
  private static final int CONNECT_TIMEOUT = 20000;
  private static final int READ_TIMEOUT = 30000;

  public static String retrieveTextFileFromURL(String url, String encoding)
  {
    return StringUtils.readStreamAsString(getStreamFromURL(url), encoding);
  }

  public static String retrieveGZippedTextFileFromURL(String url, String encoding)
  {
    return StringUtils.readStreamAsString(ZipUtils.unGzipSingleFile(getStreamFromURL(url)), encoding);
  }

  public static byte[] retrieveBinaryFileFromURL(String url)
  {
    URL fileURL = new URL(url);
    URLConnection connection = HttpUtils.getUrlConnection(fileURL, HttpUtils.getCredentialsFormUrl(url));
    connection.setConnectTimeout(CONNECT_TIMEOUT);
    connection.setReadTimeout(READ_TIMEOUT);
    InputStream in_ = connection.getInputStream();
    return readBytesFromStream(in_);
  }

  public static InputStream getStreamFromURL(String url)
  {
    URLConnection connection = prepareConnection(url);
    return cast(InputStream)connection.getContent();
  }

  public static InputStream retrieveBinaryStreamFromURL(String url)
  {
    URLConnection connection = prepareConnection(url);
    return connection.getInputStream();
  }

  public static InputStream getShoutCastStream(String urlString) {
    return IcyInputStream.create(urlString);
  }

  public static Integer getContentSize(URL contentURL) {
    try {
      URLConnection connection = contentURL.openConnection();
      int contentLength = connection.getContentLength();
      return Integer.valueOf(contentLength); } catch (IOException e) {
    }
    return null;
  }

  private static byte[] readBytesFromStream(InputStream is_)
  {
    ByteArrayOutputStream buffer = new ByteArrayOutputStream();

    byte[] data = new byte[2048];
    int nRead;
    while ((nRead = is_.read(data, 0, data.length)) != -1) {
      buffer.write(data, 0, nRead);
    }

    buffer.flush();

    return buffer.toByteArray();
  }

  private static URLConnection prepareConnection(String url) {
    URL fileURL = new URL(url);
    URLConnection connection = HttpUtils.getUrlConnection(fileURL, HttpUtils.getCredentialsFormUrl(url));
    connection.setConnectTimeout(CONNECT_TIMEOUT);
    connection.setReadTimeout(READ_TIMEOUT);
    return connection;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.HttpClient
 * JD-Core Version:    0.6.2
 */