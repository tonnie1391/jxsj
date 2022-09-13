-- 文件名　：addtitle_base.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-05-05 11:21:13
--增加称号
-- ExtParam1:G
-- ExtParam2:D
-- ExtParam3:P
-- ExtParam4:L


local tbBase = Item:GetClass("addtitle_base");

function tbBase:OnUse()
	local nGenre = tonumber(it.GetExtParam(1));
	local nDetail = tonumber(it.GetExtParam(2));
	local nParticular = tonumber(it.GetExtParam(3));
	local nLevel = tonumber(it.GetExtParam(4));
	if nGenre > 0 and nDetail >0 and nParticular >0  and nLevel > 0 then
		local bRet = me.AddTitle(nGenre,nDetail, nParticular, nLevel);
		if bRet == 1 then
			return 1;
		end
	end
	return 0;
end
