module org.serviio.external.DCRawCLBuilder;

import java.lang.String;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import org.serviio.external.AbstractCLBuilder;

public class DCRawCLBuilder : AbstractCLBuilder
{
  static String executablePath = setupExecutablePath("dcraw.location", "dcraw_executable");

  private /*final*/ List!(String) _inFileOptions = new ArrayList!(String)();
  private String _inFile;

  override public String[] build()
  {
    List!(String) args = new ArrayList!(String)();
    args.add(executablePath);
    if (_inFile !is null) {
      args.addAll(_inFileOptions);
      args.add(_inFile);
    }
    String[] dcrawArgs = new String[args.size()];
    return cast(String[])args.toArray(dcrawArgs);
  }

  public DCRawCLBuilder inFileOptions(String[] options) {
    Collections.addAll(_inFileOptions, options);
    return this;
  }

  public DCRawCLBuilder inFile(String inFile) {
    this._inFile = inFile;
    return this;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.external.DCRawCLBuilder
 * JD-Core Version:    0.6.2
 */