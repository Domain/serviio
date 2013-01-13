module org.serviio.external.ProcessExecutor;

import java.lang.String;
import java.lang.Long;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.serviio.external.io.OutputBytesReader;
import org.serviio.external.io.OutputReader;
import org.serviio.external.io.OutputTextReader;
import org.serviio.external.io.PipedOutputBytesReader;
import org.serviio.util.CollectionUtils;
import org.serviio.util.FileUtils;
import org.serviio.util.Platform;
import org.serviio.util.ProcessUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ProcessExecutor : Thread
{
  private static immutable Logger log = LoggerFactory.getLogger!(ProcessExecutor);
  private static const int OUTPUT_STREAM_TIMEOUT = 5000;
  private String[] commandArguments;
  private bool destroyed = false;

  private bool checkForExitValue = false;
  private Long failsafeTimeout;
  private Process process;
  private OutputReader stdoutReader;
  private OutputTextReader stderrReader;
  private bool success = true;
  private bool unlimitedPipe = false;
  private bool useStdOutForTextOutput = false;

  private Set!(ProcessListener) listeners = new HashSet!(ProcessListener)();

  public this(String[] commandArguments)
  {
    this(commandArguments, false);
  }

  public this(String[] commandArguments, bool checkForExitValue) {
    this(commandArguments, checkForExitValue, null);
  }

  public this(String[] commandArguments, bool checkForExitValue, Long failsafeTimeout) {
    this(commandArguments, checkForExitValue, failsafeTimeout, false);
  }

  public this(String[] commandArguments, bool checkForExitValue, Long failsafeTimeout, bool unlimitedPipe) {
    this(commandArguments, checkForExitValue, failsafeTimeout, unlimitedPipe, false);
  }

  public this(String[] commandArguments, bool checkForExitValue, Long failsafeTimeout, bool unlimitedPipe, bool useStdOutForTextOutput) {
    this.commandArguments = commandArguments;
    this.checkForExitValue = checkForExitValue;
    this.failsafeTimeout = failsafeTimeout;
    this.unlimitedPipe = unlimitedPipe;
    this.useStdOutForTextOutput = useStdOutForTextOutput;
  }

  public void run()
  {
    Thread faisafeThread = null;
    try {
      log.debug_((new StringBuilder()).append("Starting ").append(CollectionUtils.arrayToCSV(commandArguments, " ")).toString());

      ProcessBuilder processBuilder = new ProcessBuilder(commandArguments);
      if (Platform.isWindows()) {
        Map!(String, String) env = processBuilder.environment();
        env.putAll(createWindowsRuntimeEnvironmentVariables());

        processBuilder.command(commandArguments);
      }

      process = processBuilder.start();
      stderrReader = new OutputTextReader(this, process.getErrorStream());
      if (useStdOutForTextOutput) {
        stdoutReader = new OutputTextReader(this, process.getInputStream());
      }
      else if (unlimitedPipe)
        stdoutReader = new PipedOutputBytesReader(process.getInputStream());
      else {
        stdoutReader = new OutputBytesReader(process.getInputStream());
      }

      stderrReader.start();
      stdoutReader.start();

      if (failsafeTimeout !is null)
        faisafeThread = makeFailSafe(failsafeTimeout);
      try
      {
        process.waitFor();
        stdoutReader.join(OUTPUT_STREAM_TIMEOUT);
        stderrReader.join(OUTPUT_STREAM_TIMEOUT);
      } catch (InterruptedException e) {
      }
    } catch (Exception e) {
      log.error((new StringBuilder()).append("Fatal error in process starting: ").append(e.getMessage()).toString());
      success = false;
      stopProcess(false);
    } finally {
      if ((!destroyed) && (checkForExitValue))
        try {
          if ((process !is null) && (process.exitValue() != 0)) {
            log.warn((new StringBuilder()).append("Process ").append(commandArguments[0]).append(" has a return code of ").append(process.exitValue()).append("! This is a possible error.").toString());

            success = false;

            notifyListenersEnd(Boolean.valueOf(false));
          } else if ((process !is null) && (process.exitValue() == 0))
          {
            notifyListenersEnd(Boolean.valueOf(true));
          }
        } catch (IllegalThreadStateException e) {
          log.error(String.format("Error during finishing process execution: %s", cast(Object[])[ e.getMessage() ]));
        }
      else if (!destroyed) {
        notifyListenersEnd(Boolean.valueOf(true));
      }
      destroyed = true;
      if (faisafeThread !is null) {
        faisafeThread.interrupt();
      }
      closeStreams();
    }
  }

  public void addListener(ProcessListener listener)
  {
    listeners.add(listener);
    listener.setExecutor(this);
  }

  public void stopProcess(bool success) {
    if ((process !is null) && (!destroyed)) {
      log.debug_(String.format("Stopping external process: %s", cast(Object[])[ this ]));
      ProcessUtils.destroy(process);
      destroyed = true;
      closeStreams();

      notifyListenersEnd(Boolean.valueOf(success));
    }
  }

  public OutputStream getOutputStream() {
    if (stdoutReader !is null) {
      return stdoutReader.getOutputStream();
    }
    return null;
  }

  public List!(String) getResults() {
    if (useStdOutForTextOutput) {
      return getResultsFromStream(stdoutReader);
    }
    return getResultsFromStream(stderrReader);
  }

  private List!(String) getResultsFromStream(OutputReader reader)
  {
    if (reader !is null) {
      try {
        reader.join(1000L);
      } catch (InterruptedException e) {
      }
      return reader.getResults();
    }
    log.warn("Cannot retrieve results, output reader is null");
    return Collections.emptyList();
  }

  public bool isSuccess()
  {
    return success;
  }

  public void notifyListenersOutputUpdated(String updatedLine) {
    foreach (ProcessListener listener ; listeners)
      listener.outputUpdated(updatedLine);
  }

  private Map!(String, String) createWindowsRuntimeEnvironmentVariables()
  {
    Map!(String, String) newEnv = new HashMap!(String, String)();
    newEnv.putAll(System.getenv());
    String[] i18n = new String[commandArguments.length + 2];
    i18n[0] = "cmd";
    i18n[1] = "/C";
    i18n[2] = commandArguments[0];
    for (int counter = 1; counter < commandArguments.length; counter++)
    {
      String argument = commandArguments[counter];
      String envName = (new StringBuilder()).append("JENV_").append(counter).toString();
      i18n[(counter + 2)] = (new StringBuilder()).append("%").append(envName).append("%").toString();
      bool quotesNeeded = (argument.indexOf(" ") > -1) || (argument.indexOf("&") > -1);
      newEnv.put(envName, (new StringBuilder()).append(quotesNeeded ? "\"" : "").append(argument).append(quotesNeeded ? "\"" : "").toString());
    }
    commandArguments = i18n;
    String[] tempPath = FileUtils.splitFilePathToDriveAndRest(System.getProperty("java.io.tmpdir"));
    newEnv.put("HOMEDRIVE", tempPath[0]);
    newEnv.put("HOMEPATH", tempPath[1]);
    if (log.isTraceEnabled()) {
      log.trace(String.format("Env variables: %s", cast(Object[])[ newEnv.toString() ]));
    }
    return newEnv;
  }

  private Thread makeFailSafe(final Long timeout) {
    Runnable r = new class() Runnable {
      public void run() {
        try {
          Thread.sleep(timeout.longValue());
        } catch (InterruptedException e) {
        }
        stopProcess(false);
      }
    };
    Thread failsafe = new Thread(r);
    failsafe.start();
    return failsafe;
  }

  private void notifyListenersEnd(Boolean success) {
    foreach (ProcessListener listener ; listeners)
      listener.processEnded(success.boolValue());
  }

  private void closeStreams()
  {
    if (stderrReader !is null) {
      stderrReader.closeStream();
    }
    if (stdoutReader !is null) {
      stdoutReader.closeStream();
    }
    if (process !is null)
      FileUtils.closeQuietly(process.getOutputStream());
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.external.ProcessExecutor
 * JD-Core Version:    0.6.2
 */