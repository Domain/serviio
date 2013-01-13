module org.serviio.library.playlist.CannotParsePlaylistException;

public class CannotParsePlaylistException : Exception
{
  private static final long serialVersionUID = 6421703004477221786L;
  private PlaylistType type;
  private String playlistLocation;

  public this(PlaylistType type, String playlistLocation, String message)
  {
    super(message);
    this.type = type;
    this.playlistLocation = playlistLocation;
  }

  public String getMessage()
  {
    return String.format("Cannot parse playlist (%s) '%s' because: %s", cast(Object[])[ type.toString(), playlistLocation, super.getMessage() ]);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.playlist.CannotParsePlaylistException
 * JD-Core Version:    0.6.2
 */