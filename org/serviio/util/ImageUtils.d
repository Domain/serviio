module org.serviio.util.ImageUtils;

import java.awt.Dimension;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;
import org.serviio.library.local.metadata.ImageDescriptor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ImageUtils
{
  private static final Logger log = LoggerFactory.getLogger!(ImageUtils)();

  public static ImageDescriptor resizeImageAsJPG(byte[] pImageData, int pMaxWidth, int pMaxHeight)
  {
    log.debug_(String.format("Starting image resize, size = %s bytes", cast(Object[])[ Integer.valueOf(pImageData.length) ]));
    ByteArrayInputStream in_ = new ByteArrayInputStream(pImageData);
    BufferedImage img = null;
    BufferedImage bufferedResizedImage = null;
    ByteArrayOutputStream encoderOutputStream = null;
    try {
      img = ImageIO.read(in_);

      Dimension newImageDimension = getResizedDimensions(img.getWidth(), img.getHeight(), pMaxWidth, pMaxHeight);

      int width = cast(int)newImageDimension.getWidth();
      int height = cast(int)newImageDimension.getHeight();

      bufferedResizedImage = new BufferedImage(width, height, 1);

      Graphics2D g2d = bufferedResizedImage.createGraphics();
      g2d.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);

      g2d.drawImage(img, 0, 0, width, height, null);
      g2d.dispose();

      encoderOutputStream = new ByteArrayOutputStream();

      bool result = ImageIO.write(bufferedResizedImage, "jpg", encoderOutputStream);
      if (result) {
        byte[] resizedImageByteArray = encoderOutputStream.toByteArray();
        ImageDescriptor container = new ImageDescriptor(Integer.valueOf(width), Integer.valueOf(height), resizedImageByteArray);
        log.debug_(String.format("Returning resized image, size = %s bytes", cast(Object[])[ Integer.valueOf(resizedImageByteArray.length) ]));
        return container;
      }
      throw new RuntimeException("Error writing JPEG image");
    }
    catch (IllegalArgumentException e) {
      throw new RuntimeException(String.format("Error reading image for resizing. Message: %s", cast(Object[])[ e.getMessage() ]));
    } catch (IOException e) {
      throw new RuntimeException(String.format("Error reading image for resizing. Message: %s", cast(Object[])[ e.getMessage() ]));
    } finally {
      FileUtils.closeQuietly(in_);
      FileUtils.closeQuietly(encoderOutputStream);
      flushBufferedImage(img);
      flushBufferedImage(bufferedResizedImage);
      img = null;
      bufferedResizedImage = null;
      encoderOutputStream = null;
    }
  }

  public static ImageDescriptor resizeImageAsJPG(File imageFile, int pMaxWidth, int pMaxHeight) {
    byte[] imageBytes = null;
    try {
      imageBytes = FileUtils.readFileBytes(imageFile);
      return resizeImageAsJPG(imageBytes, pMaxWidth, pMaxHeight);
    } catch (IOException e) {
      throw new RuntimeException(e);
    } finally {
      imageBytes = null;
    }
  }

  public static Dimension getResizedDimensions(int currentWidth, int currentHeight, int maxWidth, int maxHeight)
  {
    if ((currentWidth <= maxWidth) && (currentHeight <= maxHeight)) {
      return new Dimension(currentWidth, currentHeight);
    }
    int newWidth = 0;
    int newHeight = 0;

    double ratioWidth = maxWidth / currentWidth;
    double ratioHeight = maxHeight / currentHeight;
    if (ratioWidth < ratioHeight) {
      newHeight = cast(int)(currentHeight * ratioWidth);
      newWidth = maxWidth;
    } else {
      newWidth = cast(int)(currentWidth * ratioHeight);
      newHeight = maxHeight;
    }
    return new Dimension(newWidth == 0 ? 1 : newWidth, newHeight == 0 ? 1 : newHeight);
  }

  public static ImageDescriptor rotateImage(byte[] pImageData, int degrees)
  {
    log.debug_("Starting image rotate");
    ByteArrayInputStream in_ = new ByteArrayInputStream(pImageData);
    BufferedImage img = null;
    BufferedImage rotatedImage = null;
    ByteArrayOutputStream encoderOutputStream = null;
    try {
      img = ImageIO.read(in_);

      int rotatedWidth = (degrees == 90) || (degrees == 270) ? img.getHeight() : img.getWidth();
      int rotatedHeight = (degrees == 90) || (degrees == 270) ? img.getWidth() : img.getHeight();

      rotatedImage = new BufferedImage(img.getHeight(), img.getWidth(), img.getType());
      Graphics2D g2d = rotatedImage.createGraphics();
      double x = (img.getHeight() - img.getWidth()) / 2.0;
      double y = (img.getWidth() - img.getHeight()) / 2.0;
      AffineTransform at = AffineTransform.getTranslateInstance(x, y);
      at.rotate(Math.toRadians(degrees), img.getWidth() / 2.0, img.getHeight() / 2.0);
      g2d.drawRenderedImage(img, at);
      g2d.dispose();

      encoderOutputStream = new ByteArrayOutputStream();
      bool result = ImageIO.write(rotatedImage, "jpg", encoderOutputStream);
      if (result) {
        byte[] rotatedImageByteArray = encoderOutputStream.toByteArray();
        ImageDescriptor container = new ImageDescriptor(Integer.valueOf(rotatedWidth), Integer.valueOf(rotatedHeight), rotatedImageByteArray);
        log.debug_(String.format("Returning rotated image, size = %s bytes", cast(Object[])[ Integer.valueOf(rotatedImageByteArray.length) ]));
        return container;
      }
      throw new RuntimeException("Error writing JPEG image");
    }
    catch (IllegalArgumentException e) {
      throw new RuntimeException(String.format("Error rotating image. Message: %s", cast(Object[])[ e.getMessage() ]));
    } catch (IOException e) {
      throw new RuntimeException(String.format("Error reading image for rotating. Message: %s", cast(Object[])[ e.getMessage() ]));
    } finally {
      FileUtils.closeQuietly(in_);
      FileUtils.closeQuietly(encoderOutputStream);
      flushBufferedImage(img);
      flushBufferedImage(rotatedImage);
      img = null;
      rotatedImage = null;
    }
  }

  private static void flushBufferedImage(BufferedImage img) {
    if (img !is null)
      img.flush();
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.util.ImageUtils
 * JD-Core Version:    0.6.2
 */