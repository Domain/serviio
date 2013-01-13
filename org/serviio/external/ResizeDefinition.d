module org.serviio.external.ResizeDefinition;

public class ResizeDefinition
{
  public int width;
  public int height;
  public int contentWidth;
  public int contentHeight;
  bool darChanged;
  bool sarChangedToSquarePixels;
  bool heightChanged;

  public this(int width, int height)
  {
    this.width = width;
    this.height = height;
    contentWidth = width;
    contentHeight = height;
  }

  public this(int width, int height, int contentWidth, int contentHeight, bool darChanged, bool sarChanged, bool heightChanged)
  {
    this.width = makeWidthMultiplyOf2(width);
    this.height = height;
    this.contentWidth = makeWidthMultiplyOf2(contentWidth);
    this.contentHeight = contentHeight;
    this.darChanged = darChanged;
    sarChangedToSquarePixels = sarChanged;
    this.heightChanged = heightChanged;
  }

  public bool changed() {
    return (darChanged) || (sarChangedToSquarePixels) || (heightChanged);
  }

  public bool physicalDimensionsChanged() {
    return (heightChanged) || (sarChangedToSquarePixels);
  }

  private int makeWidthMultiplyOf2(int width)
  {
    return (width + 1) / 2 * 2;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.external.ResizeDefinition
 * JD-Core Version:    0.6.2
 */