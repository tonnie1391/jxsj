-------------------------------------------------------
-- 文件名　：lipao.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-01-05 10:57:18
-- 文件描述：
-------------------------------------------------------

local tbItem = Item:GetClass("marry_lipao");

tbItem.MAXNUM_PLAYER = 100;	-- 最多对当前地图的100个人显示出特效

-- 使用求婚礼炮
function tbItem:OnUse()

	if it.nCount <= 0 then
		return 0;
	end
	
	-- 获取随机的当前地图前100个玩家
	local tbPlayerList, nCount = KPlayer.GetMapPlayer(me.nMapId);
	
	-- 随机打乱
	if nCount > self.MAXNUM_PLAYER then
		Lib:ShuffleInPlace(tbPlayerList);
		for i = #tbPlayerList, self.MAXNUM_PLAYER + 1, -1 do
			tbPlayerList[i] = nil;
		end
	end
	
	-- 如果随机到的人里面没有自己
	local bHaveMe = 0;
	for _, pPlayer in pairs(tbPlayerList or {}) do
		if pPlayer.nId == me.nId then
			bHaveMe = 1;
		end
	end
	
	-- 把自己添加进去
	if bHaveMe == 0 then
		table.insert(tbPlayerList, me);
	end
	
	-- 频道公告
	local szMsg = string.format("<color=yellow>【%s】<color>燃放了载满浓浓情意的皇家礼炮", me.szName);
	
	for _, pPlayer in pairs(tbPlayerList or {}) do
		pPlayer.Msg(szMsg);
		pPlayer.CallClientScript({"UiManager:OpenWindow", "UI_WEDDING", 1});
	end
	
	return 1;
end
