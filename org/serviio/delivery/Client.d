module org.serviio.delivery.Client;

import java.net.InetAddress;
import org.serviio.profile.Profile;

public class Client
{
  private InetAddress ipAddress;
  private Profile rendererProfile;
  private bool expectsClosedConnection = false;

  private bool supportsRandomTimeSeek = false;

  public this(InetAddress ipAddress, Profile rendererProfile)
  {
    this.ipAddress = ipAddress;
    this.rendererProfile = rendererProfile;
  }

  public InetAddress getIpAddress()
  {
    return ipAddress;
  }

  public Profile getRendererProfile() {
    return rendererProfile;
  }

  public bool isExpectsClosedConnection() {
    return expectsClosedConnection;
  }

  public void setExpectsClosedConnection(bool expectsClosedConnection) {
    this.expectsClosedConnection = expectsClosedConnection;
  }

  public bool isSupportsRandomTimeSeek()
  {
    return supportsRandomTimeSeek;
  }

  public void setSupportsRandomTimeSeek(bool supportsRandomTimeSeek) {
    this.supportsRandomTimeSeek = supportsRandomTimeSeek;
  }

  public override hash_t toHash()
  {
    int prime = 31;
    int result = 1;
    result = prime * result + (ipAddress is null ? 0 : ipAddress.hashCode());
    result = prime * result + (rendererProfile is null ? 0 : rendererProfile.hashCode());
    return result;
  }

  public override equals_t opEquals(Object obj)
  {
    if (this == obj)
      return true;
    if (obj is null)
      return false;
    if (getClass() != obj.getClass())
      return false;
    Client other = cast(Client)obj;
    if (ipAddress is null) {
      if (other.ipAddress !is null)
        return false;
    } else if (!ipAddress.equals(other.ipAddress))
      return false;
    if (rendererProfile is null) {
      if (other.rendererProfile !is null)
        return false;
    } else if (!rendererProfile.equals(other.rendererProfile))
      return false;
    return true;
  }

  public String toString()
  {
    return String.format("IPAddress=%s, Profile=%s", cast(Object[])[ ipAddress, rendererProfile ]);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.Client
 * JD-Core Version:    0.6.2
 */