--
-- FileName: youmingdeng.lua
-- Author: lgy&lqy
-- Time: 2012/3/22 11:30
-- Comment: 幽冥灯
--
Require("\\script\\event\\jieri\\201204_qingming\\qingming_def.lua");
local tbQingMing2012 = SpecialEvent.tbQingMing2012;
local tbItem = Item:GetClass("qingming_youmindeng_2012");

-- 使用
function tbItem:OnUse()
	do return end
	local szMsg = "  <color=yellow>一缕英魂一盏灯，万点幽光黯辰星。<color>\n\n 你可以直接使用幽冥灯来放灯祭祀，也可以消耗<color=yellow>精力、活力各300<color>，将1盏幽冥灯加工成为赎魂灯。在祭祀的时候，\n<color=blue>放飞赎魂灯可以获得比幽冥灯更多的奖励。<color>";
	local tbOpt = {
		{"加工成赎魂灯", self.ChooseNumber, self, me.nId, it.dwId},
		{"使用幽冥灯", self.UseThis, self, me.nId,it.dwId},
		{"Để ta suy nghĩ lại"},
	};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

--选择加工数量
function tbItem:ChooseNumber(nPlayerId, nItemId)
	local nNumber = tbQingMing2012:CheckMostNumber(me);
	Dialog:AskNumber("请输入加工个数：", nNumber, self.MakeShuHun, self, nPlayerId, nItemId, 0);
end

-- 加工赎魂灯
function tbItem:MakeShuHun(nPlayerId, nItemId, nSure, nCount)
	
	if nCount <= 0 then 
		return;
	end
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	if nSure == 0 then
		local szMsg = string.format("你确定使用<color=red>%d<color>点精力<color=red>%d<color>点活力将<color=yellow>%d<color>个幽冥灯合成<color=yellow>%d<color>个赎魂灯么?",
			nCount * tbQingMing2012.nCostMKP,
			nCount * tbQingMing2012.nCostGTP,
			nCount * tbQingMing2012.nNeededCount,
			nCount
			);
		local tbOpt =
		{
			{"我确定",self.MakeShuHun,self,nPlayerId,nItemId,1,nCount},
			{"还是算了"},
		};
		Dialog:Say(szMsg, tbOpt);
		return;
	end
	
	if nSure ~= 1 then 
		return;
	end
	
	local bOk, szErrorMsg = tbQingMing2012:CanProduceShuHunDeng(pPlayer, nCount);
	if bOk == 0 then
		if szErrorMsg then
			local szMsg = string.format("<color=red>%s<color>", szErrorMsg);
			Dialog:Say(szMsg, {"Ta hiểu rồi"});
		end
		return;
	end
	
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		pPlayer.Msg("你使用的幽冥灯不知道怎么的不见了。");
		return;
	end	
	
	-- 删道具
	
	local nRet = pPlayer.ConsumeItemInBags2(nCount, unpack(tbQingMing2012.nQingMingYouMinDengId));	
	if nRet ~= 0 then
		Dbg:WriteLog("清明节活动扣除道具失败。", pPlayer.szAccount, pPlayer.szName);
		return;
	end
	--扣精活
	pPlayer.ChangeCurMakePoint(-tbQingMing2012.nCostMKP*nCount);
	pPlayer.ChangeCurGatherPoint(-tbQingMing2012.nCostGTP*nCount);
	
	--加道具
	local tbAdd = tbQingMing2012.nQingMingShuHunDengId;
	pPlayer.AddStackItem(tbAdd[1], tbAdd[2], tbAdd[3], tbAdd[4], nil, nCount);
	StatLog:WriteStatLog("stat_info", "qingmingjie2012", "get_item", pPlayer.nId, nCount);
end

-- 使用幽冥灯
function tbItem:UseThis(nPlayerId, nItemId)
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		pPlayer.Msg("你使用的幽冥灯不知道怎么的不见了。");
		return;
	end
	
	local bOk, szErrorMsg = tbQingMing2012:CanUseShuHunDeng(pPlayer);
	if bOk == 0 then
		if szErrorMsg then
			Dialog:Say(szErrorMsg, {"Ta hiểu rồi"});
		end 
		return;
	end

	--完成祭祀
	tbQingMing2012:FinishJiSi(pPlayer, pItem, "YouMinDeng");
end
