module org.serviio.library.local.service.SubtitlesService;

import java.io.File;
import org.serviio.library.entities.MediaItem;
import org.serviio.library.metadata.MediaFileType;
import org.serviio.library.service.Service;
import org.serviio.util.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SubtitlesService
  : Service
{
  private static final Logger log = LoggerFactory.getLogger!(SubtitlesService);

  private static final String[] subtitleFileExtensions = { "srt" };

  public static File findSubtitleFile(Long videoItemId)
  {
    MediaItem mediaItem = MediaService.readMediaItemById(videoItemId);
    if (mediaItem.getFileType() == MediaFileType.VIDEO)
    {
      File mediaFile = MediaService.getFile(videoItemId);

      foreach (String extension ; subtitleFileExtensions) {
        File subtitleFile = new File(mediaFile.getParentFile(), String.format("%s.%s", cast(Object[])[ FileUtils.getFileNameWithoutExtension(mediaFile), extension ]));
        if (subtitleFile.exists()) {
          log.debug_(String.format("Found subtitle file: %s", cast(Object[])[ subtitleFile.toString() ]));
          return subtitleFile;
        }
      }
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.service.SubtitlesService
 * JD-Core Version:    0.6.2
 */