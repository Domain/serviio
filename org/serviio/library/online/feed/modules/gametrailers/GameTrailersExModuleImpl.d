module org.serviio.library.online.feed.modules.gametrailers.GameTrailersExModuleImpl;

import com.sun.syndication.feed.modules.ModuleImpl;

public class GameTrailersExModuleImpl : ModuleImpl
  , GameTrailersExModule
{
  private static final long serialVersionUID = -9195315748559355960L;
  private Long fileSize;
  private String thumbnailUrl;

  public this()
  {
    super(GameTrailersExModule.class_, "http://www.gametrailers.com/rssexplained.php");
  }

  public void copyFrom(Object obj)
  {
    GameTrailersExModule mod = cast(GameTrailersExModule)obj;
    setFileSize(mod.getFileSize());
    setThumbnailUrl(mod.getThumbnailUrl());
  }

  public Class!(Object) getInterface()
  {
    return GameTrailersExModule.class_;
  }

  public Long getFileSize()
  {
    return fileSize;
  }

  public void setFileSize(Long fileSize)
  {
    this.fileSize = fileSize;
  }

  public String getThumbnailUrl()
  {
    return thumbnailUrl;
  }

  public void setThumbnailUrl(String thumbnailUrl)
  {
    this.thumbnailUrl = thumbnailUrl;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.library.online.feed.modules.gametrailers.GameTrailersExModuleImpl
 * JD-Core Version:    0.6.2
 */