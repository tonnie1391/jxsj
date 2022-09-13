	-- 文件名　：zhenzai_gs.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-04-15 17:01:37
-- 描  述  ：赈灾gs

if  not MODULE_GAMESERVER then
	return;
end
Require("\\script\\event\\specialevent\\ZhenZai\\ZhenZai_def.lua");
SpecialEvent.ZhenZai = SpecialEvent.ZhenZai or {};
local ZhenZai = SpecialEvent.ZhenZai or {};

--永乐镇增加许愿树
function ZhenZai:AddVowTree()
	if SubWorldID2Idx(ZhenZai.tbVowTreePosition[1]) >= 0 then	
		 if ZhenZai.nVowTreenId == 0 then			--没有加载过许愿树，add许愿树
	 		local pNpc = KNpc.Add2(ZhenZai.nVowTreeTemplId, 100, -1, ZhenZai.tbVowTreePosition[1], ZhenZai.tbVowTreePosition[2], ZhenZai.tbVowTreePosition[3]);
	 		if pNpc then
		 		ZhenZai.nVowTreenId = pNpc.dwId;
		 		pNpc.SetTitle("<color=green>风调雨顺国泰民安<color>");
		 	end
		end
		Dialog:GlobalNewsMsg_GS("许愿佛已经安放，大家带着<color=yellow>希望之水<color>快去为灾区送上自己的一份心意吧！");
	end
end

--删除许愿树
function ZhenZai.DeleteVowTree()
	if SubWorldID2Idx(ZhenZai.tbVowTreePosition[1]) >= 0 then
		if ZhenZai.nVowTreenId and ZhenZai.nVowTreenId ~= 0 then	--加载过许愿树
			local pNpc = KNpc.GetById(ZhenZai.nVowTreenId);
			if pNpc then
				pNpc.Delete();
				ZhenZai.nVowTreenId = 0;
			end			
		end
	end
end

--满足1001个愿望，给第2010个愿望的玩家奖励，通知全服去领奖
function ZhenZai:OnSpecialAward(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	pPlayer.AddTitle(unpack(ZhenZai.tbVowTree_Title));
	pPlayer.SetCurTitle(unpack(ZhenZai.tbVowTree_Title));
	local pItemEx = pPlayer.AddItem(unpack(ZhenZai.tbBaoXiang));
	if pItemEx then
		EventManager:WriteLog(string.format("[赈灾]获得物品:%s",pItemEx.szName), pPlayer);
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[赈灾]获得物品:%s",pItemEx.szName));
		Dialog:GlobalNewsMsg_GS(string.format("%s许下了平安佛的第%s次祝愿，成为今日的平安大使，灾区人民一定能平安！", pPlayer.szName, ZhenZai.nTrapNumber));	
	else
		pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[赈灾]获得物品失败"));	
	end	
			
end
--活动期间内服务器维护或者宕机启动，重新加载npc
function ZhenZai:ServerStartFunc()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData >= self.VowTreeOpenTime and nData <= self.VowTreeCloseTime then	--活动期间内启动服务器
		ZhenZai:AddVowTree();
	end
end

ServerEvent:RegisterServerStartFunc(ZhenZai.ServerStartFunc, ZhenZai);
