module org.serviio.library.playlist.PlaylistType;

import java.lang.String;

public class PlaylistType
{
    enum PlaylistTypeEnum
    {
        ASX, 
        M3U, 
        PLS,
        WPL,
    }

    PlaylistTypeEnum playlistType;
    alias playlistType this;

    public String[] supportedFileExtensions()
    {
        switch (playlistType)
        {
            case ASX:
                return cast(String[])[ "asx", "wax", "wvx" ]; 

            case M3U:
                return cast(String[])[ "m3u", "m3u8" ]; 

            case PLS:
                return cast(String[])[ "pls" ]; 

            case WPL:
                return cast(String[])[ "wpl" ];
        }
        return null;
    }

    public static bool playlistTypeExtensionSupported(String extension)
    {
        foreach (PlaylistType playlistType ; values()) {
            foreach (String supportedExtension ; playlistType.supportedFileExtensions()) {
                if (extension.equalsIgnoreCase(supportedExtension)) {
                    return true;
                }
            }
        }
        return false;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.playlist.PlaylistType
* JD-Core Version:    0.6.2
*/