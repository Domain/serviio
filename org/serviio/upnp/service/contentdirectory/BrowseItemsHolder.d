module org.serviio.upnp.service.contentdirectory.BrowseItemsHolder;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import org.serviio.upnp.service.contentdirectory.classes.DirectoryObject;

public class BrowseItemsHolder(T : DirectoryObject) : Serializable
{
	private static const long serialVersionUID = -1985812715117276202L;
	private List!(T) items;

	private int totalMatched = 0;

	public this()
	{
		items = new ArrayList!(T)();
	}

	public List!(T) getItems()
	{
		return items;
	}

	public void setItems(List!(T) items) {
		this.items = items;
	}

	public int getTotalMatched() {
		return totalMatched;
	}

	public void setTotalMatched(int totalMatched) {
		this.totalMatched = totalMatched;
	}

	public int getReturnedSize() {
		return items.size();
	}
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.upnp.service.contentdirectory.BrowseItemsHolder
* JD-Core Version:    0.6.2
*/