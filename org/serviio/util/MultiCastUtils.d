module org.serviio.util.MultiCastUtils;

import java.lang.String;
import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.MulticastSocket;
import java.net.NetworkInterface;
import java.net.SocketAddress;
import java.net.SocketException;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.Set;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MultiCastUtils
{
  private static immutable Logger log = LoggerFactory.getLogger!(MultiCastUtils)();

  public static MulticastSocket startMultiCastSocketForListening(InetSocketAddress group, NetworkInterface networkInterface, int ttl)
  {
    MulticastSocket socket = new MulticastSocket(group.getPort());
    socket.setTimeToLive(ttl);

    socket.setReuseAddress(true);
    socket.joinGroup(group, networkInterface);
    return socket;
  }

  public static MulticastSocket startMultiCastSocketForSending(NetworkInterface networkInterface, InetAddress boundAddress, int ttl) {
    MulticastSocket socket = new MulticastSocket();
    socket.setTimeToLive(ttl);

    socket.setInterface(boundAddress);
    socket.setNetworkInterface(networkInterface);
    socket.setReuseAddress(true);
    return socket;
  }

  public static void stopMultiCastSocket(MulticastSocket socket, InetSocketAddress group, bool leaveGroup)
  {
    if (socket !is null)
      try {
        if (leaveGroup)
          socket.leaveGroup(group.getAddress());
      }
      catch (Exception ex)
      {
        log.debug_("Problem leaving multicast group", ex);
      } finally {
        if (!socket.isClosed())
          socket.close();
      }
  }

  public static DatagramSocket startUniCastSocket()
  {
    DatagramSocket ssdpUniSock = new DatagramSocket();
    return ssdpUniSock;
  }

  public static void send(String message, DatagramSocket socket, SocketAddress target) {
    byte[] pk = message.getBytes();
    socket.send(new DatagramPacket(pk, pk.length, target));
  }

  public static DatagramPacket receive(DatagramSocket socket) {
    byte[] buf = new byte[2048];
    DatagramPacket input = new DatagramPacket(buf, buf.length);
    socket.receive(input);
    return input;
  }

  public static String getPacketData(DatagramPacket packet) {
    String received = new String(packet.getData(), packet.getOffset(), packet.getLength());
    return received;
  }

  public static Set!(NetworkInterface) findAllAvailableInterfaces()
  {
    Set!(NetworkInterface) ifaceList = new HashSet!(NetworkInterface)();
    for (Enumeration!(Object) ifaces = NetworkInterface.getNetworkInterfaces(); ifaces.hasMoreElements(); ) {
      NetworkInterface iface = cast(NetworkInterface)ifaces.nextElement();
      if ((!iface.isLoopback()) && (!iface.isVirtual()) && (!iface.isPointToPoint()) && (iface.isUp()) && (iface.supportsMulticast()) && (findIPAddress(iface) !is null))
      {
        ifaceList.add(iface);
      }
    }
    return ifaceList;
  }

  public static InetAddress findIPAddress(NetworkInterface iface) {
    for (Enumeration!(Object) addresses = iface.getInetAddresses(); addresses.hasMoreElements(); ) {
      InetAddress address = cast(InetAddress)addresses.nextElement();
      if (( cast(Inet4Address)address !is null )) {
        return address;
      }
    }
    return null;
  }

  public static String getInterfaceName(NetworkInterface iface) {
    if (iface !is null) {
      return String.format("%s (%s)", cast(Object[])[ iface.getName(), iface.getDisplayName() ]);
    }
    return "Unknown";
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.MultiCastUtils
 * JD-Core Version:    0.6.2
 */