module org.serviio.library.local.service.CoverImageService;

import java.lang.Integer;
import java.lang.Long;
import java.util.List;
import org.serviio.db.dao.DAOFactory;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.CoverImage;
import org.serviio.library.entities.MusicTrack;
import org.serviio.library.local.metadata.ImageDescriptor;
import org.serviio.library.service.Service;
import org.serviio.util.ImageUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CoverImageService : Service
{
    private static immutable Logger log;

    static this()
    {
        log = LoggerFactory.getLogger!(CoverImageService)();
    }

    public static Long createCoverImage(ImageDescriptor image, Integer rotation)
    {
        CoverImage coverImage = prepareCoverImage(image, rotation);
        if (coverImage !is null) {
            return Long.valueOf(DAOFactory.getCoverImageDAO().create(coverImage));
        }
        return null;
    }

    public static CoverImage prepareCoverImage(ImageDescriptor image, Integer requiredRotation)
    {
        if ((image !is null) && (image.getImageData() !is null) && (image.getImageData().length > 0)) {
            try {
                log.debug_("Resizing and storing cover art image");
                ImageDescriptor resizedImage = ImageUtils.resizeImageAsJPG(image.getImageData(), 160, 160);

                log.debug_("Image successfully resized");
                if ((requiredRotation !is null) && (!requiredRotation.equals(new Integer(0))))
                {
                    log.debug_(String.format("Rotating thumbnail image (%s)", cast(Object[])[ requiredRotation ]));
                    resizedImage = ImageUtils.rotateImage(resizedImage.getImageData(), requiredRotation.intValue());
                }
                return new CoverImage(resizedImage.getImageData(), "image/jpeg", resizedImage.getWidth().intValue(), resizedImage.getHeight().intValue());
            }
            catch (Throwable e)
            {
                log.warn(String.format("Cannot convert/resize art to JPG. Message: %s", cast(Object[])[ e.getMessage() ]));
                return null;
            }
        }
        return null;
    }

    public static Long getMusicAlbumCoverArt(Long albumId)
    {
        List!(MusicTrack) songs = DAOFactory.getMusicTrackDAO().retrieveMusicTracksForAlbum(albumId, AccessGroup.ANY, 0, 2147483647);
        foreach (MusicTrack song ; songs) {
            if (song.getThumbnailId() !is null) {
                return song.getThumbnailId();
            }
        }
        return null;
    }

    public static void removeCoverImage(Long coverImageId)
    {
        if (coverImageId !is null)
            DAOFactory.getCoverImageDAO().delete_(coverImageId);
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.local.service.CoverImageService
* JD-Core Version:    0.6.2
*/