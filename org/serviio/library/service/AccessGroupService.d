module org.serviio.library.service.AccessGroupService;

import java.lang.Long;
import java.util.List;
import org.serviio.db.dao.DAOFactory;
import org.serviio.library.entities.AccessGroup;
import org.serviio.renderer.entities.Renderer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AccessGroupService
{
	private static immutable Logger log;

	static this()
	{
		log = LoggerFactory.getLogger!(AccessGroupService)();
	}

	public static AccessGroup getAccessGroupForRenderer(Renderer renderer)
	{
		if ((renderer is null) || (renderer.getAccessGroupId() is null)) {
			log.debug_("Could not find a access group for renderer. Using ANY.");
			return AccessGroup.ANY;
		}
		AccessGroup profile = cast(AccessGroup)DAOFactory.getAccessGroupDAO().read(renderer.getAccessGroupId());
		if (profile is null)
		{
			log.debug_(String.format("Could not find a access group with id '%s' for renderer. Using ANY.", cast(Object[])[ renderer.getAccessGroupId() ]));
			return AccessGroup.ANY;
		}
		return profile;
	}

	public static List!(AccessGroup) getAccessGroupsForRepository(Long repositoryId)
	{
		return DAOFactory.getAccessGroupDAO().getAccessGroupsForRepository(repositoryId);
	}

	public static List!(AccessGroup) getAccessGroupsForOnlineRepository(Long repositoryId) {
		return DAOFactory.getAccessGroupDAO().getAccessGroupsForOnlineRepository(repositoryId);
	}
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.library.service.AccessGroupService
* JD-Core Version:    0.6.2
*/