module org.serviio.util.IcyInputStream;

import java.io.BufferedInputStream;
import java.io.FilterInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.net.URL;
import java.net.URLConnection;

public class IcyInputStream : FilterInputStream
{
  private int metaInt = 0;
  private int bytesRead = 0;
  private URLConnection connection;
  private String contentType;

  public static IcyInputStream create(String url)
  {
    URLConnection connection = (new URL(url)).openConnection();
    IcyInputStream icyInputStream = new IcyInputStream(new BufferedInputStream(openConnection(url)));
    icyInputStream.setConnection(connection);
    icyInputStream.init();
    return icyInputStream;
  }

  private static InputStream openConnection(String urlString) {
    URL url = new URL(urlString);
    int port = url.getPort() == -1 ? 80 : url.getPort();
    String path = ObjectValidator.isEmpty(url.getPath()) ? "/" : url.getPath();
    Socket socket = new Socket(url.getHost(), port);
    OutputStream os = socket.getOutputStream();
    String userAgent = "Windows-Media-Player/12.0.7601.17514";
    String req = String.format("GET %s HTTP/1.0\r\nuser-agent: %s\r\nConnection: keep-alive\r\n\r\n", cast(Object[])[ path, userAgent ]);
    os.write(req.getBytes());
    return socket.getInputStream();
  }

  private this(InputStream in_) {
    super(in_);
  }

  private void setConnection(URLConnection connection) {
    this.connection = connection;
  }

  public String getContentType() {
    return contentType;
  }

  public String readLine() {
    int ch = read();

    StringBuilder sb = new StringBuilder();
    while ((ch != 10) && (ch != 13) && (ch >= 0)) {
      sb.append(cast(char)ch);
      ch = read();
    }

    if ((ch == 10) || (ch == 13))
    {
      read();
    }
    return sb.toString();
  }

  private void init() {
    contentType = connection.getContentType();
    String metaIntString = "0";
    if (contentType.equals("unknown/unknown")) {
      String s = readLine();
      if (!s.equals("ICY 200 OK")) {
        throw new IOException((new StringBuilder()).append("SHOUTCast invalid response: ").append(s).toString());
      }
      while (true)
      {
        s = readLine();

        if (s.isEmpty())
          break;
      }
    }
    else {
      metaIntString = connection.getHeaderField("icy-metaint");
    }
    try {
      metaInt = Integer.parseInt(metaIntString.trim());
    } catch (NumberFormatException e) {
      metaInt = 0;
    }
  }

  public int read(byte[] b, int off, int len)
  {
    if (metaInt > 0) {
      int bytesToMeta = metaInt - bytesRead;

      if (bytesToMeta == 0)
        readMeta();
      else if ((bytesToMeta > 0) && (bytesToMeta < len)) {
        len = bytesToMeta;
      }
    }

    int read = super.read(b, off, len);
    bytesRead = read;
    return read;
  }

  private void readMeta() {
    int size = read() * 16;
    if (size > 1) {
      byte[] meta = new byte[size];
      int i = super.read(meta, 0, size);
      if (i != size) {
        throw new RuntimeException("WTF");
      }
    }
    bytesRead = 0;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.IcyInputStream
 * JD-Core Version:    0.6.2
 */