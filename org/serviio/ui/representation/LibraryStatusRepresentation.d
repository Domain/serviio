module org.serviio.ui.representation.LibraryStatusRepresentation;

import java.lang.String;

public class LibraryStatusRepresentation
{
    private bool libraryUpdatesCheckerRunning;
    private bool libraryAdditionsCheckerRunning;
    private String lastAddedFileName;
    private int numberOfAddedFiles = 0;

    public bool isLibraryUpdatesCheckerRunning()
    {
        return libraryUpdatesCheckerRunning;
    }

    public bool isLibraryAdditionsCheckerRunning() {
        return libraryAdditionsCheckerRunning;
    }

    public String getLastAddedFileName() {
        return lastAddedFileName;
    }

    public int getNumberOfAddedFiles() {
        return numberOfAddedFiles;
    }

    public void setLibraryUpdatesCheckerRunning(bool libraryUpdatesCheckerRunning) {
        this.libraryUpdatesCheckerRunning = libraryUpdatesCheckerRunning;
    }

    public void setLibraryAdditionsCheckerRunning(bool libraryAdditionsCheckerRunning) {
        this.libraryAdditionsCheckerRunning = libraryAdditionsCheckerRunning;
    }

    public void setLastAddedFileName(String lastAddedFileName) {
        this.lastAddedFileName = lastAddedFileName;
    }

    public void setNumberOfAddedFiles(int numberOfAddedFiles) {
        this.numberOfAddedFiles = numberOfAddedFiles;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.ui.representation.LibraryStatusRepresentation
* JD-Core Version:    0.6.2
*/