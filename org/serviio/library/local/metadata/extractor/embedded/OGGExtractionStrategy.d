module org.serviio.library.local.metadata.extractor.embedded.OGGExtractionStrategy;

import java.io.IOException;
import org.apache.sanselan.ImageFormat;
import org.jaudiotagger.audio.AudioFile;
import org.jaudiotagger.audio.AudioHeader;
import org.jaudiotagger.tag.Tag;
import org.jaudiotagger.tag.vorbiscomment.VorbisCommentFieldKey;
import org.jaudiotagger.tag.vorbiscomment.VorbisCommentTag;
import org.jaudiotagger.tag.vorbiscomment.util.Base64Coder;
import org.serviio.dlna.AudioContainer;
import org.serviio.library.local.metadata.AudioMetadata;
import org.serviio.library.local.metadata.ImageDescriptor;
import org.serviio.library.local.metadata.extractor.InvalidMediaFormatException;
import org.serviio.util.ObjectValidator;

public class OGGExtractionStrategy : AudioExtractionStrategy
{
  public void extractMetadata(AudioMetadata metadata, AudioFile f, AudioHeader header, Tag tag)
  {
    super.extractMetadata(metadata, f, header, tag);

    if (metadata.getCoverImage() is null) {
      VorbisCommentTag ovtag = cast(VorbisCommentTag)f.getTag();
      byte[] imageBytes = null;
      String mimetype = null;
      String imageData = ovtag.getFirst(VorbisCommentFieldKey.METADATA_BLOCK_PICTURE);
      if (ObjectValidator.isEmpty(imageData)) {
        imageData = ovtag.getFirst(VorbisCommentFieldKey.COVERART);
        mimetype = ovtag.getFirst(VorbisCommentFieldKey.COVERARTMIME);
        if (ObjectValidator.isNotEmpty(imageData))
          imageBytes = Base64Coder.decode(imageData.toCharArray());
      }
      else {
        ImageDescriptor imageDesc = getImageDescriptorFromMetadataField(imageData);
        if (imageDesc !is null) {
          imageBytes = imageDesc.getImageData();
          mimetype = imageDesc.getMimeType();
        }
      }
      if (imageBytes !is null) {
        ImageFormat imageFormat = getImageFormat(imageBytes);
        if (isSupportedImageFormat(imageFormat)) {
          if (ObjectValidator.isEmpty(mimetype)) {
            mimetype = getMimeType(imageFormat);
          }

          ImageDescriptor imageDesc = new ImageDescriptor(imageBytes, mimetype);
          metadata.setCoverImage(imageDesc);
        }
      }
    }
  }

  private ImageDescriptor getImageDescriptorFromMetadataField(String imageData)
  {
    byte[] imageStructure = Base64Coder.decode(imageData.toCharArray());
    int offset = 4;
    byte[] result = new byte[4];
    System.arraycopy(imageStructure, offset, result, 0, 4);
    int mimeTypeLength = unsignedIntToLong(result);
    offset += 4;
    byte[] mimeTypeBytes = new byte[mimeTypeLength];
    System.arraycopy(imageStructure, offset, mimeTypeBytes, 0, mimeTypeLength);
    String mimetype = new String(mimeTypeBytes);
    if (mimetype.equals("-->")) {
      return null;
    }
    offset += mimeTypeLength;
    System.arraycopy(imageStructure, offset, result, 0, 4);
    int descLength = unsignedIntToLong(result);
    offset = offset + 4 + descLength;
    offset = offset + 4 + 4 + 4 + 4;
    System.arraycopy(imageStructure, offset, result, 0, 4);
    int imageBytesLength = unsignedIntToLong(result);
    offset += 4;
    byte[] imageBytes = new byte[imageBytesLength];
    System.arraycopy(imageStructure, offset, imageBytes, 0, imageBytesLength);
    return new ImageDescriptor(imageBytes, mimetype);
  }

  private int unsignedIntToLong(byte[] b)
  {
    long l = 0L;
    l |= b[0] & 0xFF;
    l <<= 8;
    l |= b[1] & 0xFF;
    l <<= 8;
    l |= b[2] & 0xFF;
    l <<= 8;
    l |= b[3] & 0xFF;
    return Integer.parseInt(Long.toString(l));
  }

  protected AudioContainer getContainer()
  {
    return AudioContainer.OGG;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.local.metadata.extractor.embedded.OGGExtractionStrategy
 * JD-Core Version:    0.6.2
 */