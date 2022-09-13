--
-- FileName: qingmingxuanxiang.lua
-- Author: zhangbin1
-- Time: 2011/3/22 11:29
-- Comment: 清明玄香
--
SpecialEvent.tbQingMing2011 =  SpecialEvent.tbQingMing2011 or {};
local tbQingMing2011 = SpecialEvent.tbQingMing2011;

local tbItem = Item:GetClass("qingmingxuanxiang_2011");

function tbItem:OnUse()
	local szMsg = tbQingMing2011:GetProduceNotifyMsg(me);
	local tbOpt = 
	{
		{"Xác nhận", self.Produce, self, me.nId, it.dwId},
		{"Để ta suy nghĩ thêm"}
	};
	
	Dialog:Say(szMsg, tbOpt);
end

-- 加工清明挑战令
function tbItem:Produce(nPlayerId, nItemId, bFinished)
	bFinished =  bFinished or 0;

	local bOk, szErrorMsg = tbQingMing2011:CanProduceQingMingTiaoZhanLing(nPlayerId);
	if bOk == 0 then
		if szErrorMsg then
			local szInfo = tbQingMing2011:GetProduceConditionDescription();
			local szMsg = string.format("%s\n\n<color=red>%s<color>", szInfo, szErrorMsg);
			Dialog:Say(szMsg, {"Ta hiểu rồi"});
		end
		return;
	end

	if bFinished == 0 then
		local tbCallBack = {self.Produce, self, nPlayerId, nItemId, 1};
		GeneralProcess:StartProcess(tbQingMing2011.szProduceMsg, tbQingMing2011.nProcessDuration, tbCallBack, nil, tbQingMing2011.tbBreakEvent);
		return;
	end
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		pPlayer.Msg("你使用的清明玄香不知道怎么的不见了。");
		return;
	end	

	-- 删道具
	if pItem.nCount > tbQingMing2011.nNeededCount then
		local nLeft = pItem.nCount - tbQingMing2011.nNeededCount;
		pItem.SetCount(nLeft);
	else
		local nCountGap = tbQingMing2011.nNeededCount - pItem.nCount;
		pItem.Delete(pPlayer);
		if nCountGap > 0 then
			pPlayer.ConsumeItemInBags(nCountGap, unpack(tbQingMing2011.nQingMingXuanXiangId));
		end
	end

	--扣精活
	pPlayer.ChangeCurMakePoint(-tbQingMing2011.nCostMKP);
	pPlayer.ChangeCurGatherPoint(-tbQingMing2011.nCostGTP);
	
	--加道具
	local pAddedItem = pPlayer.AddItem(unpack(tbQingMing2011.nQingMingTiaoZhanLing));
	if pAddedItem then
		pAddedItem.SetTimeOut(0, (GetTime() + tbQingMing2011.nQingMingZhaoHuanLingLiveTime));
		pAddedItem.Sync();
		local nProducedCount = pPlayer.GetTask(tbQingMing2011.TASKGID, tbQingMing2011.TASK_PRODUCED_COUNT);
		pPlayer.SetTask(tbQingMing2011.TASKGID, tbQingMing2011.TASK_PRODUCED_COUNT, nProducedCount + 1);
		-- 记Log
		StatLog:WriteStatLog("stat_info", "qingmingjie2011", "cards_get", nPlayerId, 1);
	end
	return;
end
