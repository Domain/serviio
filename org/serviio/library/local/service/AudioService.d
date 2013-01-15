module org.serviio.library.local.service.AudioService;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import org.serviio.db.dao.DAOFactory;
import org.serviio.library.entities.AccessGroup;
import org.serviio.library.entities.MetadataDescriptor;
import org.serviio.library.entities.MusicAlbum;
import org.serviio.library.entities.MusicTrack;
import org.serviio.library.entities.Person : RoleType;
import org.serviio.library.entities.Repository;
import org.serviio.library.local.metadata.AudioMetadata;
import org.serviio.library.local.metadata.extractor.MetadataFile;
import org.serviio.library.service.Service;
import org.serviio.util.ObjectValidator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AudioService
  : Service
{
  private static final Logger log = LoggerFactory.getLogger!(AudioService)();

  public static void addMusicTrackToLibrary(AudioMetadata metadata, Repository repository)
  {
    Long mediaItemId;
    if (metadata !is null) {
      log.debug_(String.format("Adding music track into database: %s", cast(Object[])[ metadata.getTitle() ]));

      Long albumId = findOrCreateAlbum(metadata);

      Long folderId = FolderService.createOrReadFolder(repository, metadata.getFilePath());

      Long genreId = GenreService.findOrCreateGenre(metadata.getGenre());

      Long coverImageId = CoverImageService.createCoverImage(metadata.getCoverImage(), null);

      MusicTrack track = new MusicTrack(metadata.getTitle(), metadata.getContainer(), (new File(metadata.getFilePath())).getName(), metadata.getFilePath(), Long.valueOf(metadata.getFileSize()), folderId, repository.getId(), metadata.getDate());

      track.setAlbumId(albumId);
      track.setDuration(metadata.getDuration());
      track.setGenreId(genreId);
      track.setThumbnailId(coverImageId);
      track.setTrackNumber(metadata.getTrackNumber());
      track.setReleaseYear(metadata.getReleaseYear());
      track.setDescription(metadata.getDescription());
      track.setBitrate(metadata.getBitrate());
      track.setChannels(metadata.getChannels());
      track.setSampleFrequency(metadata.getSampleFrequency());

      mediaItemId = Long.valueOf(DAOFactory.getMusicTrackDAO().create(track));

      if (ObjectValidator.isNotEmpty(metadata.getArtist())) {
        DAOFactory.getPersonDAO().addPersonToMedia(metadata.getArtist(), RoleType.ARTIST, mediaItemId);
      }
      if (ObjectValidator.isNotEmpty(metadata.getAuthor())) {
        DAOFactory.getPersonDAO().addPersonToMedia(metadata.getAuthor(), RoleType.COMPOSER, mediaItemId);
      }

      foreach (MetadataFile metadataFile ; metadata.getMetadataFiles()) {
        MetadataDescriptor metadataDescriptor = new MetadataDescriptor(metadataFile.getExtractorType(), mediaItemId, metadataFile.getLastUpdatedDate(), metadataFile.getIdentifier());

        DAOFactory.getMetadataDescriptorDAO().create(metadataDescriptor);
      }
    }
    else {
      log.warn("Music track cannot be added to the library because no metadata has been provided");
    }
  }

  public static void removeMusicTrackFromLibrary(Long mediaItemId)
  {
    MusicTrack track = getSong(mediaItemId);
    if (track !is null) {
      log.debug_(String.format("Removing music track from database: %s", cast(Object[])[ track.getTitle() ]));

      DAOFactory.getPersonDAO().removeAllPersonsFromMedia(mediaItemId);

      PlaylistService.removeMediaItemFromPlaylists(mediaItemId);

      DAOFactory.getMetadataDescriptorDAO().removeMetadataDescriptorsForMedia(mediaItemId);

      DAOFactory.getMusicTrackDAO().delete_(track.getId());

      CoverImageService.removeCoverImage(track.getThumbnailId());

      removeAlbum(track);

      FolderService.removeFolderAndItsParents(track.getFolderId());

      GenreService.removeGenre(track.getGenreId());
    }
    else {
      log.warn("Music track cannot be removed from the library because it cannot be found");
    }
  }

  public static void updateMusicTrackInLibrary(AudioMetadata metadata, Long mediaItemId)
  {
    if (metadata !is null) {
      log.debug_(String.format("Updating music track in database: %s", cast(Object[])[ metadata.getTitle() ]));

      MusicTrack track = getSong(mediaItemId);

      Long albumId = findOrCreateAlbum(metadata);

      Long genreId = GenreService.findOrCreateGenre(metadata.getGenre());

      Long coverImageId = CoverImageService.createCoverImage(metadata.getCoverImage(), null);

      MusicTrack updatedTrack = new MusicTrack(metadata.getTitle(), metadata.getContainer(), track.getFileName(), metadata.getFilePath(), Long.valueOf(metadata.getFileSize()), track.getFolderId(), track.getRepositoryId(), metadata.getDate());

      updatedTrack.setId(track.getId());
      updatedTrack.setAlbumId(albumId);
      updatedTrack.setDuration(metadata.getDuration());
      updatedTrack.setGenreId(genreId);
      updatedTrack.setThumbnailId(coverImageId);
      updatedTrack.setTrackNumber(metadata.getTrackNumber());
      updatedTrack.setReleaseYear(metadata.getReleaseYear());
      updatedTrack.setDescription(metadata.getDescription());
      updatedTrack.setBitrate(metadata.getBitrate());
      updatedTrack.setChannels(metadata.getChannels());
      updatedTrack.setSampleFrequency(metadata.getSampleFrequency());

      updatedTrack.setDirty(false);

      DAOFactory.getMusicTrackDAO().update(updatedTrack);

      List!(Long) originalArtistRoles = DAOFactory.getPersonDAO().getRoleIDsForMediaItem(RoleType.ARTIST, mediaItemId);
      List!(Long) originalComposerRoles = DAOFactory.getPersonDAO().getRoleIDsForMediaItem(RoleType.COMPOSER, mediaItemId);

      List!(Long) newArtistRoles = new ArrayList!(Long)();
      List!(Long) newComposerRoles = new ArrayList!(Long)();
      if (ObjectValidator.isNotEmpty(metadata.getArtist())) {
        Long artistRoleId = DAOFactory.getPersonDAO().addPersonToMedia(metadata.getArtist(), RoleType.ARTIST, mediaItemId);
        newArtistRoles.add(artistRoleId);
      }
      if (ObjectValidator.isNotEmpty(metadata.getAuthor())) {
        Long composerRoleId = DAOFactory.getPersonDAO().addPersonToMedia(metadata.getAuthor(), RoleType.COMPOSER, mediaItemId);
        newComposerRoles.add(composerRoleId);
      }

      DAOFactory.getMetadataDescriptorDAO().removeMetadataDescriptorsForMedia(mediaItemId);

      foreach (MetadataFile metadataFile ; metadata.getMetadataFiles()) {
        MetadataDescriptor metadataDescriptor = new MetadataDescriptor(metadataFile.getExtractorType(), mediaItemId, metadataFile.getLastUpdatedDate(), metadataFile.getIdentifier());

        DAOFactory.getMetadataDescriptorDAO().create(metadataDescriptor);
      }

      removeAlbum(track);
      GenreService.removeGenre(track.getGenreId());
      CoverImageService.removeCoverImage(track.getThumbnailId());

      originalArtistRoles.removeAll(newArtistRoles);
      DAOFactory.getPersonDAO().removePersonsAndRoles(originalArtistRoles);
      originalComposerRoles.removeAll(newComposerRoles);
      DAOFactory.getPersonDAO().removePersonsAndRoles(originalComposerRoles);
    } else {
      log.warn("Music track cannot be updated in the library because no metadata has been provided");
    }
  }

  public static List!(MusicTrack) getListOfSongsForArtist(Long artistId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    return DAOFactory.getMusicTrackDAO().retrieveMusicTracksForArtist(artistId, accessGroup, startingIndex, requestedCount);
  }

  public static int getNumberOfSongsForArtist(Long artistId, AccessGroup accessGroup)
  {
    return DAOFactory.getMusicTrackDAO().retrieveMusicTracksForArtistCount(artistId, accessGroup);
  }

  public static List!(MusicTrack) getListOfSongsForGenre(Long genreId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    return DAOFactory.getMusicTrackDAO().retrieveMusicTracksForGenre(genreId, accessGroup, startingIndex, requestedCount);
  }

  public static int getNumberOfSongsForGenre(Long genreId, AccessGroup accessGroup)
  {
    return DAOFactory.getMusicTrackDAO().retrieveMusicTracksForGenreCount(genreId, accessGroup);
  }

  public static List!(MusicTrack) getListOfSongsForPlaylist(Long playlistId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    return DAOFactory.getMusicTrackDAO().retrieveMusicTracksForPlaylist(playlistId, accessGroup, startingIndex, requestedCount);
  }

  public static int getNumberOfSongsForPlaylist(Long playlistId, AccessGroup accessGroup)
  {
    return DAOFactory.getMusicTrackDAO().retrieveMusicTracksForPlaylistCount(playlistId, accessGroup);
  }

  public static List!(String) getListOfSongInitials(AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    return DAOFactory.getMusicTrackDAO().retrieveMusicTracksInitials(accessGroup, startingIndex, requestedCount);
  }

  public static int getNumberOfSongInitials(AccessGroup accessGroup)
  {
    return DAOFactory.getMusicTrackDAO().retrieveMusicTracksInitialsCount(accessGroup);
  }

  public static List!(MusicTrack) getListOfSongsForInitial(String initial, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    return DAOFactory.getMusicTrackDAO().retrieveMusicTracksForInitial(initial, accessGroup, startingIndex, requestedCount);
  }

  public static int getNumberOfSongsForInitial(String initial, AccessGroup accessGroup)
  {
    return DAOFactory.getMusicTrackDAO().retrieveMusicTracksForInitialCount(initial, accessGroup);
  }

  public static List!(MusicTrack) getListOfSongsForFolder(Long folderId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    return DAOFactory.getMusicTrackDAO().retrieveMusicTracksForFolder(folderId, accessGroup, startingIndex, requestedCount);
  }

  public static int getNumberOfSongsForFolder(Long folderId, AccessGroup accessGroup)
  {
    return DAOFactory.getMusicTrackDAO().retrieveMusicTracksForFolderCount(folderId, accessGroup);
  }

  public static List!(MusicTrack) getListOfAllSongs(AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    return DAOFactory.getMusicTrackDAO().retrieveAllMusicTracks(accessGroup, startingIndex, requestedCount);
  }

  public static int getNumberOfAllSongs(AccessGroup accessGroup)
  {
    return DAOFactory.getMusicTrackDAO().retrieveAllMusicTracksCount(accessGroup);
  }

  public static List!(MusicTrack) getListOfRandomSongs(AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    return DAOFactory.getMusicTrackDAO().retrieveRandomMusicTracks(startingIndex, requestedCount, accessGroup);
  }

  public static int getNumberOfRandomSongs(int max, AccessGroup accessGroup)
  {
    return DAOFactory.getMusicTrackDAO().retrieveRandomMusicTracksCount(max, accessGroup);
  }

  public static MusicTrack getSong(Long musicTrackId)
  {
    if (musicTrackId !is null) {
      return cast(MusicTrack)DAOFactory.getMusicTrackDAO().read(musicTrackId);
    }
    return null;
  }

  public static List!(MusicAlbum) getListOfAlbumsForTrackRole(Long artistId, RoleType role, int startingIndex, int requestedCount)
  {
    return DAOFactory.getMusicAlbumDAO().retrieveMusicAlbumsForTrackRole(artistId, role, startingIndex, requestedCount);
  }

  public static int getNumberOfAlbumsForTrackRole(Long artistId, RoleType role)
  {
    return DAOFactory.getMusicAlbumDAO().retrieveMusicAlbumsForTrackRoleCount(artistId, role);
  }

  public static List!(MusicAlbum) getListOfAlbumsForAlbumArtist(Long artistId, int startingIndex, int requestedCount)
  {
    return DAOFactory.getMusicAlbumDAO().retrieveMusicAlbumsForAlbumArtist(artistId, startingIndex, requestedCount);
  }

  public static int getNumberOfAlbumsForAlbumArtist(Long artistId)
  {
    return DAOFactory.getMusicAlbumDAO().retrieveMusicAlbumsForAlbumArtistCount(artistId);
  }

  public static List!(MusicTrack) getListOfSongsForTrackRoleAndAlbum(Long artistId, RoleType role, Long albumId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    return DAOFactory.getMusicTrackDAO().retrieveMusicTracksForTrackRoleAndAlbum(artistId, role, albumId, accessGroup, startingIndex, requestedCount);
  }

  public static int getNumberOfSongsForTrackRoleAndAlbum(Long artistId, RoleType role, Long albumId, AccessGroup accessGroup)
  {
    return DAOFactory.getMusicTrackDAO().retrieveMusicTracksForTrackRoleAndAlbumCount(artistId, role, albumId, accessGroup);
  }

  public static List!(MusicTrack) getListOfSongsForAlbum(Long albumId, AccessGroup accessGroup, int startingIndex, int requestedCount)
  {
    return DAOFactory.getMusicTrackDAO().retrieveMusicTracksForAlbum(albumId, accessGroup, startingIndex, requestedCount);
  }

  public static int getNumberOfSongsForAlbum(Long albumId, AccessGroup accessGroup)
  {
    return DAOFactory.getMusicTrackDAO().retrieveMusicTracksForAlbumCount(albumId, accessGroup);
  }

  public static List!(MusicAlbum) getListOfAllAlbums(int startingIndex, int requestedCount)
  {
    return DAOFactory.getMusicAlbumDAO().retrieveAllMusicAlbums(startingIndex, requestedCount);
  }

  public static int getNumberOfAllAlbums()
  {
    return DAOFactory.getMusicAlbumDAO().retrieveAllMusicAlbumsCount();
  }

  public static MusicAlbum getMusicAlbum(Long albumId)
  {
    if (albumId !is null) {
      return cast(MusicAlbum)DAOFactory.getMusicAlbumDAO().read(albumId);
    }
    return null;
  }

  private static void removeAlbum(MusicTrack track)
  {
    if (track.getAlbumId() !is null) {
      int numberOfTracks = DAOFactory.getMusicAlbumDAO().getNumberOfTracks(track.getAlbumId());
      if (numberOfTracks == 0)
      {
        DAOFactory.getPersonDAO().removeAllPersonsFromMusicAlbum(track.getAlbumId());
        DAOFactory.getMusicAlbumDAO().delete_(track.getAlbumId());
      }
    }
  }

  private static Long findOrCreateAlbum(AudioMetadata metadata)
  {
    if (ObjectValidator.isNotEmpty(metadata.getAlbum()))
    {
      String albumArtist = metadata.getAlbumArtist();

      MusicAlbum album = DAOFactory.getMusicAlbumDAO().findAlbum(metadata.getAlbum(), albumArtist);

      if (album is null) {
        log.debug_(String.format("Album %s (%s) not found, creating a new one", cast(Object[])[ metadata.getAlbum(), albumArtist ]));

        album = new MusicAlbum(metadata.getAlbum());
        Long albumId = Long.valueOf(DAOFactory.getMusicAlbumDAO().create(album));

        DAOFactory.getPersonDAO().addPersonToMusicAlbum(metadata.getAlbumArtist(), RoleType.ALBUM_ARTIST, albumId);
        return albumId;
      }
      log.debug_(String.format("Album %s found, attaching the music track to it", cast(Object[])[ album.getTitle() ]));
      return album.getId();
    }

    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.service.AudioService
 * JD-Core Version:    0.6.2
 */