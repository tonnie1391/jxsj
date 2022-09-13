--
-- FileName: qingmingtiaozhanling.lua
-- Author: hanruofei
-- Time: 2011/3/22 11:30
-- Comment: 清明挑战令
--
SpecialEvent.tbQingMing2011 =  SpecialEvent.tbQingMing2011 or {};
local tbQingMing2011 = SpecialEvent.tbQingMing2011;

local tbItem = Item:GetClass("qingmingtiaozhanling_2011");

-- 召唤BOSS了
function tbItem:OnUse()
	local bOk, szErrorMsg = tbQingMing2011:CanCallQingMingBoss(me.nId);
	if bOk == 0 then
		if szErrorMsg then
			local szInfo = tbQingMing2011:GetCallQingMingBossConditionDescription();
			local szMsg = string.format("%s\n\n<color=red>%s<color>", szInfo, szErrorMsg);
			Dialog:Say(szMsg, {"Ta hiểu rồi"});
		end
		return;
	end
	local szMsg = "你确定要挑战清明节BOSS吗?";
	local tbOpt = 
	{
		{"Xác nhận", self.CallNpc, self, me.nId, it.dwId},
		{"Để ta suy nghĩ thêm"}
	};
	
	Dialog:Say(szMsg, tbOpt);
end

-- 玩家nPlayerId使用nItemId招BOSS
function tbItem:CallNpc(nPlayerId, nItemId)
	local bOk, szMsg = tbQingMing2011:CanCallQingMingBoss(nPlayerId)
	if bOk == 0 then
		if szMsg then
			Dialog:Say(szMsg, {{"Ta hiểu rồi"}});
		end
		return;
	end
	
	local nGroupId, tbBoss = tbQingMing2011:GetARandomBoss();
	if not nGroupId then
		return;
	end
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		pPlayer.Msg("你使用的清明挑战令已经不存在了");
		return;
	end
	
	local nMapId, nPosX, nPosY = pPlayer.GetWorldPos();
	if not nMapId or not nPosX or not nPosY then
		return;
	end
	
	local pNpc = KNpc.Add2(tbBoss.nNpcId, tbBoss.nLevel, -1, nMapId, nPosX, nPosY, 0, 2);
	if not pNpc then
		return;
	end
	
	pNpc.SetLiveTime(tbQingMing2011.nBossLiveTime);
	
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp then
		return;
	end
	tbTemp.nCallerId = nPlayerId;
	tbTemp.nGroupId = nGroupId;
	tbTemp.szCallerName = pPlayer.szName;
	
	local szMsg = string.format("清明时节雨纷纷, %s接受了你的挑战", pNpc.szName);
	Dialog:SendBlackBoardMsgTeam(pPlayer, szMsg, 1);

	-- 删除清明挑战令
	if pItem.nCount > 1 then
		local nLeft = pItem.nCount - 1;
		pItem.SetCount(nLeft);
	else
		pItem.Delete(pPlayer);
	end

	return 1;
end
