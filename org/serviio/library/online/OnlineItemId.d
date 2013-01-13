module org.serviio.library.online.OnlineItemId;

import org.serviio.util.NumberUtils;

public class OnlineItemId
{
  private static final Long FEED_ITEM_ID_PREFIX = new Long(100000L);
  private long repositoryId;
  private int sequence;
  private int salt;

  public this(long repoId, int sequence)
  {
    repositoryId = repoId;
    this.sequence = sequence;
    salt = NumberUtils.getRandomInInterval(100, 999);
  }

  public long value() {
    return Long.parseLong(String.format("%s%03d%04d%03d", cast(Object[])[ FEED_ITEM_ID_PREFIX, Long.valueOf(repositoryId), Integer.valueOf(sequence), Integer.valueOf(salt) ]));
  }

  public static bool isOnlineItemId(Long id) {
    bool isLocalMedia = id.longValue() > FEED_ITEM_ID_PREFIX.longValue() * 10000000000L;
    return isLocalMedia;
  }

  public static OnlineItemId parse(Long itemId) {
    String idString = itemId.toString();
    int startIndex = FEED_ITEM_ID_PREFIX.toString().length();
    Long repositoryId = Long.valueOf(Long.parseLong(idString.substring(startIndex, startIndex + 3)));
    Integer onlineItemOrder = Integer.valueOf(Integer.parseInt(idString.substring(startIndex + 3, startIndex + 7)));
    return new OnlineItemId(repositoryId.longValue(), onlineItemOrder.intValue());
  }

  public long getRepositoryId() {
    return repositoryId;
  }

  public int getSequence() {
    return sequence;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.OnlineItemId
 * JD-Core Version:    0.6.2
 */