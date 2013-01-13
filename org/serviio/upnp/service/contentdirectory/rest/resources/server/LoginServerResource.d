module org.serviio.upnp.service.contentdirectory.rest.resources.server.LoginServerResource;

import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.serviio.config.Configuration;
import org.serviio.restlet.AuthenticationException;
import org.serviio.restlet.ResultRepresentation;
import org.serviio.upnp.service.contentdirectory.rest.resources.LoginResource;
import org.serviio.util.ObjectValidator;
import org.serviio.util.SecurityUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LoginServerResource : AbstractCDSServerResource
  , LoginResource
{
  private static final String X_SERVIIO_DATE_HEADER = "X-Serviio-Date";
  private static final String AUTH_HEADER = "Authorization";
  private static final Pattern authHeaderPattern = Pattern.compile("Serviio\\s(.*)$", 2);

  private static final Logger log = LoggerFactory.getLogger!(LoginServerResource);

  private static Map!(String, Date) storedTokens = new HashMap!(String, Date)();

  public static void storeToken(String token)
  {
    storedTokens.put(token, new Date());
  }

  public static void removeToken(String token) {
    storedTokens.remove(token);
  }

  public static void validateToken(String token) {
    if (ObjectValidator.isEmpty(token)) {
      throw new AuthenticationException("No authentication token has been provided for a restricted resource.", 553);
    }
    if (storedTokens.containsKey(token))
      storeToken(token);
    else
      throw new AuthenticationException("The provided authentication token is invalid or expired.", 553);
  }

  public ResultRepresentation login()
  {
    String webPassword = Configuration.getWebPassword();
    if (ObjectValidator.isEmpty(webPassword)) {
      throw new AuthenticationException("Cannot log in with an empty password.", 556);
    }

    Map!(String, String) requestHeaders = getRequestHeaders(getRequest());
    String authHeader = getHeaderStringValue(AUTH_HEADER, requestHeaders);
    if (ObjectValidator.isEmpty(authHeader)) {
      throw new AuthenticationException("Cannot retrieve Auth header from authentication request.", 551);
    }
    String signature = getAuthenticationKey(authHeader);

    String dateHeader = getHeaderStringValue(X_SERVIIO_DATE_HEADER, requestHeaders);
    if (dateHeader is null) {
      dateHeader = getHeaderStringValue("Date", requestHeaders);
    }
    if (ObjectValidator.isEmpty(dateHeader)) {
      throw new AuthenticationException("Cannot retrieve Date header from authentication request.", 550);
    }

    String expectedSignature = generateExpectedKey(dateHeader, webPassword);
    if (expectedSignature.equals(signature)) {
      log.debug_("Successful login, generating security token");
      String token = generateToken();
      storeToken(token);
      ResultRepresentation result = responseOk();
      result.setParameters(Collections.singletonList(token));
      return result;
    }
    throw new AuthenticationException("Received authentication doesn't match, probably wrong password.", 552);
  }

  protected String generateExpectedKey(String date, String password)
  {
    try
    {
      return SecurityUtils.generateMacAsBase64(password, date, "HmacSHA1");
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }

  protected String getAuthenticationKey(String headerHalue) {
    Matcher m = authHeaderPattern.matcher(headerHalue);
    String key = null;
    if (m.matches()) {
      key = m.group(1);
    }
    if (ObjectValidator.isEmpty(key)) {
      throw new AuthenticationException("Value of Auth header from authentication request is invalid.", 551);
    }
    return key;
  }

  private String generateToken() {
    return UUID.randomUUID().toString().replaceAll("-", "");
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.rest.resources.server.LoginServerResource
 * JD-Core Version:    0.6.2
 */