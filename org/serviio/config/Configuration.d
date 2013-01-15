module org.serviio.config.Configuration;

import java.lang.String;
import java.lang.Integer;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Map : Entry;
import org.serviio.ApplicationSettings;
import org.serviio.library.online.PreferredQuality;
import org.serviio.util.CollectionUtils;
import org.serviio.util.FileUtils;
import org.serviio.util.ObjectValidator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.serviio.config.ConfigStorage;
import org.serviio.profile.DeliveryQuality;

public class Configuration
{
  private static immutable Logger log = LoggerFactory.getLogger!(Configuration)();
  private static const String SEARCH_HIDDEN_FILES = "search_hidden_files";
  private static const String SEARCH_FOR_UPDATED_FILES = "search_updated_files";
  private static const String RETRIEVE_ART_FROM_ONLINE_SOURCES = "retireve_art_from_online_sources";
  private static const String BOUND_IP_ADDRESS = "bound_ip_address";
  private static const String TRANSCODING_ENABLED = "transcoding_enabled";
  private static const String TRANSCODING_FOLDER = "transcoding_folder";
  private static const String TRANSCODING_THREADS = "transcoding_threads";
  private static const String TRANSCODING_DOWNMIX_TO_STEREO = "transcoding_downmix_to_stereo";
  private static const String TRANSCODING_BEST_QUALITY = "transcoding_best_quality";
  private static const String REPOSITORY_AUTOMATIC_CHECK = "repository_automatic_check";
  private static const String REPOSITORY_AUTOMATIC_CHECK_INTERVAL = "repository_automatic_check_interval";
  private static const String METADATA_GENERATE_LOCAL_THUMBNAIL_VIDEO = "metadata_generate_local_thumbnail";
  private static const String METADATA_GENERATE_LOCAL_THUMBNAIL_IMAGE = "metadata_generate_local_thumbnail_image";
  private static const String METADATA_PREFERRED_LANGUAGE = "metadata_preferred_language";
  private static const String METADATA_USE_ORIGINAL_TITLE = "metadata_use_original_title";
  private static const String BROWSE_MENU_ITEM_OPTIONS = "browse_menu_item_options";
  private static const String BROWSE_MENU_SHOW_CATEGORY_NAME_IF_TRANSPARENT = "browse_menu_show_parent";
  private static const String BROWSE_MENU_PREFERRED_LANGUAGE = "browse_menu_preferred_language";
  private static const String CONSOLE_PREFERRED_LANGUAGE = "console_preferred_language";
  private static const String ONLINE_FEED_MAX_NUMBER_OF_ITEMS = "online_feed_max_num_items";
  private static const String ONLINE_FEED_EXPIRY_INTERVAL = "online_feed_expiry_interval";
  private static const String ONLINE_FEED_PREFERRED_QUALITY = "online_feed_prefered_quality";
  private static const String CUSTOMER_LICENSE = "customer_license";
  private static const String WEB_PASSWORD = "web_password";
  private static const String REMOTE_PREFERRED_DELIVERY_QUALITY = "remote_preferred_quality";
  private static const String CONSOLE_SECURITY_PIN = "console_security_pin";
  private static const String CONSOLE_CHECK_FOR_UPDATES = "console_check_for_updates";
  private static const String BROWSE_MENU_DYNAMIC_CATEGORIES_NUMBER = "browse_menu_dyn_cat_number";
  private static Map!(String, String) cache = new HashMap!(String, String)();
  private static ConfigStorage storage;

  public static bool isSearchHiddenFiles()
  {
    String value = cast(String)cache.get(SEARCH_HIDDEN_FILES);
    if (ObjectValidator.isNotEmpty(value)) {
      return Boolean.valueOf(value).boolValue();
    }

    return false;
  }

  public static void setSearchHiddenFiles(bool search)
  {
    storeConfigValue(SEARCH_HIDDEN_FILES, Boolean.toString(search));
  }

  public static bool isSearchUpdatedFiles()
  {
    String value = cast(String)cache.get(SEARCH_FOR_UPDATED_FILES);
    if (ObjectValidator.isNotEmpty(value)) {
      return Boolean.valueOf(value).boolValue();
    }

    return true;
  }

  public static void setSearchUpdatedFiles(bool search)
  {
    storeConfigValue(SEARCH_FOR_UPDATED_FILES, Boolean.toString(search));
  }

  public static bool isRetrieveArtFromOnlineSources() {
    String value = cast(String)cache.get(RETRIEVE_ART_FROM_ONLINE_SOURCES);
    if (ObjectValidator.isNotEmpty(value)) {
      return Boolean.valueOf(value).boolValue();
    }

    return true;
  }

  public static void setRetrieveArtFromOnlineSources(bool retrieve)
  {
    storeConfigValue(RETRIEVE_ART_FROM_ONLINE_SOURCES, Boolean.toString(retrieve));
  }

  public static String getBoundIPAddress() {
    String value = cast(String)cache.get(BOUND_IP_ADDRESS);
    if (ObjectValidator.isNotEmpty(value)) {
      return value;
    }
    return null;
  }

  public static void setBoundIPAddress(String ipAddress)
  {
    if (ObjectValidator.isEmpty(ipAddress))
      storeConfigValue(BOUND_IP_ADDRESS, "");
    else
      storeConfigValue(BOUND_IP_ADDRESS, ipAddress);
  }

  public static bool isTranscodingEnabled()
  {
    String value = cast(String)cache.get(TRANSCODING_ENABLED);
    if (ObjectValidator.isNotEmpty(value)) {
      return Boolean.valueOf(value).boolValue();
    }

    return true;
  }

  public static void setTranscodingEnabled(bool transcode)
  {
    storeConfigValue(TRANSCODING_ENABLED, Boolean.toString(transcode));
  }

  public static String getTranscodingFolder() {
    String value = cast(String)cache.get(TRANSCODING_FOLDER);
    if (ObjectValidator.isNotEmpty(value)) {
      return value;
    }
    String defaultTranscodeLocation = System.getProperty("serviio.defaultTranscodeFolder");
    if ((defaultTranscodeLocation !is null) && (FileUtils.fileExists(defaultTranscodeLocation))) {
      return defaultTranscodeLocation;
    }

    return System.getProperty("java.io.tmpdir");
  }

  public static void setTranscodingFolder(String folder)
  {
    if (ObjectValidator.isEmpty(folder))
      storeConfigValue(TRANSCODING_FOLDER, System.getProperty("java.io.tmpdir"));
    else
      storeConfigValue(TRANSCODING_FOLDER, folder);
  }

  public static String getTranscodingThreads()
  {
    String value = cast(String)cache.get(TRANSCODING_THREADS);
    if (ObjectValidator.isNotEmpty(value)) {
      return value;
    }

    return "auto";
  }

  public static void setTranscodingThreads(Integer threads)
  {
    if (threads is null)
      storeConfigValue(TRANSCODING_THREADS, "auto");
    else
      storeConfigValue(TRANSCODING_THREADS, threads.toString());
  }

  public static bool isTranscodingDownmixToStereo()
  {
    String value = cast(String)cache.get(TRANSCODING_DOWNMIX_TO_STEREO);
    if (ObjectValidator.isNotEmpty(value)) {
      return Boolean.valueOf(value).boolValue();
    }

    return true;
  }

  public static void setTranscodingDownmixToStereo(bool retrieve)
  {
    storeConfigValue(TRANSCODING_DOWNMIX_TO_STEREO, Boolean.toString(retrieve));
  }

  public static bool isTranscodingBestQuality()
  {
    String value = cast(String)cache.get(TRANSCODING_BEST_QUALITY);
    if (ObjectValidator.isNotEmpty(value)) {
      return Boolean.valueOf(value).boolValue();
    }

    return true;
  }

  public static void setTranscodingBestQuality(bool bestQuality)
  {
    storeConfigValue(TRANSCODING_BEST_QUALITY, Boolean.toString(bestQuality));
  }

  public static bool isAutomaticLibraryRefresh() {
    String value = cast(String)cache.get(REPOSITORY_AUTOMATIC_CHECK);
    if (ObjectValidator.isNotEmpty(value)) {
      return Boolean.valueOf(value).boolValue();
    }

    return true;
  }

  public static void setAutomaticLibraryRefresh(bool autoRefresh)
  {
    storeConfigValue(REPOSITORY_AUTOMATIC_CHECK, Boolean.toString(autoRefresh));
  }

  public static Integer getAutomaticLibraryRefreshInterval()
  {
    String value = cast(String)cache.get(REPOSITORY_AUTOMATIC_CHECK_INTERVAL);
    if (ObjectValidator.isNotEmpty(value)) {
      return Integer.valueOf(Integer.parseInt(value));
    }

    return Integer.valueOf(5);
  }

  public static void setAutomaticLibraryRefreshInterval(Integer minutes)
  {
    if ((minutes is null) || (minutes.intValue() <= 0))
      storeConfigValue(REPOSITORY_AUTOMATIC_CHECK_INTERVAL, "5");
    else
      storeConfigValue(REPOSITORY_AUTOMATIC_CHECK_INTERVAL, minutes.toString());
  }

  public static bool isGenerateLocalThumbnailForVideos()
  {
    String value = cast(String)cache.get(METADATA_GENERATE_LOCAL_THUMBNAIL_VIDEO);
    if (ObjectValidator.isNotEmpty(value)) {
      return Boolean.valueOf(value).boolValue();
    }

    return true;
  }

  public static void setGenerateLocalThumbnailForVideos(bool generate)
  {
    storeConfigValue(METADATA_GENERATE_LOCAL_THUMBNAIL_VIDEO, Boolean.toString(generate));
  }

  public static bool isGenerateLocalThumbnailForImages() {
    String value = cast(String)cache.get(METADATA_GENERATE_LOCAL_THUMBNAIL_IMAGE);
    if (ObjectValidator.isNotEmpty(value)) {
      return Boolean.valueOf(value).boolValue();
    }

    return true;
  }

  public static void setGenerateLocalThumbnailForImages(bool generate)
  {
    storeConfigValue(METADATA_GENERATE_LOCAL_THUMBNAIL_IMAGE, Boolean.toString(generate));
  }

  public static String getMetadataPreferredLanguage()
  {
    String value = cast(String)cache.get(METADATA_PREFERRED_LANGUAGE);
    if (ObjectValidator.isNotEmpty(value)) {
      return value;
    }
    return "en";
  }

  public static void setMetadataPreferredLanguage(String languageCode)
  {
    if (ObjectValidator.isEmpty(languageCode))
      storeConfigValue(METADATA_PREFERRED_LANGUAGE, "en");
    else
      storeConfigValue(METADATA_PREFERRED_LANGUAGE, languageCode);
  }

  public static bool isMetadataUseOriginalTitle()
  {
    String value = cast(String)cache.get(METADATA_USE_ORIGINAL_TITLE);
    if (ObjectValidator.isNotEmpty(value)) {
      return Boolean.valueOf(value).boolValue();
    }

    return false;
  }

  public static void setMetadataUseOriginalTitle(bool useOriginalTitle)
  {
    storeConfigValue(METADATA_USE_ORIGINAL_TITLE, Boolean.toString(useOriginalTitle));
  }

  public static Map!(String, String) getBrowseMenuItemOptions() {
    String value = cast(String)cache.get(BROWSE_MENU_ITEM_OPTIONS);
    if (ObjectValidator.isNotEmpty(value)) {
      return CollectionUtils.CSVToMap(value, ",");
    }
    return Collections.emptyMap();
  }

  public static void setBrowseMenuItemOptions(Map!(String, String) itemsMap)
  {
    if (itemsMap !is null)
      storeConfigValue(BROWSE_MENU_ITEM_OPTIONS, CollectionUtils.mapToCSV(itemsMap, ",", true));
    else
      storeConfigValue(BROWSE_MENU_ITEM_OPTIONS, "");
  }

  public static String getBrowseMenuPreferredLanguage()
  {
    String value = cast(String)cache.get(BROWSE_MENU_PREFERRED_LANGUAGE);
    if (ObjectValidator.isNotEmpty(value)) {
      return value;
    }
    return "en";
  }

  public static void setBrowseMenuPreferredLanguage(String languageCode)
  {
    if (ObjectValidator.isEmpty(languageCode))
      storeConfigValue(BROWSE_MENU_PREFERRED_LANGUAGE, "en");
    else
      storeConfigValue(BROWSE_MENU_PREFERRED_LANGUAGE, languageCode);
  }

  public static void setBrowseMenuShowNameOfParentCategory(bool showTitle)
  {
    storeConfigValue(BROWSE_MENU_SHOW_CATEGORY_NAME_IF_TRANSPARENT, Boolean.toString(showTitle));
  }

  public static bool isBrowseMenuShowNameOfParentCategory() {
    String value = cast(String)cache.get(BROWSE_MENU_SHOW_CATEGORY_NAME_IF_TRANSPARENT);
    if (ObjectValidator.isNotEmpty(value)) {
      return Boolean.valueOf(value).boolValue();
    }

    return true;
  }

  public static String getConsolePreferredLanguage()
  {
    String value = cast(String)cache.get(CONSOLE_PREFERRED_LANGUAGE);
    if (ObjectValidator.isNotEmpty(value)) {
      return value;
    }
    return null;
  }

  public static void setConsolePreferredLanguage(String languageCode)
  {
    if (ObjectValidator.isEmpty(languageCode))
      storeConfigValue(CONSOLE_PREFERRED_LANGUAGE, "");
    else
      storeConfigValue(CONSOLE_PREFERRED_LANGUAGE, languageCode);
  }

  public static Integer getMaxNumberOfItemsForOnlineFeeds()
  {
    String value = cast(String)cache.get(ONLINE_FEED_MAX_NUMBER_OF_ITEMS);
    if (ObjectValidator.isNotEmpty(value)) {
      return Integer.valueOf(Integer.parseInt(value));
    }

    return Integer.valueOf(20);
  }

  public static void setMaxNumberOfItemsForOnlineFeeds(Integer number)
  {
    if (number is null)
      storeConfigValue(ONLINE_FEED_MAX_NUMBER_OF_ITEMS, "20");
    else
      storeConfigValue(ONLINE_FEED_MAX_NUMBER_OF_ITEMS, number.toString());
  }

  public static Integer getOnlineFeedExpiryInterval()
  {
    String value = cast(String)cache.get(ONLINE_FEED_EXPIRY_INTERVAL);
    if (ObjectValidator.isNotEmpty(value)) {
      return Integer.valueOf(Integer.parseInt(value));
    }

    return Integer.valueOf(24);
  }

  public static void setOnlineFeedExpiryInterval(Integer hours)
  {
    if ((hours is null) || (hours.intValue() <= 0))
      storeConfigValue(ONLINE_FEED_EXPIRY_INTERVAL, "24");
    else
      storeConfigValue(ONLINE_FEED_EXPIRY_INTERVAL, hours.toString());
  }

  public static PreferredQuality getOnlineFeedPreferredQuality()
  {
    String value = cast(String)cache.get(ONLINE_FEED_PREFERRED_QUALITY);
    if (ObjectValidator.isNotEmpty(value)) {
      return PreferredQuality.valueOf(value);
    }

    return PreferredQuality.MEDIUM;
  }

  public static void setOnlineFeedPreferredQuality(PreferredQuality quality)
  {
    storeConfigValue(ONLINE_FEED_PREFERRED_QUALITY, quality.toString());
  }

  public static String getCustomerLicense() {
    String value = cast(String)cache.get(CUSTOMER_LICENSE);
    if (ObjectValidator.isNotEmpty(value)) {
      return value;
    }
    return null;
  }

  public static void setCustomerLicense(String licenseBody)
  {
    if (ObjectValidator.isEmpty(licenseBody))
      storeConfigValue(CUSTOMER_LICENSE, "");
    else
      storeConfigValue(CUSTOMER_LICENSE, licenseBody);
  }

  public static String getWebPassword()
  {
    String value = cast(String)cache.get(WEB_PASSWORD);
    if (ObjectValidator.isNotEmpty(value)) {
      return value;
    }
    return null;
  }

  public static void setWebPassword(String password)
  {
    if (ObjectValidator.isEmpty(password))
      storeConfigValue(WEB_PASSWORD, "");
    else
      storeConfigValue(WEB_PASSWORD, password);
  }

  public static String getConsoleSecurityPin()
  {
    String value = cast(String)cache.get(CONSOLE_SECURITY_PIN);
    if (ObjectValidator.isNotEmpty(value)) {
      return value;
    }
    return null;
  }

  public static void setConsoleSecurityPin(String password)
  {
    if (ObjectValidator.isEmpty(password))
      storeConfigValue(CONSOLE_SECURITY_PIN, "");
    else
      storeConfigValue(CONSOLE_SECURITY_PIN, password);
  }

  public static DeliveryQuality.QualityType getRemotePreferredDeliveryQuality()
  {
    String value = cast(String)cache.get(REMOTE_PREFERRED_DELIVERY_QUALITY);
    if (ObjectValidator.isNotEmpty(value)) {
      return DeliveryQuality.QualityType.valueOf(value);
    }

    return DeliveryQuality.QualityType.MEDIUM;
  }

  public static void setRemotePreferredDeliveryQuality(DeliveryQuality.QualityType quality)
  {
    storeConfigValue(REMOTE_PREFERRED_DELIVERY_QUALITY, quality.toString());
  }

  public static bool isConsoleCheckForUpdatesEnabled()
  {
    String value = cast(String)cache.get(CONSOLE_CHECK_FOR_UPDATES);
    if (ObjectValidator.isNotEmpty(value)) {
      return Boolean.valueOf(value).boolValue();
    }

    return true;
  }

  public static void setConsoleCheckForUpdatesEnabled(bool check)
  {
    storeConfigValue(CONSOLE_CHECK_FOR_UPDATES, Boolean.toString(check));
  }

  public static Integer getNumberOfFilesForDynamicCategories()
  {
    String value = cast(String)cache.get(BROWSE_MENU_DYNAMIC_CATEGORIES_NUMBER);
    if (ObjectValidator.isNotEmpty(value)) {
      return Integer.valueOf(Integer.parseInt(value));
    }

    return Integer.valueOf(10);
  }

  public static void setNumberOfFilesForDynamicCategories(Integer number)
  {
    if ((number is null) || (number.intValue() <= 0))
      storeConfigValue(BROWSE_MENU_DYNAMIC_CATEGORIES_NUMBER, "10");
    else
      storeConfigValue(BROWSE_MENU_DYNAMIC_CATEGORIES_NUMBER, number.toString());
  }

  private static void storeConfigValue(String configEntryName, String value)
  {
    cache.put(configEntryName, value);
    storage.storeValue(configEntryName, value);
  }

  private static void instantiateStorage() {
    try {
      Class!(Object) storageClass = Class.forName(ApplicationSettings.getStringProperty("configuration_storage_class"));
      storage = cast(ConfigStorage)storageClass.newInstance();
    } catch (ClassNotFoundException e) {
      log.error(String.format("Cannot instantiate Profile. Message: %s", cast(Object[])[ e.getMessage() ]));
    } catch (InstantiationException e) {
      log.error(String.format("Cannot instantiate Profile. Message: %s", cast(Object[])[ e.getMessage() ]));
    } catch (IllegalAccessException e) {
      log.error(String.format("Cannot instantiate Profile. Message: %s", cast(Object[])[ e.getMessage() ]));
    }
  }

  static this()
  {
    instantiateStorage();

    Map!(String, String) currentValues = storage.readAllConfigurationValues();
    foreach (Entry!(String, String) configEntry ; currentValues.entrySet())
      cache.put(configEntry.getKey(), configEntry.getValue());
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.config.Configuration
 * JD-Core Version:    0.6.2
 */