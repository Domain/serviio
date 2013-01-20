module org.serviio.library.local.service.VideoService;

import java.lang.Long;
import java.lang.Integer;
import java.lang.String;
import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.serviio.db.dao.DAOFactory;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.MetadataDescriptor;
import org.serviio.library.entities.Person;
import org.serviio.library.entities.Repository;
import org.serviio.library.entities.Series;
import org.serviio.library.entities.Video;
import org.serviio.library.local.metadata.VideoMetadata;
import org.serviio.library.local.metadata.extractor.MetadataFile;
import org.serviio.library.service.Service;
import org.serviio.util.ObjectValidator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class VideoService : Service
{
    private static immutable Logger log;
    
    static this()
    {
        log = LoggerFactory.getLogger!(VideoService)();
    }

    public static void addVideoToLibrary(VideoMetadata metadata, Repository repository)
    {
        Long mediaItemId;
        if (metadata !is null) {
            log.debug_(String.format("Adding video into database: %s", cast(Object[])[ metadata.getTitle() ]));

            Long folderId = FolderService.createOrReadFolder(repository, metadata.getFilePath());

            Long genreId = GenreService.findOrCreateGenre(metadata.getGenre());

            Long seriesId = findOrCreateSeries(metadata.getSeriesName());

            Long coverImageId = CoverImageService.createCoverImage(metadata.getCoverImage(), null);

            Video video = new Video(metadata.getTitle(), metadata.getContainer(), (new File(metadata.getFilePath())).getName(), metadata.getFilePath(), Long.valueOf(metadata.getFileSize()), folderId, repository.getId(), metadata.getDate());

            video.setDuration(metadata.getDuration());
            video.setGenreId(genreId);
            video.setThumbnailId(coverImageId);
            video.setDescription(metadata.getDescription());
            video.setBitrate(metadata.getBitrate());
            video.setAudioBitrate(metadata.getAudioBitrate());
            video.setWidth(metadata.getWidth());
            video.setHeight(metadata.getHeight());
            video.setRating(metadata.getRating());
            video.setEpisodeNumber(metadata.getEpisodeNumber());
            video.setSeasonNumber(metadata.getSeasonNumber());
            video.setSeriesId(seriesId);
            video.setAudioCodec(metadata.getAudioCodec());
            video.setVideoCodec(metadata.getVideoCodec());
            video.setAudioStreamIndex(metadata.getAudioStreamIndex());
            video.setVideoStreamIndex(metadata.getVideoStreamIndex());
            video.setChannels(metadata.getChannels());
            video.setFps(metadata.getFps());
            video.setFrequency(metadata.getFrequency());
            video.setContentType(metadata.getContentType());
            video.setTimestampType(metadata.getTimestampType());
            video.setH264Profile(metadata.getH264Profile());
            video.setH264Levels(metadata.getH264Levels());
            video.setFtyp(metadata.getFtyp());
            video.setSar(metadata.getSar());
            video.setVideoFourCC(metadata.getVideoFourCC());
            video.setOnlineIdentifiers(metadata.getOnlineIdentifiers());

            mediaItemId = Long.valueOf(DAOFactory.getVideoDAO().create(video));

            if (metadata.getDirectors() !is null) {
                foreach (String director ; metadata.getDirectors()) {
                    DAOFactory.getPersonDAO().addPersonToMedia(director, Person.RoleType.DIRECTOR, mediaItemId);
                }
            }
            if (metadata.getProducers() !is null) {
                foreach (String producer ; metadata.getProducers()) {
                    DAOFactory.getPersonDAO().addPersonToMedia(producer, Person.RoleType.PRODUCER, mediaItemId);
                }
            }
            if (metadata.getActors() !is null) {
                foreach (String actor ; metadata.getActors()) {
                    DAOFactory.getPersonDAO().addPersonToMedia(actor, Person.RoleType.ACTOR, mediaItemId);
                }

            }

            foreach (MetadataFile metadataFile ; metadata.getMetadataFiles()) {
                MetadataDescriptor metadataDescriptor = new MetadataDescriptor(metadataFile.getExtractorType(), mediaItemId, metadataFile.getLastUpdatedDate(), metadataFile.getIdentifier());

                DAOFactory.getMetadataDescriptorDAO().create(metadataDescriptor);
            }
        }
        else {
            log.warn("Video cannot be added to the library because no metadata has been provided");
        }
    }

    public static void removeVideoFromLibrary(Long mediaItemId)
    {
        Video video = getVideo(mediaItemId);
        if (video !is null) {
            log.debug_(String.format("Removing video from database: %s", cast(Object[])[ video.getTitle() ]));

            DAOFactory.getPersonDAO().removeAllPersonsFromMedia(mediaItemId);

            PlaylistService.removeMediaItemFromPlaylists(mediaItemId);

            DAOFactory.getMetadataDescriptorDAO().removeMetadataDescriptorsForMedia(mediaItemId);

            DAOFactory.getVideoDAO().delete_(video.getId());

            CoverImageService.removeCoverImage(video.getThumbnailId());

            removeSeries(video.getSeriesId());

            FolderService.removeFolderAndItsParents(video.getFolderId());

            GenreService.removeGenre(video.getGenreId());
        }
        else {
            log.warn("Video cannot be removed from the library because it cannot be found");
        }
    }

    public static void updateVideoInLibrary(VideoMetadata metadata, Long mediaItemId)
    {
        if (metadata !is null) {
            log.debug_(String.format("Updating video in database: %s", cast(Object[])[ metadata.getTitle() ]));

            Video video = getVideo(mediaItemId);

            Long genreId = GenreService.findOrCreateGenre(metadata.getGenre());

            Long seriesId = findOrCreateSeries(metadata.getSeriesName());

            Long coverImageId = CoverImageService.createCoverImage(metadata.getCoverImage(), null);

            Video updatedVideo = new Video(metadata.getTitle(), metadata.getContainer(), video.getFileName(), metadata.getFilePath(), Long.valueOf(metadata.getFileSize()), video.getFolderId(), video.getRepositoryId(), metadata.getDate());

            updatedVideo.setId(video.getId());
            updatedVideo.setDuration(metadata.getDuration());
            updatedVideo.setGenreId(genreId);
            updatedVideo.setThumbnailId(coverImageId);
            updatedVideo.setDescription(metadata.getDescription());
            updatedVideo.setBitrate(metadata.getBitrate());
            updatedVideo.setAudioBitrate(metadata.getAudioBitrate());
            updatedVideo.setWidth(metadata.getWidth());
            updatedVideo.setHeight(metadata.getHeight());
            updatedVideo.setRating(metadata.getRating());
            updatedVideo.setEpisodeNumber(metadata.getEpisodeNumber());
            updatedVideo.setSeasonNumber(metadata.getSeasonNumber());
            updatedVideo.setSeriesId(seriesId);
            updatedVideo.setAudioCodec(metadata.getAudioCodec());
            updatedVideo.setVideoCodec(metadata.getVideoCodec());
            updatedVideo.setAudioStreamIndex(metadata.getAudioStreamIndex());
            updatedVideo.setVideoStreamIndex(metadata.getVideoStreamIndex());
            updatedVideo.setChannels(metadata.getChannels());
            updatedVideo.setFps(metadata.getFps());
            updatedVideo.setFrequency(metadata.getFrequency());
            updatedVideo.setContentType(metadata.getContentType());
            updatedVideo.setTimestampType(metadata.getTimestampType());
            updatedVideo.setH264Profile(metadata.getH264Profile());
            updatedVideo.setH264Levels(metadata.getH264Levels());
            updatedVideo.setFtyp(metadata.getFtyp());
            updatedVideo.setSar(metadata.getSar());
            updatedVideo.setVideoFourCC(metadata.getVideoFourCC());
            updatedVideo.setOnlineIdentifiers(metadata.getOnlineIdentifiers());

            updatedVideo.setDirty(false);

            DAOFactory.getVideoDAO().update(updatedVideo);

            List!(Long) originalDirectorRoles = DAOFactory.getPersonDAO().getRoleIDsForMediaItem(Person.RoleType.DIRECTOR, mediaItemId);
            List!(Long) originalProducerRoles = DAOFactory.getPersonDAO().getRoleIDsForMediaItem(Person.RoleType.PRODUCER, mediaItemId);
            List!(Long) originalActorRoles = DAOFactory.getPersonDAO().getRoleIDsForMediaItem(Person.RoleType.ACTOR, mediaItemId);

            List!(Long) newDirectorRoles = new ArrayList!(Long)();
            List!(Long) newProducerRoles = new ArrayList!(Long)();
            List!(Long) newActorRoles = new ArrayList!(Long)();

            if (metadata.getDirectors() !is null) {
                foreach (String director ; metadata.getDirectors()) {
                    Long newRole = DAOFactory.getPersonDAO().addPersonToMedia(director, Person.RoleType.DIRECTOR, mediaItemId);
                    newDirectorRoles.add(newRole);
                }
            }
            if (metadata.getProducers() !is null) {
                foreach (String producer ; metadata.getProducers()) {
                    Long newRole = DAOFactory.getPersonDAO().addPersonToMedia(producer, Person.RoleType.PRODUCER, mediaItemId);
                    newProducerRoles.add(newRole);
                }
            }
            if (metadata.getActors() !is null) {
                foreach (String actor ; metadata.getActors()) {
                    Long newRole = DAOFactory.getPersonDAO().addPersonToMedia(actor, Person.RoleType.ACTOR, mediaItemId);
                    newActorRoles.add(newRole);
                }

            }

            DAOFactory.getMetadataDescriptorDAO().removeMetadataDescriptorsForMedia(mediaItemId);

            foreach (MetadataFile metadataFile ; metadata.getMetadataFiles()) {
                MetadataDescriptor metadataDescriptor = new MetadataDescriptor(metadataFile.getExtractorType(), mediaItemId, metadataFile.getLastUpdatedDate(), metadataFile.getIdentifier());

                DAOFactory.getMetadataDescriptorDAO().create(metadataDescriptor);
            }

            GenreService.removeGenre(video.getGenreId());
            CoverImageService.removeCoverImage(video.getThumbnailId());
            removeSeries(video.getSeriesId());

            originalDirectorRoles.removeAll(newDirectorRoles);
            originalProducerRoles.removeAll(newProducerRoles);
            originalActorRoles.removeAll(newActorRoles);
            DAOFactory.getPersonDAO().removePersonsAndRoles(originalDirectorRoles);
            DAOFactory.getPersonDAO().removePersonsAndRoles(originalProducerRoles);
            DAOFactory.getPersonDAO().removePersonsAndRoles(originalActorRoles);
        } else {
            log.warn("Video cannot be updated in the library because no metadata has been provided");
        }
    }

    public static Video getVideo(Long videoId)
    {
        if (videoId !is null) {
            return cast(Video)DAOFactory.getVideoDAO().read(videoId);
        }
        return null;
    }

    public static Series getSeries(Long seriesId)
    {
        if (seriesId !is null) {
            return cast(Series)DAOFactory.getSeriesDAO().read(seriesId);
        }
        return null;
    }

    public static List!(Video) getListOfVideosForFolder(Long folderId, AccessGroup accessGroup, int startingIndex, int requestedCount)
    {
        return DAOFactory.getVideoDAO().retrieveVideosForFolder(folderId, accessGroup, startingIndex, requestedCount);
    }

    public static int getNumberOfVideosForFolder(Long folderId, AccessGroup accessGroup)
    {
        return DAOFactory.getVideoDAO().retrieveVideosForFolderCount(folderId, accessGroup);
    }

    public static List!(Video) getListOfVideosForPlaylist(Long playlistId, AccessGroup accessGroup, int startingIndex, int requestedCount)
    {
        return DAOFactory.getVideoDAO().retrieveVideosForPlaylist(playlistId, accessGroup, startingIndex, requestedCount);
    }

    public static int getNumberOfVideosForPlaylist(Long playlistId, AccessGroup accessGroup)
    {
        return DAOFactory.getVideoDAO().retrieveVideosForPlaylistCount(playlistId, accessGroup);
    }

    public static List!(Video) getListOfVideosForGenre(Long genreId, AccessGroup accessGroup, int startingIndex, int requestedCount)
    {
        return DAOFactory.getVideoDAO().retrieveVideosForGenre(genreId, accessGroup, startingIndex, requestedCount);
    }

    public static int getNumberOfVideosForGenre(Long genreId, AccessGroup accessGroup)
    {
        return DAOFactory.getVideoDAO().retrieveVideosForGenreCount(genreId, accessGroup);
    }

    public static List!(Video) getListOfVideosForPerson(Long personId, Person.RoleType role, AccessGroup accessGroup, int startingIndex, int requestedCount)
    {
        return DAOFactory.getVideoDAO().retrieveVideosForPerson(personId, role, accessGroup, startingIndex, requestedCount);
    }

    public static int getNumberOfVideosForPerson(Long personId, Person.RoleType role, AccessGroup accessGroup)
    {
        return DAOFactory.getVideoDAO().retrieveVideosForPersonCount(personId, role, accessGroup);
    }

    public static List!(Series) getListOfSeries(int startingIndex, int requestedCount)
    {
        return DAOFactory.getSeriesDAO().retrieveSeries(startingIndex, requestedCount);
    }

    public static int getNumberOfSeries()
    {
        return DAOFactory.getSeriesDAO().getSeriesCount();
    }

    public static List!(Integer) getListOfSeasonsForSeries(Long seriesId, AccessGroup accessGroup, int startingIndex, int requestedCount)
    {
        return DAOFactory.getSeriesDAO().retrieveSeasonsForSeries(seriesId, accessGroup, startingIndex, requestedCount);
    }

    public static int getNumberOfSeasonsForSeries(Long seriesId, AccessGroup accessGroup)
    {
        return DAOFactory.getSeriesDAO().getSeasonsForSeriesCount(seriesId, accessGroup);
    }

    public static List!(Video) getListOfEpisodesForSeriesSeason(Long seriesId, Integer season, AccessGroup accessGroup, int startingIndex, int requestedCount)
    {
        return DAOFactory.getVideoDAO().retrieveVideosForSeriesSeason(seriesId, season, accessGroup, startingIndex, requestedCount);
    }

    public static int getNumberOfEpisodesForSeriesSeason(Long seriesId, Integer season, AccessGroup accessGroup)
    {
        return DAOFactory.getVideoDAO().retrieveVideosForSeriesSeasonCount(seriesId, season, accessGroup);
    }

    public static List!(String) getListOfVideoInitials(AccessGroup accessGroup, int startingIndex, int requestedCount)
    {
        return DAOFactory.getVideoDAO().retrieveVideoInitials(accessGroup, startingIndex, requestedCount);
    }

    public static int getNumberOfVideoInitials(AccessGroup accessGroup)
    {
        return DAOFactory.getVideoDAO().retrieveVideoInitialsCount(accessGroup);
    }

    public static List!(Video) getListOfVideosForInitial(String initial, AccessGroup accessGroup, int startingIndex, int requestedCount)
    {
        return DAOFactory.getVideoDAO().retrieveVideosForInitial(initial, accessGroup, startingIndex, requestedCount);
    }

    public static int getNumberOfVideosForInitial(String initial, AccessGroup accessGroup)
    {
        return DAOFactory.getVideoDAO().retrieveVideosForInitialCount(initial, accessGroup);
    }

    public static List!(Video) getListOfAllVideos(AccessGroup userProfile, int startingIndex, int requestedCount)
    {
        return DAOFactory.getVideoDAO().retrieveVideos(0, userProfile, startingIndex, requestedCount);
    }

    public static int getNumberOfAllVideos(AccessGroup userProfile)
    {
        return DAOFactory.getVideoDAO().retrieveVideosCount(0, userProfile);
    }

    public static List!(Video) getListOfMovieVideos(AccessGroup userProfile, int startingIndex, int requestedCount)
    {
        return DAOFactory.getVideoDAO().retrieveVideos(2, userProfile, startingIndex, requestedCount);
    }

    public static int getNumberOfMovieVideos(AccessGroup userProfile)
    {
        return DAOFactory.getVideoDAO().retrieveVideosCount(2, userProfile);
    }

    public static List!(Video) getListOfLastViewedVideos(int maxRequested, AccessGroup accessGroup, int startingIndex, int requestedCount)
    {
        return DAOFactory.getVideoDAO().retrieveLastViewedVideos(maxRequested, accessGroup, startingIndex, requestedCount);
    }

    public static int getNumberOfLastViewedVideos(int maxRequested, AccessGroup accessGroup)
    {
        return DAOFactory.getVideoDAO().retrieveLastViewedVideosCount(maxRequested, accessGroup);
    }

    public static List!(Video) getListOfLastAddedVideos(int maxRequested, AccessGroup accessGroup, int startingIndex, int requestedCount)
    {
        return DAOFactory.getVideoDAO().retrieveLastAddedVideos(maxRequested, accessGroup, startingIndex, requestedCount);
    }

    public static int getNumberOfLastAddedVideos(int maxRequested, AccessGroup userProfile)
    {
        return DAOFactory.getVideoDAO().retrieveLastAddedVideosCount(maxRequested, userProfile);
    }

    public static Map!(Long, Integer) getLastViewedEpisode(Long seriesId)
    {
        return DAOFactory.getVideoDAO().retrieveLastViewedEpisode(seriesId);
    }

    public static Long findOrCreateSeries(String seriesName)
    {
        if (ObjectValidator.isNotEmpty(seriesName)) {
            Series series = DAOFactory.getSeriesDAO().findSeriesByName(seriesName);
            if (series is null) {
                log.debug_(String.format("Series %s not found, creating a new one", cast(Object[])[ seriesName ]));

                series = new Series(seriesName, null);
                return Long.valueOf(DAOFactory.getSeriesDAO().create(series));
            }
            log.debug_(String.format("Series %s found", cast(Object[])[ seriesName ]));
            return series.getId();
        }

        return null;
    }

    private static void removeSeries(Long seriesId)
    {
        if (seriesId !is null) {
            int numberOfEpisodes = DAOFactory.getSeriesDAO().getNumberOfEpisodes(seriesId);
            if (numberOfEpisodes == 0)
            {
                DAOFactory.getSeriesDAO().delete_(seriesId);
            }
        }
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.local.service.VideoService
* JD-Core Version:    0.6.2
*/