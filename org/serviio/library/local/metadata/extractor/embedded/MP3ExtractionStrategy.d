module org.serviio.library.local.metadata.extractor.embedded.MP3ExtractionStrategy;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import org.jaudiotagger.audio.AudioFile;
import org.jaudiotagger.audio.AudioHeader;
import org.jaudiotagger.audio.mp3.MP3File;
import org.jaudiotagger.tag.FieldKey;
import org.jaudiotagger.tag.Tag;
import org.jaudiotagger.tag.id3.AbstractID3v2Tag;
import org.jaudiotagger.tag.id3.ID3v1Tag;
import org.jaudiotagger.tag.reference.GenreTypes;
import org.serviio.dlna.AudioContainer;
import org.serviio.library.local.metadata.AudioMetadata;
import org.serviio.library.local.metadata.extractor.InvalidMediaFormatException;
import org.serviio.util.CollectionUtils;
import org.serviio.util.NumberUtils;
import org.serviio.util.ObjectValidator;

public class MP3ExtractionStrategy : AudioExtractionStrategy
{
  public void extractMetadata(AudioMetadata metadata, AudioFile audioFile, AudioHeader header, Tag tag)
  {
    MP3File mp3File = cast(MP3File)audioFile;

    if (mp3File.hasID3v1Tag()) {
      ID3v1Tag v1tag = mp3File.getID3v1Tag();
      super.extractMetadata(metadata, audioFile, header, v1tag);
    } else {
      super.extractMetadata(metadata, audioFile, header, null);
    }

    if (mp3File.hasID3v2Tag()) {
      AbstractID3v2Tag v24tag = mp3File.getID3v2TagAsv24();
      if (ObjectValidator.isNotEmpty(tag.getFirst(FieldKey.GENRE))) {
        metadata.setGenre(getGenreString(tag.getFirst(FieldKey.GENRE)));
      }
      if ((ObjectValidator.isEmpty(metadata.getGenre())) && (ObjectValidator.isNotEmpty(tag.getFirst("TCON")))) {
        metadata.setGenre(getGenreString(tag.getFirst("TCON")));
      }
      if (ObjectValidator.isNotEmpty(v24tag.getFirst("TALB"))) {
        metadata.setAlbum(v24tag.getFirst("TALB"));
      }
      if (ObjectValidator.isNotEmpty(v24tag.getFirst("TPE2"))) {
        metadata.setAlbumArtist(v24tag.getFirst("TPE2"));
      }
      if (ObjectValidator.isNotEmpty(v24tag.getFirst("TPE1"))) {
        metadata.setArtist(v24tag.getFirst("TPE1"));
      }
      if (ObjectValidator.isNotEmpty(v24tag.getFirst("TIT2"))) {
        metadata.setTitle(v24tag.getFirst("TIT2"));
      }
      if (ObjectValidator.isNotEmpty(v24tag.getFirst("TRCK"))) {
        metadata.setTrackNumber(fixTrackNumber(v24tag.getFirst("TRCK")));
      }
      if (metadata.getCoverImage() is null)
        metadata.setCoverImage(findAlbumArt(v24tag));
    }
  }

  protected AudioContainer getContainer()
  {
    return AudioContainer.MP3;
  }

  protected String getGenreString(String genreDefinition)
  {
    List!(String) resultGenre = new ArrayList!(String)();
    String workingGenreDef = "";

    if (genreDefinition.indexOf(0) > -1) {
      String[] tokens = genreDefinition.split("\\x00");
      foreach (String token ; tokens)
        if (NumberUtils.isNumber(token))
        {
          workingGenreDef = String.format("%s(%s)", cast(Object[])[ workingGenreDef, token.trim() ]);
        }
        else workingGenreDef = String.format("%s%s", cast(Object[])[ workingGenreDef, token.trim() ]);
    }
    else
    {
      workingGenreDef = genreDefinition.replaceAll("\\(\\(", "(");
    }
    int startPos = workingGenreDef.indexOf("(");
    int endPos = -1;
    if (startPos > -1) {
      while (startPos > -1) {
        if (endPos + 1 < startPos) {
          resultGenre.add(workingGenreDef.substring(endPos + 1, startPos));
        }
        endPos = workingGenreDef.indexOf(")", startPos);
        String betweenBrackets = workingGenreDef.substring(startPos + 1, endPos);
        try {
          Integer genreNumber = new Integer(betweenBrackets);
          String genreName = GenreTypes.getInstanceOf().getValueForId(genreNumber.intValue());
          if (ObjectValidator.isNotEmpty(genreName))
            resultGenre.add(genreName);
        }
        catch (NumberFormatException e)
        {
          String nonNumericReference = "";
          if (betweenBrackets.equals("RX"))
            nonNumericReference = "Remix";
          else if (betweenBrackets.equals("CR"))
            nonNumericReference = "Cover";
          else {
            nonNumericReference = "(" + betweenBrackets + ")";
          }
          resultGenre.add(nonNumericReference);
        }
        startPos = workingGenreDef.indexOf("(", startPos + 1);
      }

      if (endPos + 1 < workingGenreDef.length())
        resultGenre.add(workingGenreDef.substring(endPos + 1));
    }
    else
    {
      resultGenre.add(genreDefinition);
    }
    return CollectionUtils.listToCSV(resultGenre, " ", true);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.MP3ExtractionStrategy
 * JD-Core Version:    0.6.2
 */