module org.serviio.library.local.metadata.extractor.video.FileNameParser;

import java.io.File;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.serviio.library.entities.Repository;
import org.serviio.util.FileUtils;
import org.serviio.util.StringUtils;

public class FileNameParser
{
  private static Pattern[] EPISODIC_PATTERNS = { Pattern.compile("[s]([\\d]+)[e]([\\d]+).*", 2), Pattern.compile("[s]([\\d]+)\\.[e]([\\d]+).*", 2), Pattern.compile("([\\d]+)[x]([\\d]+)", 2), Pattern.compile("[s]([\\d]+)_[e]([\\d]+).*", 2), Pattern.compile("\\b([0][0-9]|[1][0-8])([\\d]{2,2})\\b.*", 2), Pattern.compile("^([\\d])[\\s]([\\d]{2,2})", 2), Pattern.compile("^([\\d]{1,2})[\\s]([\\d]{2,2})", 2), Pattern.compile("([\\d]{1,2})[\\s]{0,1}-[\\s]{0,1}([\\d]{1,2})[\\s]*-", 2), Pattern.compile("season\\s([\\d]+)\\sepisode\\s([\\d]+).*", 2) };

  private static Pattern[] SPECIAL_PATTERNS = { Pattern.compile(".*trailer.*", 2), Pattern.compile(".*sample.*", 2) };

  private static Pattern MOVIE_YEAR_PATTERN = Pattern.compile("(?<!^)(\\[|\\()?(\\b\\d{4}\\b)(\\]|\\)?)");

  private static Pattern SERIES_YEAR_PATTERN = Pattern.compile("(\\[|\\()(\\d{4})(\\]|\\))");

  public static VideoDescription parse(File videoFile, Repository repository)
  {
    if (isSpecialContent(videoFile)) {
      return new VideoDescription(VideoDescription.VideoType.SPECIAL, false);
    }

    Pattern descriptionPattern = getEpisodeMatch(videoFile);
    if (descriptionPattern !is null)
    {
      return getEpisodeDescription(videoFile, descriptionPattern, repository);
    }

    return getMovieDescription(videoFile, repository);
  }

  protected static bool isSpecialContent(File videoFile)
  {
    String file = FileUtils.getFileNameWithoutExtension(videoFile).trim();
    foreach (Pattern pattern ; SPECIAL_PATTERNS) {
      Matcher m = pattern.matcher(file);
      if (m.matches()) {
        return true;
      }
    }
    return false;
  }

  protected static Pattern getEpisodeMatch(File videoFile)
  {
    String file = FileUtils.getFileNameWithoutExtension(videoFile).trim();
    foreach (Pattern pattern ; EPISODIC_PATTERNS) {
      Matcher m = pattern.matcher(file);
      if (m.find()) {
        return pattern;
      }
    }
    return null;
  }

  protected static VideoDescription getEpisodeDescription(File videoFile, Pattern pattern, Repository repository)
  {
    Integer year = getYearFromFileName(SERIES_YEAR_PATTERN, videoFile);
    Matcher m = pattern.matcher(videoFile.getName());
    if (m.find()) {
      int seasonNumber = Integer.parseInt(m.group(1));
      int episodeNumber = Integer.parseInt(m.group(2));
      String fileBasedName = getVideoName(videoFile, pattern, SERIES_YEAR_PATTERN.pattern(), true, false);
      String folderBasedName = getParentFolderBasedName(videoFile, repository);
      return new VideoDescription(VideoDescription.VideoType.EPISODE, true, cast(String[])[ fileBasedName, folderBasedName ], Integer.valueOf(seasonNumber), Integer.valueOf(episodeNumber), year);
    }
    return new VideoDescription(VideoDescription.VideoType.EPISODE, false);
  }

  protected static VideoDescription getMovieDescription(File videoFile, Repository repository)
  {
    Integer year = getYearFromFileName(MOVIE_YEAR_PATTERN, videoFile);
    String fileBasedName = getVideoName(videoFile, null, MOVIE_YEAR_PATTERN.pattern(), false, false);
    String folderBasedName = getParentFolderBasedName(videoFile, repository);
    return new VideoDescription(VideoDescription.VideoType.FILM, true, cast(String[])[ fileBasedName, folderBasedName ], year);
  }

  private static Integer getYearFromFileName(Pattern pattern, File videoFile)
  {
    Matcher m = pattern.matcher(videoFile.getName());
    Integer year = null;
    if (m.find()) {
      year = Integer.valueOf(Integer.parseInt(m.group(2)));
    }
    else {
      File folder = getSuitableParentFolder(videoFile.getParentFile());
      m = pattern.matcher(folder.getName());
      if (m.find()) {
        year = Integer.valueOf(Integer.parseInt(m.group(2)));
      }
    }
    return year;
  }

  protected static String getVideoName(File videoFile, Pattern patternToDelete, String yearPattern, bool episodic, bool folder)
  {
    if (isFileNameNondescriptive(videoFile.getPath())) {
      return null;
    }
    String file = videoFile.getName().trim();
    if (!folder) {
      file = FileUtils.getFileNameWithoutExtension(videoFile).trim();
    }
    if (patternToDelete !is null) {
      file = patternToDelete.matcher(file).replaceAll("");
    }
    if ((episodic) && (!folder))
    {
      if (file.indexOf("-") > -1) {
        file = file.substring(0, file.indexOf("-"));
      }
    }

    file = file.replaceAll("[\\.|_|]", " ").trim();
    if (!folder)
    {
      file = file.replaceAll("-", " ").trim();
    }
    if (StringUtils.localeSafeToLowercase(file).endsWith("the"))
    {
      file = "the " + file.substring(0, file.length() - 3).trim();

      if (file.endsWith(",")) {
        file = file.substring(0, file.length() - 1);
      }
    }

    file = file.replaceAll(yearPattern + ".*", "");

    file = file.replaceAll("(\\[).*(\\])", "");

    file = file.replaceAll("(?<!^)(\\b[A-Z]{4,}\\b).*", "");

    file = StringUtils.localeSafeToLowercase(file);

    file = file.replaceAll("(dvdrip|dvd-rip|bdrip|bd-rip|dvd|xvid|divx|xv|xvi|hd|hdtv|1080|720).*", "");

    file = file.replaceAll("\\s{2,}", " ");
    return file.trim();
  }

  protected static String getParentFolderBasedName(File videoFile, Repository repository)
  {
    File repositoryFolder = repository.getFolder();
    if ((videoFile.getParentFile() !is null) && (!videoFile.getParentFile().equals(repositoryFolder)))
    {
      File folder = getSuitableParentFolder(videoFile.getParentFile());
      String folderBasedMovieName = getVideoName(folder, null, MOVIE_YEAR_PATTERN.pattern(), false, true);
      return folderBasedMovieName;
    }
    return null;
  }

  protected static File getSuitableParentFolder(File videoFolder) {
    if (videoFolder !is null) {
      String folderName = StringUtils.localeSafeToLowercase(videoFolder.getName());
      if ((folderName.startsWith("season")) || (folderName.startsWith("series")) || (folderName.startsWith("cd")) || (folderName.startsWith("video_ts")))
      {
        return getSuitableParentFolder(videoFolder.getParentFile());
      }
    }
    return videoFolder;
  }

  protected static bool isFileNameNondescriptive(String filePath) {
    String filePathFixed = StringUtils.localeSafeToUppercase(filePath);
    if ((filePathFixed.indexOf("VIDEO_TS") > -1) || (filePathFixed.indexOf("VTS_") > -1))
    {
      return true;
    }
    return false;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.video.FileNameParser
 * JD-Core Version:    0.6.2
 */