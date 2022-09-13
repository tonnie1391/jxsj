  --
-- FileName: xianglu.lua
-- Author: hanruofei
-- Time: 2011/3/22 17:13
-- Comment:香炉
--


SpecialEvent.tbQingMing2011 = SpecialEvent.tbQingMing2011 or {};
local tbQingMing2011 = SpecialEvent.tbQingMing2011;

local tbNpc= Npc:GetClass("xianglu_2011");

function tbNpc:OnDialog()
	local szMsg = "山孤烟雾薄，树小雨声稀！风飘飘，雨潇潇，心思悠悠，悲情渺渺，莫道不销魂，何处暗香盈袖？";
	local tbOpt = 
	{
		{"领取奖励", self.GetAward, self, me.nId, him.dwId},
		{"Để ta suy nghĩ thêm"}
	};
	Dialog:Say(szMsg, tbOpt);
	return;
end

function tbNpc:GetAward(nPlayerId, nNpcId)
	local bOk, szErrorMsg = tbQingMing2011:CanGetAwardFrom(nPlayerId, nNpcId);
	if bOk == 0 then
		if szErrorMsg then
			Dialog:Say(szErrorMsg);
		end
		return;
	end
	
	local szMsg = tbQingMing2011.szGetAwardMsg;
	local nDuration = tbQingMing2011.nGetAwardDuration;
	local tbCallBack = {self.GetAwardEx, self, nPlayerId, nNpcId};
	
	GeneralProcess:StartProcess(szMsg, nDuration, tbCallBack, nil, tbQingMing2011.tbBreakEvent);
end
-- 领奖
function tbNpc:GetAwardEx(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp then
		return;
	end
	
	local nCallerId, nGroupId, tbAwardedPlayerList = tbTemp.nCallerId, tbTemp.nGroupId, tbTemp.tbAwardedPlayerList;
	if not nCallerId or not nGroupId or not tbAwardedPlayerList then
		return;
	end
	
	local bIsCaller = nPlayerId == nCallerId;
	
	local bOk, szErrorMsg = tbQingMing2011:CanGetAwardFrom(nPlayerId, nNpcId);
	if bOk == 0 then
		if szErrorMsg then
			pPlayer.Msg(szErrorMsg);
		end
		return;
	end
	
	local bOk, szErrorMsg = tbQingMing2011:AddAward(nPlayerId, nGroupId, bIsCaller)
		
	if bOk == 0 then
		if szErrorMsg then
			pPlayer.Msg(szErrorMsg);
		end
		return;
	end

	if bIsCaller then
		tbTemp.bIsCallerAwarded = 1;
		local nAwardType = tbQingMing2011:GetAwardType(nGroupId);
		StatLog:WriteStatLog("stat_info", "qingmingjie2011", "award", nPlayerId, tostring(pPlayer.nTeamId) .. "," .. tostring(nAwardType));
	else
		local nNowCount = pPlayer.GetTask(tbQingMing2011.TASKGID, tbQingMing2011.TASK_AWARD_COUNT);
		pPlayer.SetTask(tbQingMing2011.TASKGID, tbQingMing2011.TASK_AWARD_COUNT, nNowCount + 1);
		tbAwardedPlayerList[nPlayerId] = 1;
	end

	return 1;
end