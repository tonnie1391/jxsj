-- 文件名　：childrenday_gs.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-05-14 14:07:07
-- 功能    ：

SpecialEvent.tbChildrenDay2012 = SpecialEvent.tbChildrenDay2012 or {};
local tbChildrenDay2012 = SpecialEvent.tbChildrenDay2012;


--tbChildrenDay2012.tbAwardEx = {
--	{["szType"] = "item", 		["varValue"] = {18,1,1,7,1,1}},
--	{["szType"] = "bindmoney", 	["varValue"] = 5000},
--	{["szType"] = "money", 		["varValue"] = 500},
--	{["szType"] = "repute", 		["varValue"] = {2,2,10,"10点凤翔战场声望"}},
--	{["szType"] = "gatherpoint", 	["varValue"] = 100},
--	{["szType"] = "makepoint", 	["varValue"] = 100},
--}

tbChildrenDay2012.nMaxValue = 400000;	--每天

tbChildrenDay2012.tbFrameDay = {	{201112, 726, 7},{201203, 363, 6},{202010,311, 5}};
tbChildrenDay2012.tbXuanJingValue		= {100, 360, 1296,4665,16796,60466,217678,783641,2821109,10155995,36565762,131636744};	--玄晶价值量

tbChildrenDay2012.tbCardAward= {
	--需求道具数，白银牌子概率（10000），宠物概率（10000）,占的概率
	[1] = {1, 0, 0, 0.08},
	[2] = {2, 0, 0, 0.1},
	[3] = {3, 0, 0, 0.12},
	[4] = {5, 0, 0, 0.1},
	[5] = {6, 300, 0, 0.1},
	[6] = {8, 320, 0, 0.1},
	[7] = {10, 333, 0, 0.1},
	[8] = {30, 900, 2000, 0.1},
	[9] = {50, 1167, 3500, 0.1},
	[10] = {100, 2000, 5000, 0.1},
}

--计算单前服务器当天本轮的总价值量
function tbChildrenDay2012:ValueMax(nIndex)
	local nBack = 0;
	local nOpenDay = tonumber(os.date("%Y%m", tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME))));
	for _, tb in ipairs(self.tbFrameDay) do
		if nOpenDay < tb[1] then
			nBack = tb[2];
			break;
		end
	end
	local nBackMax = 3 * nBack * self.tbCardAward[nIndex][1] * 10;	--每轮根据投入返回总量
	if nIndex <= 3 then
		nBackMax = 0;
	end
	return  nBackMax + math.floor(self.nMaxValue *(nBack / 363) * self.tbCardAward[nIndex][4]);
end

function tbChildrenDay2012:ClearPlayer()
	if me.GetSkillState(self.nSkillId) > 0 then
		me.RemoveSkillState(self.nSkillId);
		Dialog:SendBlackBoardMsg(me, "葫芦娃成功帮你解除了咒语，下次可要小心那些坏蛋哦！");
		me.SetTask(self.TASKID_GROUP, self.TASKID_CHANGE_TIME, 0);
		me.SetTask(self.TASKID_GROUP, self.TASKID_CHANGE_TYPE, 0);
		return;
	end
	Dialog:Say("你...你根本没有被变身，你这个骗子！");
end

function tbChildrenDay2012:OnFirst()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nNowDate < tbChildrenDay2012.nStartDay or nNowDate > tbChildrenDay2012.nEndDay  then
		Dialog:Say("好像不在活动期间。");
		return;
	end
	local nCountDay = self:GetTodayCount();
	local nState = me.GetTask(self.TASKID_GROUP, self.TASKID_HULU_HANDON);
	local tbAwardInfo = self.tbPlayerAwardList[me.nId];
	if nCountDay < self.nMaxCount or (nState == 1 and nCountDay == self.nMaxCount and tbAwardInfo) then
		self:OnNextAward(nCountDay + 1);
	else
		me.Msg("您今天已经达上限了，明天再来砸葫芦吧。");
		me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", "您今天已经达上限了，明天再来砸葫芦吧。"});
	end
end

--随即声望奖励
function tbChildrenDay2012:RandomRepute(nIndex)
	--需要有概率的时候才做随即
	if not self.tbCardAward[nIndex] or not self.tbCardAward[nIndex][2] or self.tbCardAward[nIndex][2] <= 0 then
		return self.tbRepute[MathRandom(#self.tbRepute)];
	end
	local nOpenDay = tonumber(os.date("%Y%m", tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME))));
	for _, tb in ipairs(self.tbFrameDay) do
		if nOpenDay < tb[1] then
			if me.GetHonorLevel() < tb[3] then
				return self.tbRepute[MathRandom(#self.tbRepute)];
			end
			break;
		end
	end
	--最多获得5个
	local nGetCount = me.GetTask(self.TASKID_GROUP, self.TASKID_MAX_REPUTE_ITEM);
	if nGetCount >= self.nMaxReputeItem then
		return self.tbRepute[MathRandom(#self.tbRepute)];
	end
	local tbRandomItem = {};
	for _, tb in ipairs(self.tbRepute) do
		if me.GetReputeLevel(tb[1], tb[2]) == tb[5] and me.GetReputeValue(tb[1], tb[2]) <= tb[3] then
			table.insert(tbRandomItem, tb);
		end
	end
	--没有满足的情况
	if #tbRandomItem <= 0 then
		return self.tbRepute[MathRandom(#self.tbRepute)];
	end
	local nRate = MathRandom(10000);
	if nRate > self.tbCardAward[nIndex][2] then
		return tbRandomItem[MathRandom(#tbRandomItem)];
	end
	return tbRandomItem[MathRandom(#tbRandomItem)], 1;
end

--随即特殊道具
function tbChildrenDay2012:RandomSpeItem(nIndex)
	if not self.tbCardAward[nIndex] or not self.tbCardAward[nIndex][3] or self.tbCardAward[nIndex][3] <= 0 then
		return nil;
	end
	local nGetCount = me.GetTask(self.TASKID_GROUP, self.TASKID_MAX_SPE_ITEM);
	if nGetCount >= self.nMaxSpeItem then
		return nil;
	end
	local nRate = MathRandom(10000);
	if nRate > self.tbCardAward[nIndex][3] then
		return nil
	end
	return 1;
end

--计算奖励
function tbChildrenDay2012:CaleAward(nIndex)
	local tbAward, i = self:CaleBindValue(nIndex);
	local tbRepute, bReputeItem = self:RandomRepute(nIndex);
	local nFlagSpeItem = self:RandomSpeItem(nIndex);
	if bReputeItem then
		tbAward[i] = self:ChangAward(tbRepute);
	elseif nFlagSpeItem then
		tbAward[i] = self:ChangAward(nFlagSpeItem);
	end
	local nRandReputeIndex = nil;
	if nIndex >=  4 and not bReputeItem then
		nRandReputeIndex = self:RandomView(i);
		tbAward[nRandReputeIndex] = self:ChangAward(tbRepute);
	end
	if nIndex >=  7 and not nFlagSpeItem then
		local nRandIndex = self:RandomView(i, nRandReputeIndex);
		tbAward[nRandIndex] = self:ChangAward(1);
	end
	self.tbPlayerAwardList[me.nId] = {tbAward, i, nIndex};
	return tbAward;
end

--6个中随即一个不同于index的值
function tbChildrenDay2012:RandomView(nIndex, nIndex2)
	local nCount = 1;
	local tb = {1,2,3,4,5,6};
	--保证第二个小于第一个
	if nIndex and nIndex2 and nIndex< nIndex2 then
		local n = nIndex2;
		nIndex2 = nIndex;
		nIndex = n;
	end
	if nIndex == nIndex2 then
		nIndex2 = nil;
	end
	local tbRevome = {};
	for i, num in ipairs(tb) do
		if nIndex == num then
			table.insert(tbRevome, 1, i);
		end
		if nIndex2 == num then
			table.insert(tbRevome, 1, i);
		end
	end
	for _, n in ipairs(tbRevome) do
		table.remove(tb, n);
	end
	return tb[MathRandom(#tb)];
end

function tbChildrenDay2012:ChangAward(varValue)
	if type(varValue) == "table" then
		return {["szType"] = "item", 		["varValue"] = varValue[4]};
	else
		return {["szType"] = "item", 		["varValue"] = {18,1,1730,1,1,1}};
	end
end

function tbChildrenDay2012:CaleBindValue(nIndex)
	local nMaxValue = self:ValueMax(nIndex);
	local nBindMoney1 = math.floor(nMaxValue * 0.8 / 100) * 100;
	local nBindMoney2 = math.floor(nMaxValue * 1.2 / 100) * 100;
	local nBindCoin1 = math.floor(nMaxValue * 0.75 / 1000) * 10;
	local nBindCoin2 = math.floor(nMaxValue * 1.25 / 1000) * 10;
	local nXuanJing = 0;
	local n = math.floor(10000 * 1/6);
	local tbRandom = {n, 2*n, 3*n, 4*n}

	for i, nValue in ipairs(self.tbXuanJingValue) do
		if nMaxValue >= nValue and nMaxValue < self.tbXuanJingValue[i + 1] then
			local nRate = math.floor((self.tbXuanJingValue[i + 1] - nMaxValue) / (self.tbXuanJingValue[i + 1] - self.tbXuanJingValue[i]) * 100);
			table.insert(tbRandom, tbRandom[4] + math.floor(100 * 1/3 * nRate));
			table.insert(tbRandom, tbRandom[5] + math.floor(100 * 1/3 * (100 - nRate)));
			nXuanJing = i;
			break;
		end
	end
	local tbAward = {
			{["szType"] = "bindmoney", 	["varValue"] = nBindMoney1},
			{["szType"] = "bindmoney", 	["varValue"] = nBindMoney2},
			{["szType"] = "bindcoin", 		["varValue"] = nBindCoin1},
			{["szType"] = "bindcoin", 		["varValue"] = nBindCoin2},
			{["szType"] = "item", 		["varValue"] = {18,1,114,nXuanJing,1,1}},
			{["szType"] = "item", 		["varValue"] = {18,1,114,nXuanJing + 1,1,1}},
		}
	local nRate= MathRandom(tbRandom[6]);
	for i, nCount in ipairs(tbRandom) do
		if nCount >= nRate then
			return tbAward, i;
		end
	end
end

--计算需要花费的物品数量
function tbChildrenDay2012:CaleCostItem(nIndex)
	if not self.tbCardAward[nIndex] then
		return;
	end
	return {{self.tbCostItem[1], self.tbCostItem[2], self.tbCostItem[3], self.tbCostItem[4], self.tbCardAward[nIndex][1]}};
end

--上交道具的回调
function tbChildrenDay2012:HandUp(nCount)
	Player:CheckTask(self.TASKID_GROUP, self.TASKID_HULU_DATE, "%Y%m%d", self.TASKID_HULU_COUNT, self.nMaxCount);
	me.SetTask(self.TASKID_GROUP, self.TASKID_HULU_COUNT, me.GetTask(self.TASKID_GROUP, self.TASKID_HULU_COUNT) + 1);
	me.SetTask(self.TASKID_GROUP, self.TASKID_HULU_HANDON, 1);
	StatLog:WriteStatLog("stat_info", "kid_2012", "kick_box", me.nId, nCount);
end

--打开一张卡牌
function tbChildrenDay2012:OpenOneCard(tbAward, bPay)
	me.SetTask(self.TASKID_GROUP, self.TASKID_HULU_HANDON, 0);
end

function tbChildrenDay2012:GetTodayCount()
	Player:CheckTask(self.TASKID_GROUP, self.TASKID_HULU_DATE, "%Y%m%d", self.TASKID_HULU_COUNT, self.nMaxCount);
	return me.GetTask(self.TASKID_GROUP, self.TASKID_HULU_COUNT);
end

--根据传过来得table找出已经选定的奖励项
function tbChildrenDay2012:GetAward(tbAward)
	if not self.tbPlayerAwardList[me.nId]  then
		print("奖励有误1！！！！！", me.szName, me.szAccount);
		return;
	end
	local tbSelect = self.tbPlayerAwardList[me.nId][1][self.tbPlayerAwardList[me.nId][2]];
	for i, tbInfor in ipairs(tbAward) do
		if tbInfor.szType == tbSelect.szType then
			if type(tbInfor.varValue) == "number" and tbInfor.varValue == tbSelect.varValue then
				StatLog:WriteStatLog("stat_info", "kid_2012", "award", me.nId, tbInfor.szType, tbInfor.varValue);
				if tbInfor.szType == "bindmoney" and tbInfor.varValue >= 100000 then
					Player:SendMsgToKinOrTong(me, "在[葫芦兄弟送大礼]活动中获得了"..tbInfor.varValue.."绑银<color>。", 1);
					me.SendMsgToFriend("Hảo hữu ["..me.szName.."]在[葫芦兄弟送大礼]活动中获得了<color=green>"..tbInfor.varValue.."绑银<color>。");	
				end
				if tbInfor.szType == "bindcoin" and tbInfor.varValue >= 2000 then
					Player:SendMsgToKinOrTong(me, "在[葫芦兄弟送大礼]活动中获得了<color=green>"..tbInfor.varValue.."绑金<color>。", 1);
					me.SendMsgToFriend("Hảo hữu ["..me.szName.."]在[葫芦兄弟送大礼]活动中获得了<color=green>"..tbInfor.varValue.."绑金<color>。");	
				end
				return i;
			elseif type(tbInfor.varValue) == "table" and tbInfor.varValue[1] == tbSelect.varValue[1]
				and tbInfor.varValue[2] == tbSelect.varValue[2] and tbInfor.varValue[3] == tbSelect.varValue[3]
				and tbInfor.varValue[4] == tbSelect.varValue[4] and tbInfor.varValue[5] == tbSelect.varValue[5]
				and tbInfor.varValue[6] == tbSelect.varValue[6]  then
				local szGDP = string.format("%s,%s,%s", unpack(tbInfor.varValue));
				--获得的是声望牌子
				if szGDP == "18,1,1251" then
					me.SetTask(self.TASKID_GROUP, self.TASKID_MAX_REPUTE_ITEM, me.GetTask(self.TASKID_GROUP, self.TASKID_MAX_REPUTE_ITEM) + 1);
					Player:SendMsgToKinOrTong(me, "在[葫芦兄弟送大礼]活动中获得了<color=green>"..self.tbRepute[tbInfor.varValue[4]][6] or "小游龙阁声望令".."<color>。", 1);
					me.SendMsgToFriend("Hảo hữu ["..me.szName.."]在[葫芦兄弟送大礼]活动中获得了<color=green>"..self.tbRepute[tbInfor.varValue[4]][6] or "小游龙阁声望令".."<color>。");	
					KDialog.NewsMsg(1,3,"恭喜["..me.szName.."]在[葫芦兄弟送大礼]活动中获得了<color=green>"..self.tbRepute[tbInfor.varValue[4]][6] or "小游龙阁声望令".."<color>。");
				end
				--获得的是特殊道具
				if szGDP == "18,1,1730" then
					me.SetTask(self.TASKID_GROUP, self.TASKID_MAX_SPE_ITEM, me.GetTask(self.TASKID_GROUP, self.TASKID_MAX_SPE_ITEM) + 1);
					Player:SendMsgToKinOrTong(me, "用在[葫芦兄弟送大礼]活动中获得了<color=green>【宠物宝箱】·葫芦娃<color>。", 1);
					me.SendMsgToFriend("Hảo hữu ["..me.szName.."]在[葫芦兄弟送大礼]活动中获得了<color=green>【宠物宝箱】·葫芦娃<color>。");	
					KDialog.NewsMsg(1,3,"恭喜["..me.szName.."]在[葫芦兄弟送大礼]活动中获得了<color=green>【宠物宝箱】·葫芦娃<color>。");
				end
				--玄晶
				if szGDP == "18,1,114" then
					if tbSelect.varValue[4] >= 7 then
						Player:SendMsgToKinOrTong(me, "在[葫芦兄弟送大礼]活动中获得了<color=green>"..tbSelect.varValue[4].."级玄晶<color>。", 1);
						me.SendMsgToFriend("Hảo hữu ["..me.szName.."]在[葫芦兄弟送大礼]活动中获得了<color=green>"..tbSelect.varValue[4].."级玄晶<color>。");	
					end
				end
				local szItem = string.format("%s_%s_%s_%s", unpack(tbInfor.varValue));
				StatLog:WriteStatLog("stat_info", "kid_2012", "award", me.nId, szItem, 1);
				return i;
			end
		end
	end
	
	print("奖励有误！！！！！", me.szName, me.szAccount);
	return;
end

function tbChildrenDay2012:Continue()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	if nNowDate < tbChildrenDay2012.nStartDay or nNowDate > tbChildrenDay2012.nEndDay  then
		Dialog:Say("好像不在活动期间。");
		return;
	end
	local nCountDay = self:GetTodayCount();
	local nState = me.GetTask(self.TASKID_GROUP, self.TASKID_HULU_HANDON);
	local tbAwardInfo = self.tbPlayerAwardList[me.nId];
	if nCountDay < self.nMaxCount or (nState == 1 and nCountDay == self.nMaxCount and tbAwardInfo) then
		self:OnNextAward(nCountDay + 1);
	else
		me.Msg("您今天已经达上限了，明天再来砸葫芦吧。");
		me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", "您今天已经达上限了，明天再来砸葫芦吧。"});
	end
end

--开始条件--不足道具的时候弹出购买葫芦的窗口
function tbChildrenDay2012:StarCondition()
	local nCount = self:GetTodayCount();
	if nCount >= self.nMaxCount then
		me.Msg("您今天已经达上限了，明天再来砸葫芦吧。");
		me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", "您今天已经达上限了，明天再来砸葫芦吧。"});
		return 0;
	end
	local tbCostItem = self:CaleCostItem(nCount+1) or {};
	local tbFind = me.FindItemInBags(tbCostItem[1][1], tbCostItem[1][2], tbCostItem[1][3], tbCostItem[1][4]);
	local nCount = 0;
	for i, tbItem in ipairs(tbFind) do
		nCount = nCount + tbItem.pItem.nCount;
	end
	if nCount < tbCostItem[1][5] then
		me.CallClientScript({"UiManager:CloseWindow", "UI_CARDAWARD", });
		Dialog:Say("本轮需要<color=yellow>小葫芦"..tbCostItem[1][5].."个<color>，您的葫芦数量不足，是否在奇珍阁购买？\n\n<color=green>小葫芦：<color>    <color=yellow>10金币 / 个<color>\n<color=green>小葫芦·箱：<color><color=yellow>1000金币 / 个（包含小葫芦100个）<color>",{{"购买小葫芦", self.BuyItem, self, 1},{"购买小葫芦·箱", self.BuyItem, self, 2},{"Để ta suy nghĩ thêm"}});
		return 0;
	end
end

function tbChildrenDay2012:BuyItem(nIndex, nFlag, nNum)
	if not nFlag then
		Dialog:AskNumber("请输入您要购买物品的数量", 10, self.BuyItem, self, nIndex,1);
		return;
	end
	local tbBuyItem = {[1] = {614, 10}, [2] = {615, 1000}};
	if nIndex <= 0 or nIndex > 2 then
		print("传递的参数有问题。");
		return;
	end
	if nNum <= 0 then
		Dialog:Say("您输入的数目不正确。");
		return;
	end
	if me.nCoin < tbBuyItem[nIndex][2] * nNum then
		Dialog:Say("您的金币不足！", {{"我知道啦"}});
		return;
	end
	if me.CountFreeBagCell() < nNum then
		Dialog:Say("Hành trang không đủ chỗ trống.", {{"我知道啦"}});
		return;
	end
	me.ApplyAutoBuyAndUse(tbBuyItem[nIndex][1], nNum, 0);
	return;
end

--进行下一轮奖励
function tbChildrenDay2012:OnNextAward(nNextCount)
	local tbAwardInfo = self.tbPlayerAwardList[me.nId];
	local tbAward = nil;
	local nState = me.GetTask(self.TASKID_GROUP, self.TASKID_HULU_HANDON);
	if nState == 1 and tbAwardInfo then
		nNextCount = tbAwardInfo[3];
		tbAward = tbAwardInfo[1];
	else
		--做一层保护，防止出现传进来的是10次以上的
		if nNextCount > 10 then
			me.Msg("您今天已经达上限了，明天再来砸葫芦吧。");
			me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", "您今天已经达上限了，明天再来砸葫芦吧。"});
			return;
		end
		tbAward = self:CaleAward(nNextCount);
		if nState == 1 then	--如果没有内存奖励（重启可能发生），就放弃掉
			me.SetTask(self.TASKID_GROUP, self.TASKID_HULU_HANDON, 0);
			nState = 0;
		end
	end
	local tbCostItem = self:CaleCostItem(nNextCount);
	
	if not tbCostItem then
		me.Msg("活动异常，请联系Gm！！！");
		return;
	end

	local tbMsg = {};
	for _, szMsg in ipairs(self.tbMsgFerCount) do
		table.insert(tbMsg, string.format(szMsg, nNextCount, self.nMaxCount - nNextCount, tbCostItem[1][5]));
	end
	
	local tbCallBack = {
		["tbHandUp"] = {self.HandUp, self}, 
		["tbOpenOneCard"] = {self.OpenOneCard, self},
		["tbGetAward"] = {self.GetAward, self},
		["tbContinue"] = {self.Continue, self},
		["tbStarCondition"] = {self.StarCondition, self},};
	CardAward:SendAskAward(self.szUITitle, tbMsg, tbAward, tbCostItem, nil, tbCallBack, 0, 1 + nState);
end


