-- 文件名　：refreshnpa_gs.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-04-07 19:48:54
-- 描  述  ：
SpecialEvent.LaborDay = SpecialEvent.LaborDay or {};
local LaborDay = SpecialEvent.LaborDay or {};

function LaborDay:AddDefender_GS()	
	--士兵	
	local nLevel = 0;
	for nMapId, tbPoint in pairs(LaborDay.tbNpcsoldierList) do
		if nMapId < 130 then
			nLevel = 95;
		else
			nLevel = 115;
		end		
		if SubWorldID2Idx(nMapId) >= 0 then				
			for _,tbPosition in ipairs(tbPoint) do
				local pNpc = KNpc.Add2(6812, nLevel, -1, nMapId, tbPosition[1]/32, tbPosition[2]/32, 1);
				if not pNpc then
					print("call npc failed:"..6812, nMapId, tbPosition[1],tbPosition[2]);
				end
			end
		end
	end
	--将军
	for nMapId, tbPoint in pairs(LaborDay.tbNpcgenList) do
		if nMapId < 130 then
			nLevel = 95;
		else
			nLevel = 115;
		end
		for _,tbPosition in ipairs(tbPoint) do
			if SubWorldID2Idx(nMapId) >= 0 then
				local pNpc = KNpc.Add2(6813, nLevel, -1, nMapId, tbPosition[1]/32, tbPosition[2]/32, 1);
				if not pNpc then
					print("call npc failed:"..6813);
				end
			end
		end
	end	
end

-- clear npc
function LaborDay:ClearDefender_GS()
	local szName = KNpc.GetNameByTemplateId(6812);		
	for nMapId, _ in pairs(self.tbNpcsoldierList) do	
		if SubWorldID2Idx(nMapId) >= 0 then
			ClearMapNpcWithName(nMapId, szName);
		end
	end
	
	szName = KNpc.GetNameByTemplateId(6813);	
	for nMapId, _ in pairs(self.tbNpcgenList) do
		if SubWorldID2Idx(nMapId) >= 0 then
			ClearMapNpcWithName(nMapId, szName);
		end
	end
end

--加经验
function LaborDay:GetExpPoint(szName)
	local tbPlayerList = KPlayer:GetAllPlayer();
	for _,pPlayer in pairs(tbPlayerList) do
		pPlayer.AddExp(3000000);
	end
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL,string.format( "祝贺[%s]打开令牌宝箱并获得奖励[全服的所有玩家同时获得3百万经验值]", szName));
end
