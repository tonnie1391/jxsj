-- 文件名　：waitercard.lua
-- 创建者　：furuilei
-- 创建时间：2009-12-21 09:29:38
-- 功能描述：婚礼道具（仆人卡片）
-- modify by zhangjinpin@kingsoft 2010-01-21

local tbWaiter = Item:GetClass("marry_waitercard");

tbWaiter.tbWaiterInfo = 
{
	[1] = {szGDPL = "18-1-587-1", nNpcId = 6520, nLiveTime = 15 * 60},
	[2] = {szGDPL = "18-1-589-1", nNpcId = 6525, nLiveTime = 15 * 60},
};

function tbWaiter:OnUse()
	if (Marry:CheckState() == 0) then
		return 0;
	end
	if (me.nFightState ~= 0) then
		Dialog:Say("请注意：只有在非战斗状态才可以使用该道具。");
		return 0;
	end

	local szCurItemGDPL = string.format("%s-%s-%s-%s", it.nGenre, it.nDetail, it.nParticular, it.nLevel);
	local szCustomString = it.szCustomString or "";
	for _, tbInfo in ipairs(self.tbWaiterInfo) do
		if (szCurItemGDPL == tbInfo.szGDPL) then
			local nMapId, nMapX, nMapY = me.GetWorldPos();
			local pNpc = KNpc.Add2(tbInfo.nNpcId, 1, -1, nMapId, nMapX, nMapY);
			if (pNpc) then
				if ("" ~= szCustomString and Marry:CheckWeddingMap(me.nMapId) ~= 1) then
					local szTitle = string.format("<color=blue>%s<color>", szCustomString);
					pNpc.SetTitle(szTitle);
				end
				
				pNpc.SetLiveTime(tbInfo.nLiveTime * Env.GAME_FPS);
			end
		end
	end
	return 1;
end
