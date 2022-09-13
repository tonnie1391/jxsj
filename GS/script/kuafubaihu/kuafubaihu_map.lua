-------------------------------------------------------
-- 文件名　：kuafubaihu_map.lua
-- 创建者　：zhangjunjie
-- 创建时间：2010-12-17 09:16:40
-- 文件描述：
-------------------------------------------------------


Require("\\script\\kuafubaihu\\kuafubaihu_def.lua")

if not MODULE_GAMESERVER then
	return;
end

local tbMap = KuaFuBaiHu.Map or {};
KuaFuBaiHu.Map = tbMap;

function tbMap:OnEnter(szParam)
	if (me.GetCamp() == 6) then	-- GM阵营
		return;
	end
	local _,nIndex,nCampId = KuaFuBaiHu:GetPlayerGroupIndex(me);
	local tbMis = KuaFuBaiHu:GetMission(nIndex);
	if (not tbMis) then
		me.Msg("跨服白虎堂正在维护中！");
		Dbg:WriteLogEx(2, "KuafuBaiHu",me.szName,me.nId,me.nMapId,"mission not created!");
		KuaFuBaiHu:NewWorld2GlobalMap(me);
		return;
	end
	tbMis:JoinPlayer(me, nCampId);
	tbMis:AddPlayerCount();
	Dbg:WriteLogEx(2, "KuafuBaiHu","Enter Fight Map:",tbMis.nMapId,me.nId,tbMis:GetPlayerCount(),tbMis:GetGroupsCount());
	Player:AddProtectedState(me, KuaFuBaiHu.nProtectedTime);
end

function tbMap:OnEnter2(szParam) 
	if (me.GetCamp() == 6) then	-- GM阵营
		return;
	end
	KuaFuBaiHu:ShowTimeInfo(me,KuaFuBaiHu.FIGHTSTATE)
end

function tbMap:OnLeave(szParam)
	if (me.GetCamp() == 6) then	-- GM阵营
		return;
	end
	Dialog:ShowBattleMsg(me, 0, 0);
	if KuaFuBaiHu.nActionState == KuaFuBaiHu.FIGHTSTATE or KuaFuBaiHu.nActionState == KuaFuBaiHu.FORBIDENTER then
		local _,nIndex,nCampId = KuaFuBaiHu:GetPlayerGroupIndex(me);
		local tbMis = KuaFuBaiHu:GetMission(nIndex);
		if tbMis and tbMis:IsOpen() ~= 0 then
			tbMis:KickPlayer(me);
		end
	end
end

function KuaFuBaiHu:LinkMap(nMapId)
	local tbMap = Map:GetClass(nMapId);
	for szFunMap, _ in pairs(self.Map) do
		tbMap[szFunMap] = self.Map[szFunMap];
	end
end


for nId,tbMap in pairs(KuaFuBaiHu.tbFightMapIdList) do
	if tbMap then
		for _,nMapId in pairs(tbMap) do
			if nMapId then
				KuaFuBaiHu:LinkMap(nMapId);
			end
		end
	end
end

