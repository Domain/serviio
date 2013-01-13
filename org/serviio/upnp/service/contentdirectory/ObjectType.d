module org.serviio.upnp.service.contentdirectory.ObjectType;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public class ObjectType
{
	enum ObjectTypeEnum
	{
		CONTAINERS, ITEMS, ALL,
	}

	ObjectTypeEnum objectType;
	alias objectType this;

  public bool supportsContainers() {
    return getContainerTypes().contains(this);
  }

  public bool supportsItems() {
    return getItemTypes().contains(this);
  }

  public static Set!(ObjectType) getItemTypes() {
    return new HashSet!(ObjectType)(Arrays.asList(cast(ObjectType[])[ ITEMS, ALL ]));
  }

  public static Set!(ObjectType) getContainerTypes() {
    return new HashSet!(ObjectType)(Arrays.asList(cast(ObjectType[])[ CONTAINERS, ALL ]));
  }

  public static Set!(ObjectType) getAllTypes() {
    return new HashSet!(ObjectType)(Arrays.asList(cast(ObjectType[])[ CONTAINERS, ITEMS, ALL ]));
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.service.contentdirectory.ObjectType
 * JD-Core Version:    0.6.2
 */