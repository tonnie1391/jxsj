--
-- FileName: qingmingboss.lua
-- Author: hanruofei
-- Time: 2011/3/22 16:53
-- Comment: 2011清明节BOSS
--

SpecialEvent.tbQingMing2011 =  SpecialEvent.tbQingMing2011 or {};
local tbQingMing2011 = SpecialEvent.tbQingMing2011;

local tbNpc= Npc:GetClass("qingmingboss_2011");

-- 清明节招出来的BOSS死了，那么在原地刷一个香炉
function tbNpc:OnDeath()

	local nMapId, nPosX, nPosY = him.GetWorldPos();
	if not nMapId or not nPosX or not nPosY then
		return;
	end
	local tbBoss = tbQingMing2011.tbXiangLu;
	local pNpc = KNpc.Add2(tbBoss.nNpcId, tbBoss.nLevel, -1, nMapId, nPosX, nPosY, 0, 1)
	if not pNpc then
		return;
	end
	pNpc.SetLiveTime(tbQingMing2011.nXiangLuLiveTime);
		
	--复制附加信息
	local tbAttachedInfo = him.GetTempTable("Npc");
	if not tbAttachedInfo then
		return;
	end
	
	local pCaller = KPlayer.GetPlayerObjById(tbAttachedInfo.nCallerId);
	if pCaller then
		local _, nCount = pCaller.GetTeamMemberList();
		StatLog:WriteStatLog("stat_info", "qingmingjie2011", "kill_boss", tbAttachedInfo.nCallerId, tostring(pCaller.nTeamId) .. "," .. tostring(nCount or 0));
	end
	
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp then
		return;
	end
	
	pNpc.szName = string.format("%s队伍的香炉", tbAttachedInfo.szCallerName);
	
	for k, v in pairs(tbAttachedInfo) do
		tbTemp[k] = v;
	end

	tbTemp.tbAwardedPlayerList = {};
end
