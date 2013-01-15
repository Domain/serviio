module org.serviio.delivery.resource.AudioDeliveryEngine;

import java.lang.Integer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map : Entry;
import org.serviio.delivery.AudioMediaInfo;
import org.serviio.delivery.resource.transcode.AbstractTranscodingDeliveryEngine;
import org.serviio.delivery.resource.transcode.AudioTranscodingDefinition;
import org.serviio.delivery.resource.transcode.AudioTranscodingMatch;
import org.serviio.delivery.resource.transcode.TranscodingDefinition;
import org.serviio.dlna.AudioContainer;
import org.serviio.dlna.MediaFormatProfile;
import org.serviio.dlna.MediaFormatProfileResolver;
import org.serviio.dlna.UnsupportedDLNAMediaFileFormatException;
import org.serviio.external.FFMPEGWrapper;
import org.serviio.library.entities.MusicTrack;
import org.serviio.profile.DeliveryQuality;
import org.serviio.profile.Profile;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AudioDeliveryEngine : AbstractTranscodingDeliveryEngine!(AudioMediaInfo, MusicTrack)
{
  private static AudioDeliveryEngine instance;
  private static immutable Logger log = LoggerFactory.getLogger!(AudioDeliveryEngine)();

  public static AudioDeliveryEngine getInstance()
  {
    if (instance is null) {
      instance = new AudioDeliveryEngine();
    }
    return instance;
  }

  protected LinkedHashMap!(DeliveryQuality.QualityType, List!(AudioMediaInfo)) retrieveOriginalMediaInfo(MusicTrack mediaItem, Profile rendererProfile)
  {
    List!(MediaFormatProfile) fileProfiles = MediaFormatProfileResolver.resolve(mediaItem);
    LinkedHashMap!(DeliveryQuality.QualityType, List!(AudioMediaInfo)) result = new LinkedHashMap!(DeliveryQuality.QualityType, List!(AudioMediaInfo))();
    List!(AudioMediaInfo) mediaInfos = new ArrayList!(AudioMediaInfo)();

    foreach (MediaFormatProfile fileProfile ; fileProfiles) {
      mediaInfos.add(new AudioMediaInfo(mediaItem.getId(), fileProfile, mediaItem.getFileSize(), false, mediaItem.isLive(), mediaItem.getDuration(), rendererProfile.getMimeType(fileProfile), mediaItem.getChannels(), mediaItem.getSampleFrequency(), mediaItem.getBitrate(), DeliveryQuality.QualityType.ORIGINAL));
    }

    result.put(DeliveryQuality.QualityType.ORIGINAL, mediaInfos);
    return result;
  }

  protected LinkedHashMap!(DeliveryQuality.QualityType, List!(AudioMediaInfo)) retrieveTranscodedMediaInfo(MusicTrack mediaItem, Profile rendererProfile, Long fileSize)
  {
    LinkedHashMap!(DeliveryQuality.QualityType, List!(AudioMediaInfo)) transcodedMI = new LinkedHashMap!(DeliveryQuality.QualityType, List!(AudioMediaInfo))();
    Map!(DeliveryQuality.QualityType, TranscodingDefinition) trDefs = getMatchingTranscodingDefinitions(mediaItem, rendererProfile);
    if (trDefs.size() > 0) {
      foreach (Entry!(DeliveryQuality.QualityType, TranscodingDefinition) trDefEntry ; trDefs.entrySet()) {
        DeliveryQuality.QualityType qualityType = cast(DeliveryQuality.QualityType)trDefEntry.getKey();
        AudioTranscodingDefinition trDef = cast(AudioTranscodingDefinition)trDefEntry.getValue();

        Integer targetSamplerate = FFMPEGWrapper.getAudioFrequency(trDef, mediaItem.getSampleFrequency(), trDef.getTargetContainer() == AudioContainer.LPCM);
        Integer targetBitrate = FFMPEGWrapper.getAudioBitrate(mediaItem.getBitrate(), trDef);
        Integer targetChannels = FFMPEGWrapper.getAudioChannelNumber(mediaItem.getChannels(), null, true, false);
        try
        {
          MediaFormatProfile transcodedProfile = MediaFormatProfileResolver.resolveAudioFormat(mediaItem.getFileName(), trDef.getTargetContainer(), targetBitrate, targetSamplerate, targetChannels);

          log.debug_(String.format("Found Format profile for transcoded file %s: %s", cast(Object[])[ mediaItem.getFileName(), transcodedProfile ]));

          transcodedMI.put(qualityType, Collections.singletonList(new AudioMediaInfo(mediaItem.getId(), transcodedProfile, fileSize, true, mediaItem.isLive(), mediaItem.getDuration(), rendererProfile.getMimeType(transcodedProfile), targetChannels, targetSamplerate, targetBitrate, qualityType)));
        }
        catch (UnsupportedDLNAMediaFileFormatException e) {
          log.warn(String.format("Cannot get media info for transcoded file %s: %s", cast(Object[])[ mediaItem.getFileName(), e.getMessage() ]));
        }
      }
      return transcodedMI;
    }
    log.warn(String.format("Cannot find matching transcoding definition for file %s", cast(Object[])[ mediaItem.getFileName() ]));
    return new LinkedHashMap!(DeliveryQuality.QualityType, List!(AudioMediaInfo))();
  }

  protected TranscodingDefinition getMatchingTranscodingDefinition(List!(TranscodingDefinition) tDefs, MusicTrack mediaItem)
  {
    Iterator!(TranscodingDefinition) i;
    if ((tDefs !is null) && (tDefs.size() > 0))
      for (i = tDefs.iterator(); i.hasNext(); ) { TranscodingDefinition tDef = cast(TranscodingDefinition)i.next();
        List!(AudioTranscodingMatch) matches = (cast(AudioTranscodingDefinition)tDef).getMatches();
        foreach (AudioTranscodingMatch match ; matches)
          if (match.matches(mediaItem.getContainer(), getOnlineContentType(mediaItem)))
            return cast(AudioTranscodingDefinition)tDef;
      }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.delivery.resource.AudioDeliveryEngine
 * JD-Core Version:    0.6.2
 */