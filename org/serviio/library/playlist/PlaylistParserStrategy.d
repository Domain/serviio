module org.serviio.library.playlist.PlaylistParserStrategy;

public abstract interface PlaylistParserStrategy
{
  public abstract ParsedPlaylist parsePlaylist(byte[] paramArrayOfByte, String paramString);

  public abstract bool matches(byte[] paramArrayOfByte, String paramString);
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.playlist.PlaylistParserStrategy
 * JD-Core Version:    0.6.2
 */