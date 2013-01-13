module org.serviio.external.FFmpegCLBuilder;

import java.lang.String;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import org.serviio.external.DCRawCLBuilder;

public class FFmpegCLBuilder : AbstractCLBuilder
{
  static String executablePath = setupExecutablePath("ffmpeg.location", "ffmpeg_executable");

  private /*final*/ List!(String) globalOptions = new ArrayList!(String)();
  private /*final*/ List!(String) inFileOptions = new ArrayList!(String)();
  private String inFile;
  private /*final*/ List!(String) outFileOptions = new ArrayList!(String)();
  private String outFile;

  public String[] build()
  {
    List!(String) args = new ArrayList!(String)();
    args.add(executablePath);
    args.addAll(globalOptions);
    if (inFile !is null) {
      args.addAll(inFileOptions);
      args.add("-i");
      args.add(inFile);
    }
    if (outFile !is null) {
      args.addAll(outFileOptions);
      args.add(outFile);
    }
    String[] ffmpegArgs = new String[args.size()];
    return cast(String[])args.toArray(ffmpegArgs);
  }

  public FFmpegCLBuilder globalOptions(String[] options) {
    Collections.addAll(globalOptions, options);
    return this;
  }

  public FFmpegCLBuilder inFileOptions(String[] options) {
    Collections.addAll(inFileOptions, options);
    return this;
  }

  public FFmpegCLBuilder outFileOptions(String[] options) {
    Collections.addAll(outFileOptions, options);
    return this;
  }

  public FFmpegCLBuilder inFile(String inFile) {
    this.inFile = inFile;
    return this;
  }

  public FFmpegCLBuilder outFile(String outFile) {
    this.outFile = outFile;
    return this;
  }

  List!(String) getOutFileOptions() {
    return Collections.unmodifiableList(outFileOptions);
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.external.FFmpegCLBuilder
 * JD-Core Version:    0.6.2
 */