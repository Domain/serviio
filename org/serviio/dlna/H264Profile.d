module org.serviio.dlna.H264Profile;

public class H264Profile
{
	enum H264ProfileEnum
	{
		BASELINE, 
		MAIN, 
		EXTENDED, 
		HIGH, 
		HIGH_10, 
		HIGH_422, 
		HIGH_444,
	}

	H264ProfileEnum h264Profile;
	alias h264Profile this;

  public int getCode()
  {
	  switch (h264Profile)
	  {
		  case BASELINE:
			  return 66; 

		  case MAIN:
			  return 77; 

		  case EXTENDED:
			  return 88; 

		  case HIGH:
			  return 100; 

		  case HIGH_10:
			  return 110; 

		  case HIGH_422:
			  return 122; 

		  case HIGH_444:
			  return 244;
	  }
	  return 0;
  }

  public static H264Profile getByCode(int code)
  {
    foreach (H264Profile p ; values()) {
      if (p.getCode() == code) {
        return p;
      }
    }
    return null;
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.dlna.H264Profile
 * JD-Core Version:    0.6.2
 */