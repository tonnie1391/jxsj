-- 文件名　：huatongcard.lua
-- 创建者　：furuilei
-- 创建时间：2009-12-21 10:48:12
-- 功能描述：婚礼道具（花童卡片）
-- modify by zhangjinpin@kingsoft 2010-01-20

local tbHuaTong = Item:GetClass("marry_huatongcard");

--====================================================================
tbHuaTong.nNpcId = 6518;
tbHuaTong.nLiveTime = 10 * 60;
tbHuaTong.nDepTime = 5;
tbHuaTong.nCount = tbHuaTong.nLiveTime / tbHuaTong.nDepTime;
--====================================================================

function tbHuaTong:OnUse()
	if (Marry:CheckState() == 0) then
		return 0;
	end
	if (me.nFightState ~= 0) then
		Dialog:Say("请注意：只有在非战斗状态才可以使用该道具。");
		return 0;
	end
	
	local nMapId, nMapX, nMapY = me.GetWorldPos();
	local szCustomString = it.szCustomString or "";
	
	local pNpc = KNpc.Add2(self.nNpcId, 1, -1, nMapId, nMapX, nMapY);
	if (pNpc) then
		if ("" ~= szCustomString and Marry:CheckWeddingMap(me.nMapId) ~= 1) then
			pNpc.SetTitle(string.format("<color=blue>%s<color>", szCustomString));
		end
		pNpc.SetLiveTime(self.nLiveTime * Env.GAME_FPS);
		local tbNpcData = pNpc.GetTempTable("Marry");
		tbNpcData.nYanHuaCount = self.nCount;
		Timer:Register(Env.GAME_FPS, self.OpenYanHua, self, pNpc);
	end
	return 1;
end

function tbHuaTong:OpenYanHua(pNpc)
	if (not pNpc) then
		return 0;
	end
	
	local tbNpcData = pNpc.GetTempTable("Marry");
	local nCount = tbNpcData.nYanHuaCount;
	if (not nCount or nCount <= 0) then
		return 0;
	end
	tbNpcData.nYanHuaCount = nCount - 1;
	
	pNpc.CastSkill(1559, 1, -1, pNpc.nIndex);
	return 5 * Env.GAME_FPS;
end
