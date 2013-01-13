module org.serviio.library.local.metadata.extractor.video.TheMovieDBSourceAdaptor;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URLEncoder;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import javax.xml.namespace.NamespaceContext;
import javax.xml.xpath.XPathExpressionException;
import org.apache.sanselan.ImageInfo;
import org.apache.sanselan.Sanselan;
import org.serviio.config.Configuration;
import org.serviio.library.local.OnlineDBIdentifier;
import org.serviio.library.local.metadata.ImageDescriptor;
import org.serviio.library.local.metadata.VideoMetadata;
import org.serviio.util.HttpClient;
import org.serviio.util.ObjectValidator;
import org.serviio.util.StringUtils;
import org.serviio.util.XPathUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class TheMovieDBSourceAdaptor : SearchSourceAdaptor
{
	private static final String APIKEY = "33a37a299fe4bef416e347c2fca2494c";
	private static final String API_BASE_CONTEXT = "http://api.themoviedb.org/2.1/";
	private static final Logger log = LoggerFactory
			.getLogger!(TheMovieDBSourceAdaptor);

	private static final DateFormat releaseDateFormat = new SimpleDateFormat(
			"yyyy-MM-dd");

	private static final NamespaceContext namespaceContext = new OpenSearchNamespaceContext();

	public void retrieveMetadata(String movieId, VideoMetadata videoMetadata)
	{
		String movieXML = getMovieDetails(movieId);
		if (ObjectValidator.isNotEmpty(movieXML))
			try
			{
				Node rootMovieNode = XPathUtil.getRootNode(movieXML);
				Node movieNode = XPathUtil.getNode(rootMovieNode,
						"OpenSearchDescription/movies/movie");

				if (movieNode is null)
				{
					throw new IOException(String.format(
							"Problem retrieving metadata for movie with id %s",
							cast(Object[])[ movieId ]));
				}
				Integer numberReturned = Integer
						.valueOf(Integer.parseInt(XPathUtil
								.getNodeValue(
										rootMovieNode,
										"OpenSearchDescription/opensearch:totalResults",
										namespaceContext)));
				if (numberReturned.intValue() == 0)
				{
					throw new IOException(
							String.format(
									"Metadata of movie with id %s (as returned from search) cannot be retrieved",
									cast(Object[])[ movieId ]));
				}

				videoMetadata.setTitle(getMovieTitle(movieNode));
				videoMetadata.setDescription(StringUtils.trim(XPathUtil
						.getNodeValue(movieNode, "overview")));
				String genre = XPathUtil.getNodeValue(movieNode,
						"categories/category[@type='genre'][1]/@name");
				if (ObjectValidator.isNotEmpty(genre))
				{
					videoMetadata.setGenre(StringUtils.trim(genre));
				}
				videoMetadata.setDate(getReleaseDate(XPathUtil.getNodeValue(
						movieNode, "released")));
				videoMetadata.setActors(getCast(XPathUtil.getNodeSet(movieNode,
						"cast/person[@job='Actor']")));
				videoMetadata.setDirectors(getCast(XPathUtil.getNodeSet(
						movieNode, "cast/person[@job='Director']")));
				videoMetadata.setProducers(getCast(XPathUtil.getNodeSet(
						movieNode, "cast/person[@job='Producer']")));

				videoMetadata.getOnlineIdentifiers().put(
						OnlineDBIdentifier.TMDB, movieId);
				String imdbId = XPathUtil.getNodeValue(movieNode, "imdb_id");
				if (ObjectValidator.isNotEmpty(imdbId))
				{
					videoMetadata.getOnlineIdentifiers().put(
							OnlineDBIdentifier.IMDB, imdbId.trim());
				}

				if (Configuration.isRetrieveArtFromOnlineSources())
				{
					NodeList posters = XPathUtil.getNodeSet(movieNode,
							"images/image[@type='poster' and @size='cover']");
					if (posters !is null)
					{
						for (int i = 0; i < posters.getLength(); i++)
						{
							Node posterNode = posters.item(i);
							String posterURL = XPathUtil.getNodeValue(
									posterNode, "@url");
							if (ObjectValidator.isNotEmpty(posterURL))
								try
								{
									byte[] bannerBytes = HttpClient
											.retrieveBinaryFileFromURL(posterURL);
									ImageInfo imageInfo = Sanselan
											.getImageInfo(bannerBytes);
									ImageDescriptor image = new ImageDescriptor(
											bannerBytes,
											imageInfo.getMimeType());
									videoMetadata.setCoverImage(image);
									log.debug_(String.format(
											"Retrieved poster: %s",
											cast(Object[])[ posterURL ]));
								}
								catch (FileNotFoundException e)
								{
									log.warn(String
											.format("Poster '%s' doesn't exist, will try another one",
													cast(Object[])[ posterURL ]));
								}
								catch (Exception e)
								{
									log.warn(String.format(
											"Cannot retrieve movie poster: %s",
											cast(Object[])[ e.getMessage() ]));
								}
						}
					}
				}
			}
			catch (XPathExpressionException e)
			{
				throw new IOException(String.format(
						"Metadata XML for movie id %s is corrupt. ",
						cast(Object[])[ movieId ]));
			}
		else
			throw new IOException("Metadata XML file is missing");
	}

	public String search(VideoDescription description)
	{
		String movieId = searchForMovie(description.getNames(),
				description.getYear());
		return movieId;
	}

	private String searchForMovie(String[] movieNames, Integer releaseYear)
	{
		List!(Node) returnedMovieNodes = findAllSearchMatches(movieNames, releaseYear);

		if (returnedMovieNodes.size() > 0)
		{
			try
			{
				List!(Node) moviesWithMatchingName = filterMovieNodesForNameMatch(
						returnedMovieNodes, movieNames);
				Node matchingMovieNode = null;
				if (moviesWithMatchingName.size() > 0)
				{
					matchingMovieNode = cast(Node) moviesWithMatchingName.get(0);
				}
				else
				{
					matchingMovieNode = cast(Node) returnedMovieNodes.get(0);
				}
				if (matchingMovieNode !is null)
				{
					String movieId = XPathUtil.getNodeValue(matchingMovieNode,
							"id");
					log.debug_(String.format(
							"Found a suitable movie match, id = %s",
							cast(Object[])[ movieId ]));
					return movieId;
				}
			}
			catch (XPathExpressionException e)
			{
				throw new IOException(String.format(
						"Cannot retrieve movie search results: %s",
						cast(Object[])[ e.getMessage() ]));
			}
		}
		else
		{
			log.debug_("No movie with the name has been found");
		}
		return null;
	}

	private List!(Node) findAllSearchMatches(String[] movieNames, Integer year)
	{
		List!(Node) allReturnedNodes = new ArrayList!(Node)();
		String languageCode = Configuration.getMetadataPreferredLanguage();
		foreach (String movieName ; movieNames)
		{
			if (ObjectValidator.isNotEmpty(movieName))
			{
				log.debug_(String.format(
						"Searching for movie '%s' %s (language: %s)",
						cast(Object[])[ movieName, year !is null ? year : "",
								languageCode ]));
				try
				{
					String searchTerm = String.format("%s%s", cast(Object[])[
							movieName, year !is null ? " " + year : "" ]);

					String moviesSearchPath = String.format(
							"%sMovie.search/%s/xml/%s/%s", cast(Object[])[
									API_BASE_CONTEXT,
									languageCode,
									APIKEY,
									URLEncoder.encode(searchTerm, "UTF-8") ]);

					String searchResultXML = HttpClient
							.retrieveTextFileFromURL(moviesSearchPath, "UTF-8");
					if ((ObjectValidator.isNotEmpty(searchResultXML))
							&& (searchResultXML.startsWith("<?xml")))
					{
						Node rootNode = XPathUtil.getRootNode(searchResultXML);
						Integer numberReturned = Integer
								.valueOf(Integer.parseInt(XPathUtil
										.getNodeValue(
												rootNode,
												"OpenSearchDescription/opensearch:totalResults",
												namespaceContext)));
						log.debug_(String.format("Found %s matches",
								cast(Object[])[ numberReturned ]));
						if (numberReturned.intValue() > 0)
						{
							NodeList movieNodes = XPathUtil.getNodeSet(
									rootNode,
									"OpenSearchDescription/movies/movie");
							allReturnedNodes.addAll(XPathUtil
									.getListOfNodes(movieNodes));
						}
					}
					else
					{
						log.warn("Cannot retrieve movie search results, unrecognizable file returned (possibly error)");
					}
				}
				catch (FileNotFoundException fnfe)
				{
					throw new IOException(
							"Cannot retrieve movie search results, file not found");
				}
				catch (Exception e)
				{
					throw new IOException(String.format(
							"Cannot retrieve movie search results: %s",
							cast(Object[])[ e.getMessage() ]));
				}
			}
		}
		return allReturnedNodes;
	}

	private String getMovieDetails(String movieId)
	{
		String languageCode = Configuration.getMetadataPreferredLanguage();
		log.debug_(String.format(
				"Retrieving details of movie (movieId = %s, language = %s)",
				cast(Object[])[ movieId, languageCode ]));
		try
		{
			String movieDetailsPath = String.format(
					"%sMovie.getInfo/%s/xml/%s/%s", cast(Object[])[
							API_BASE_CONTEXT, languageCode,
							APIKEY, movieId ]);
			String movieXML = HttpClient.retrieveTextFileFromURL(
					movieDetailsPath, "UTF-8");
			if ((ObjectValidator.isNotEmpty(movieXML))
					&& (movieXML.startsWith("<?xml")))
			{
				return movieXML;
			}
			throw new IOException(
					"Cannot retrieve movie details, returned document is empty (possible error)");
		}
		catch (FileNotFoundException fnfe)
		{
			throw new IOException(
					String.format(
							"Cannot retrieve movie details (movieId = %s), file not found",
							cast(Object[])[ movieId ]));
		}
		catch (Exception e)
		{
			throw new IOException(String.format(
					"Cannot retrieve movie details (movieId = %s) : %s",
					cast(Object[])[ movieId , e.getMessage()]));
		}
	}

	private List!(Node) filterMovieNodesForNameMatch(List!(Node) movieNodes,
			String[] movieNames)
	{
		List!(Node) result = new ArrayList!(Node)();
		if ((movieNodes !is null) && (movieNodes.size() > 0))
		{
			for (int i = 0; i < movieNodes.size(); i++)
			{
				Node movieNode = cast(Node) movieNodes.get(i);
				String name = XPathUtil.getNodeValue(movieNode, "name");
				String originalName = XPathUtil.getNodeValue(movieNode,
						"original_name");
				NodeList altNamesNodes = XPathUtil.getNodeSet(movieNode,
						"alternative_name");
				List!(String) altNames = new ArrayList!(String)();
				for (int j = 0; j < altNamesNodes.getLength(); j++)
				{
					Node altNameNode = altNamesNodes.item(j);
					String altName = altNameNode.getTextContent();
					if (ObjectValidator.isNotEmpty(altName))
					{
						altNames.add(StringUtils.localeSafeToLowercase(altName)
								.trim());
					}
				}
				foreach (String movieName ; movieNames)
				{
					if (movieName !is null)
					{
						String trimmedMovieName = StringUtils
								.localeSafeToLowercase(movieName).trim();
						if (((name !is null) && (trimmedMovieName
								.equalsIgnoreCase(name.trim())))
								|| (altNames.contains(trimmedMovieName))
								|| ((originalName !is null) && (trimmedMovieName
										.equalsIgnoreCase(originalName.trim()))))
						{
							result.add(movieNode);
							break;
						}
					}
				}
			}
		}
		return result;
	}

	private List!(String) getCast(NodeList personNodeList)
	{
		List!(String) result = new ArrayList!(String)();
		if ((personNodeList !is null) && (personNodeList.getLength() > 0))
		{
			for (int i = 0; i < personNodeList.getLength(); i++)
			{
				Node castNode = personNodeList.item(i);
				result.add(StringUtils.trim(XPathUtil.getNodeValue(castNode,
						"@name")));
			}
		}
		return result;
	}

	private Date getReleaseDate(String releaseDateString)
	{
		if (ObjectValidator.isNotEmpty(releaseDateString))
		{
			try
			{
				return releaseDateFormat.parse(releaseDateString.trim());
			}
			catch (ParseException e)
			{
				return null;
			}
		}
		return null;
	}

	private String getMovieTitle(Node movieNode)
	{
		String title = StringUtils.trim(XPathUtil.getNodeValue(movieNode,
				"name"));
		if (Configuration.isMetadataUseOriginalTitle())
		{
			String originalTitle = StringUtils.trim(XPathUtil.getNodeValue(
					movieNode, "original_name"));
			if (ObjectValidator.isNotEmpty(originalTitle))
			{
				title = originalTitle;
			}
		}
		return title;
	}

	private static class OpenSearchNamespaceContext : NamespaceContext
	{
		public String getNamespaceURI(String prefix)
		{
			if (prefix is null)
				throw new NullPointerException("Null prefix");
			if ("opensearch".equals(prefix))
			{
				return "http://a9.com/-/spec/opensearch/1.1/";
			}
			return "";
		}

		public String getPrefix(String uri)
		{
			throw new UnsupportedOperationException();
		}

		public Iterator!(Object) getPrefixes(String uri)
		{
			throw new UnsupportedOperationException();
		}
	}
}

/*
 * Location: D:\Program Files\Serviio\lib\serviio.jar Qualified Name:
 * org.serviio.library.local.metadata.extractor.video.TheMovieDBSourceAdaptor
 * JD-Core Version: 0.6.2
 */