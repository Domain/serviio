module org.serviio.upnp.discovery.RendererSearchSender;

import java.lang.Runnable;
import java.io.IOException;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;
import java.net.NetworkInterface;
import java.net.SocketTimeoutException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import org.apache.http.Header;
import org.apache.http.HttpException;
import org.apache.http.HttpResponse;
import org.serviio.upnp.Device;
import org.serviio.upnp.protocol.http.HttpMessageParser;
import org.serviio.upnp.protocol.ssdp.SSDPMessageBuilderFactory;
import org.serviio.upnp.discovery.AbstractSSDPMessageListener;
import org.serviio.util.HttpUtils;
import org.serviio.util.MultiCastUtils;
import org.serviio.util.ServiioThreadFactory;
import org.serviio.util.ThreadExecutor;
import org.serviio.upnp.discovery.Multicaster;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RendererSearchSender : Multicaster
{
	private static immutable Logger log;
	private int mx;
	private int searchSendCount;

	static this()
	{
		log = LoggerFactory.getLogger!(RendererSearchSender)();
	}

	public this(int mx, int searchSendCount)
	{
		this.mx = mx;
		this.searchSendCount = searchSendCount;
	}

	public void searchForRenderers()
	{
		Set!(NetworkInterface) ifaces = getAvailableNICs();
		log.info(String.format("Searching for Renderer devices, will multicast on %s NICs", cast(Object[])[ Integer.valueOf(ifaces.size()) ]));

		List!(Thread) searchWorkers = new ArrayList!(Thread)();
		foreach (NetworkInterface iface ; ifaces) {
			Thread t = ServiioThreadFactory.getInstance().newThread(new RendererSearchWorker(iface));
			searchWorkers.add(t);
			t.start();
		}

		foreach (Thread t ; searchWorkers)
			try {
				t.join();
			}
		catch (InterruptedException ignore) {
		}
		log.debug_("Finished searching for Renderer devices");
	}

	private class RendererSearchWorker : AbstractSSDPMessageListener
		, Runnable
	{
		private NetworkInterface multicastInterface;

		public this(NetworkInterface multicastInterface)
		{
			this.multicastInterface = multicastInterface;
		}

		public void run()
		{
			try {
				sendSearchToSingleInterface(multicastInterface);
			} catch (IOException e) {
				RendererSearchSender.log.warn(String.format("Search for Renderers using interface %s failed: %s", cast(Object[])[ MultiCastUtils.getInterfaceName(multicastInterface), e.getMessage() ]));
			}
		}

		private void sendSearchToSingleInterface(NetworkInterface multicastInterface)
		{
			MulticastSocket socket = null;
			Device device = Device.getInstance();
			InetAddress address = MultiCastUtils.findIPAddress(multicastInterface);
			if (address !is null)
				try
				{
					socket = MultiCastUtils.startMultiCastSocketForSending(multicastInterface, address, 32);

					if ((socket !is null) && (socket.isBound())) {
						RendererSearchSender.log.debug_(String.format("Multicasting SSDP M-SEARCH using interface %s and address %s, timeout = %s", cast(Object[])[ MultiCastUtils.getInterfaceName(multicastInterface), address.getHostAddress(), Integer.valueOf(socket.getSoTimeout()) ]));

						List!(String) messages = SSDPMessageBuilderFactory.getInstance().getBuilder(SSDPMessageBuilderFactory.SSDPMessageType.SEARCH).generateSSDPMessages(Integer.valueOf(mx), "urn:schemas-upnp-org:device:MediaRenderer:1");

						RendererSearchSender.log.debug_(String.format("Sending %s 'm-search' messages", cast(Object[])[ Integer.valueOf(messages.size()) ]));
						foreach (String message ; messages) {
							for (int i = 0; i < searchSendCount; i++)
							{
								MultiCastUtils.send(message, socket, device.getMulticastGroupAddress());
							}
						}
						waitForResponses(socket, mx + 2);
					} else {
						RendererSearchSender.log.warn("Cannot multicast SSDP M-SEARCH message. Not connected to a socket.");
					}
				}
			finally {
				MultiCastUtils.stopMultiCastSocket(socket, device.getMulticastGroupAddress(), false);
			}
		}

		private void waitForResponses(MulticastSocket socket, int mx)
		{
			long startTime = System.currentTimeMillis();
			int remainingTimeout = 1;
			while (remainingTimeout > 0) {
				remainingTimeout = mx * 1000 - (new Long(System.currentTimeMillis() - startTime)).intValue();
				if (remainingTimeout > 0)
					try {
						socket.setSoTimeout(remainingTimeout);
						DatagramPacket receivedPacket = MultiCastUtils.receive(socket);
						HttpResponse response = HttpMessageParser.parseHttpResponse(MultiCastUtils.getPacketData(receivedPacket));
						if (response.getStatusLine().getStatusCode() == 200)
							processSearchResponse(response, receivedPacket);
						else
							RendererSearchSender.log.debug_("Received HTTP error " + response.getStatusLine().getStatusCode());
					}
				catch (HttpException e) {
					RendererSearchSender.log.debug_("Received message is not HTTP message");
				}
				catch (SocketTimeoutException e) {
					remainingTimeout = -1;
				} catch (IOException e) {
					RendererSearchSender.log.debug_("Cannot receive HTTP message: " + e.getMessage());
				}
			}
		}

		private void processSearchResponse(HttpResponse response, DatagramPacket receivedPacket)
		{
			Header headerCacheControl = response.getFirstHeader("CACHE-CONTROL");
			Header headerLocation = response.getFirstHeader("LOCATION");
			Header headerST = response.getFirstHeader("ST");
			Header headerSERVER = response.getFirstHeader("SERVER");
			Header headerUSN = response.getFirstHeader("USN");
			RendererSearchSender.log.debug_(String.format("Received search response: location: %s, st: %s", cast(Object[])[ headerLocation.getValue(), headerST.getValue() ]));
			if ((headerST !is null) && (headerST.getValue().equals("urn:schemas-upnp-org:device:MediaRenderer:1")) && (headerUSN !is null) && (headerSERVER !is null))
				try
				{
					String server = headerSERVER.getValue().trim();
					String deviceUuid = getDeviceUuidFromUSN(headerUSN.getValue());
					String descriptionURL = headerLocation !is null ? headerLocation.getValue() : null;
					if (deviceUuid !is null) {
						int timeToKeep = HttpUtils.getMaxAgeFromHeader(headerCacheControl);
						if (RendererSearchSender.log.isDebugEnabled()) {
							RendererSearchSender.log.debug_(String.format("Received a valid M-SEARCH response from Renderer %s from address %s", cast(Object[])[ deviceUuid, receivedPacket.getSocketAddress().toString() ]));
						}

						ThreadExecutor.execute(new RendererSearchResponseProcessor(receivedPacket.getSocketAddress(), deviceUuid, server, timeToKeep, descriptionURL));
					}
					else {
						RendererSearchSender.log.warn(String.format("Provided USN value is invalid: %s. Will not process the search reply.", cast(Object[])[ headerUSN.getValue() ]));
					}
				}
			catch (NumberFormatException e) {
				RendererSearchSender.log.warn(String.format("Invalid header value: %s. Will not respond to the request.", cast(Object[])[ e.getMessage() ]));
			}
		}
	}
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.discovery.RendererSearchSender
* JD-Core Version:    0.6.2
*/