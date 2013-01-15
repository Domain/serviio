module org.serviio.upnp.webserver.WebServer;

import java.io.IOException;
import java.io.InterruptedIOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketException;
import java.util.UUID;
import org.apache.http.ConnectionClosedException;
import org.apache.http.HttpException;
import org.apache.http.impl.DefaultConnectionReuseStrategy;
import org.apache.http.impl.DefaultHttpResponseFactory;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpParams;
import org.apache.http.protocol.BasicHttpContext;
import org.apache.http.protocol.BasicHttpProcessor;
import org.apache.http.protocol.HttpContext;
import org.apache.http.protocol.HttpService;
import org.apache.http.protocol.ResponseConnControl;
import org.apache.http.protocol.ResponseContent;
import org.apache.http.protocol.ResponseDate;
import org.apache.http.protocol.ResponseServer;
import org.serviio.ApplicationSettings;
import org.serviio.upnp.protocol.http.UniversalHttpServerConnection;
import org.serviio.upnp.protocol.ssdp.SSDPConstants;
import org.serviio.util.ObjectValidator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class WebServer
{
	private static final Logger log = LoggerFactory.getLogger!(WebServer)();
	private static RequestListenerThread webServerThread;
	public static final Integer WEBSERVER_PORT = ApplicationSettings
			.getIntegerProperty("webserver_port");
	public static final String CONTEXT_PARAM_REMOTE_IP = "remote_ip_address";
	public static final int DEFAULT_SOCKET_BUFFER = 65535;
	public static int socketBuffer;

	public static void start(int port)
	{
		webServerThread = new RequestListenerThread(port);
		webServerThread.setName("WebServer");
		webServerThread.setDaemon(false);
		webServerThread.start();
	}

	public static void stop()
	{
		if (webServerThread !is null)
		{
			webServerThread.interrupt();
			webServerThread.getServersocket().close();
		}
	}

	public static int getSocketBufferSize()
	{
		return socketBuffer;
	}

	static this()
	{
		if (ObjectValidator.isNotEmpty(System
				.getProperty("serviio.socketBuffer")))
			socketBuffer = Integer.valueOf(
					System.getProperty("serviio.socketBuffer")).intValue();
		else
		{
			socketBuffer = 65535;
		}
		log.info(String.format("Socket buffer set to %s bytes",
				cast(Object[])[ Integer.valueOf(socketBuffer) ]));
	}

	static class WorkerThread : Thread
	{
		private final HttpService httpservice;
		private final UniversalHttpServerConnection conn;

		public this(HttpService httpservice,
				UniversalHttpServerConnection conn)
		{
			this.httpservice = httpservice;
			this.conn = conn;
		}

		public void run()
		{
			String remoteIpAddress = conn.getSocketAddress();
			HttpContext context = new BasicHttpContext(null);
			context.setAttribute("remote_ip_address", remoteIpAddress);
			try
			{
				WebServer.log.debug_(String.format(
						"Incoming connection from %s",
						cast(Object[])[ remoteIpAddress ]));
				while ((!Thread.interrupted()) && (conn.isOpen()))
				{
					httpservice.handleRequest(conn, context);
					conn.closeEntityStream();
				}
				conn.close();
			}
			catch (ConnectionClosedException ex)
			{
				WebServer.log.trace("Client closed connection");
				conn.closeEntityStream();
			}
			catch (IOException ex)
			{
				WebServer.log.debug_("I/O error: " + ex.getMessage());
				conn.closeEntityStream();
			}
			catch (HttpException ex)
			{
				WebServer.log.warn("Unrecoverable HTTP protocol violation: "
						+ ex.getMessage());
				conn.closeEntityStream();
			}
			finally
			{
				try
				{
					conn.shutdown();
				}
				catch (IOException ignore)
				{
				}
			}
		}
	}

	static class RequestListenerThread : Thread
	{
		private final ServerSocket serversocket;
		private final HttpParams params;
		private final HttpService httpService;

		public this(int port)
		{
			serversocket = new ServerSocket(port);

			params = new BasicHttpParams();
			params.setIntParameter("http.socket.timeout", 0)
					.setIntParameter("http.socket.buffer-size",
							WebServer.socketBuffer)
					.setBooleanParameter("http.connection.stalecheck", false)
					.setBooleanParameter("http.tcp.nodelay", true)
					.setParameter("http.origin-server", SSDPConstants.SERVER);

			BasicHttpProcessor httpproc = new BasicHttpProcessor();
			httpproc.addInterceptor(new ResponseDate());
			httpproc.addInterceptor(new ResponseServer());
			httpproc.addInterceptor(new ResponseContent());
			httpproc.addInterceptor(new ResponseConnControl());

			HttpRequestHandlerRegexRegistry reqistry = new HttpRequestHandlerRegexRegistry();

			reqistry.register(".*/deviceDescription/.+",
					new DeviceDescriptionRequestHandler());
			reqistry.register(".*/serviceDescription/.+",
					new ServiceDescriptionRequestHandler());
			reqistry.register(".*/serviceControl",
					new ServiceControlRequestHandler());
			reqistry.register(".*/serviceEventing/.+",
					new ServiceEventSubscriptionRequestHandler());
			reqistry.register(".*/resource/.+",
					new ResourceTransportRequestHandler());
			reqistry.register(".*/icon/.+", new UPnPIconRequestHandler());

			httpService = new ServiioHttpService(httpproc,
					new DefaultConnectionReuseStrategy(),
					new DefaultHttpResponseFactory());

			httpService.setParams(params);
			httpService.setHandlerResolver(reqistry);
		}

		public void run()
		{
			WebServer.log.info("WebServer starting on port "
					+ serversocket.getLocalPort());
			while (true)
				if (!Thread.interrupted())
				{
					try
					{
						Socket socket = serversocket.accept();
						socket.setSendBufferSize(WebServer.socketBuffer);
						UniversalHttpServerConnection conn = new UniversalHttpServerConnection(
								UUID.randomUUID().toString());
						conn.bind(socket, params);

						Thread t = new WebServer.WorkerThread(httpService, conn);
						t.setDaemon(true);
						t.start();
					}
					catch (InterruptedIOException ex)
					{
					}
					catch (SocketException e)
					{
						WebServer.log.debug_("Socket closed");
					}
					catch (IOException e)
					{
						WebServer.log.error(String.format(
								"I/O error initialising connection thread: %s",
								cast(Object[])[ e.getMessage() ]), e);
					}
				}
				else 
				{
					WebServer.log.info("WebServer shutting down");
				}
		}

		public ServerSocket getServersocket()
		{
			return serversocket;
		}
	}
}

/*
 * Location: D:\Program Files\Serviio\lib\serviio.jar Qualified Name:
 * org.serviio.upnp.webserver.WebServer JD-Core Version: 0.6.2
 */