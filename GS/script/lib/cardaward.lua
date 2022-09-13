-- 文件名　：cardaward.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-05-15 11:38:40
-- 功能    ：通用卡牌奖励
-- 说明：这里的卡牌机制不保留现场，如果需要保留现场需要功能自定义，几个回调事件，进行逻辑处理。

if (not MODULE_GAMESERVER) then
	return;
end

CardAward.nCardCount = 6;				--界面需求的开牌数目
CardAward.tbBindMoney = {18,1,1729,1};		--绑银代替道具

CardAward.TASK_GROUP		= 2192;
CardAward.TASK_BINDMONEY	= 43;	--邮件发绑银变量


--打开奖励界面
--szTitle		奖励界面名字
--tbMsg		奖励面板说明文字（每一轮说明文字，如果不足数量，使用最后一条字符串作为说明文字）
--tbAwards 	奖励选项(需要六个奖励，不足请补充，多余六个，请平摊)	奖励道具如需要时间限制，请自己写Item:InitGenInfo
--{{G,D,P,L,绑定(0 or 1),数量,有效期(0,nil or 1),权重}}
--tbItem		摇奖需求的道具		{{G,D,P,L},{G,D,P,L}}前面表示先扣
--tbPayItem	付费开牌道具			{{G,D,P,L},{G,D,P,L}}前面表示先扣
--tbCallBack	一轮完成回调
	--回调分为：tbHandUp 		上交道具回调
	--		     tbOpenOneCard 	获得一个卡片回调
	--                    tbEnd			一轮选牌结束回调
	--		     tbGetAward		获奖规则自定义回调，需要有返回值（奖励调空靠它了）
	--		     tbContinue		完成一轮让界面回调继续（界面上会显示继续下一轮，否则没有该回调界面显示结束）
	--		     tbStarCondition 	开奖额外条件（0表示不通过，不能打开本轮奖励）
	--                    tbPayCondition 	付费额外条件（0表示不通过，不能打开本次额外奖励）
	--                    tbBackEnd		主动（客户端主动操作）结束掉一轮活动（多次打开抽奖界面的活动用）回调
--nPerPayCount	每轮可以付费的次数(不填表示最大卡牌数：5)
--nState 			当前状态（1、才开始（需要交道具开始）2、已经交道具正在选）
--bStartCondition	是否有需要判断开启条件（背包，绑银数量，银两数量）nil表示检查反之不检查
--bBack			是否需求离开按钮及主动离开回调（nil表示不需求）
function CardAward:SendAskAward(szTitle, tbMsg, tbAwards, tbItem, tbPayItem, tbCallBack, nPerPayCount, nState, bStartCondition, bBack)
	if not tbAwards or #tbAwards ~= self.nCardCount then
		print("[错误调用]奖励项不足6个");
		return;
	end
	
	local tbPlayerAward = self:GetMyAward();
	tbPlayerAward.tbAwards 	= {};
	--copy底下一层，因为要改数据，这样保证源数据不会被改
	for i, tb in ipairs(tbAwards) do
		tbPlayerAward.tbAwards[i] = {};
		for szKey, varValue in pairs(tb) do
			tbPlayerAward.tbAwards[i][szKey] = varValue;
		end
	end
	tbPlayerAward.szTitle 	= szTitle;
	tbPlayerAward.tbMsg 	= tbMsg;
	tbPlayerAward.tbItem 	= tbItem;
	tbPlayerAward.tbPayItem 	= tbPayItem;
	tbPlayerAward.tbCallBack 	= tbCallBack;
	tbPlayerAward.nPerPayCount 	= math.min(nPerPayCount or self.nCardCount - 1, self.nCardCount - 1);
	tbPlayerAward.nState 		= nState;
	tbPlayerAward.bStartCondition 	= bStartCondition;
	tbPlayerAward.bBack 			= bBack;
	me.CallClientScript({"CardAward:StartCardAward", tbAwards, szTitle, tbMsg, tbItem, tbPayItem, tbPlayerAward.nPerPayCount, nState, bStartCondition, bBack});
end

function CardAward:GetMyAward()
	local tbPlayerData		= me.GetTempTable("CardAward");
	local tbPlayerAward		= tbPlayerData.tbAward;
	if (not tbPlayerAward) then
		tbPlayerAward	= {
		};
		tbPlayerData.tbAward	= tbPlayerAward;
	end;
	return tbPlayerAward;
end;

--检查是否可以开始摇奖
function CardAward:CheckCanStart()
	local tbPlayerAward = self:GetMyAward();
	if tbPlayerAward.nState ~= 1 then
		me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", "还不可以开始"});
		me.Msg("还不可以开始");
		return 0;
	end
	if tbPlayerAward.tbCallBack and tbPlayerAward.tbCallBack.tbStarCondition then
 		if type(tbPlayerAward.tbCallBack.tbStarCondition[1]) ~= "function" then
 			print("回调函数不正确！！！")
 			return;
 		end
		local nRet = tbPlayerAward.tbCallBack.tbStarCondition[1](tbPlayerAward.tbCallBack.tbStarCondition[2]);
		if nRet == 0 then
			return 0;
		end
 	end
	--开奖道具需求
	local bItem = 0;
	if tbPlayerAward.tbItem then
		for _, tb in ipairs(tbPlayerAward.tbItem) do
			local tbFind = me.FindItemInBags(tb[1], tb[2], tb[3], tb[4]);
			local nCount = 0;
			for i, tbItem in ipairs(tbFind) do
				nCount = nCount + tbItem.pItem.nCount;
			end
			if nCount >= tb[5] then
				bItem = 1;
				break;
			end
		end
	else
		bItem = 1;
	end
	if bItem == 0 then
		me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", "开始本轮翻牌的道具数量不足"});
		me.Msg("开始本轮翻牌的道具数量不足");
		return 0;
	end
	if not tbPlayerAward.bStartCondition then
		--开奖背包
		local nMaxNeedBag = 0;
		local nMaxBindMoney = 0;
		local nMaxMoney = 0;
		for i, tbInfor in ipairs(tbPlayerAward.tbAwards) do
			if tbInfor.szType == "item" then
				local nNeedBag = KItem.GetNeedFreeBag(tbInfor.varValue[1], tbInfor.varValue[2], tbInfor.varValue[3], tbInfor.varValue[4], {bTimeOut=tbInfor.varValue[7]}, tbInfor.varValue[6]);
				if nMaxNeedBag < nNeedBag then
					nMaxNeedBag = nNeedBag;
				end
			end
			if tbInfor.szType == "bindmoney" then
				if nMaxBindMoney < tbInfor.varValue then
					nMaxBindMoney = tbInfor.varValue;
				end
			end
			if tbInfor.szType == "money" then
				if nMaxMoney < tbInfor.varValue then
					nMaxMoney = tbInfor.varValue;
				end
			end
		end
		if me.CountFreeBagCell() < nMaxNeedBag then
			me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", string.format("Hành trang không đủ chỗ trống %s ô.", nMaxNeedBag)});
			me.Msg(string.format("Hành trang không đủ chỗ trống%s ô.", nMaxNeedBag));
			return;
		end
		if me.GetBindMoney() + nMaxBindMoney > me.GetMaxCarryMoney() then
			me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", "对不起，您身上的绑定银两将达上限。"});
			me.Msg("对不起，您身上的绑定银两将达上限。");
			return 0;
		end
		if me.nCashMoney + nMaxMoney > me.GetMaxCarryMoney() then
			me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", "对不起，您身上的银两将达上限。"});
			me.Msg("对不起，您身上的银两将达上限。");
			return 0;
		end
	end
	--开奖绑银
	local nRet = self:HandUpItem();
	return nRet;
end

--可以是多种道具，优先扣除前一种道具
function CardAward:HandUpItem()
	local tbPlayerAward = self:GetMyAward();
	if not tbPlayerAward.tbItem then
		return -1;
	end
	for _, tb in ipairs(tbPlayerAward.tbItem) do
		local nRet = me.ConsumeItemInBags2(tb[5], tb[1], tb[2], tb[3], tb[4]);
		if nRet == 0 then
			return tb[5];
		end
	end
	return 0;
end

--检查是否可以付费打开一张卡牌
function CardAward:CheckOpenCard(nIndex)
	local tbPlayerAward = self:GetMyAward();
	if tbPlayerAward.nState ~= 2 then
		me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", "还不可以翻开任何一张牌"});
		me.Msg("还不可以翻开任何一张牌");
		return 0;
	end
	if not tbPlayerAward.tbPayItem or tbPlayerAward.nPerPayCount <= 0 then
		me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", "不能再翻更多的牌"});
		me.Msg("不能再翻更多的牌");
		return 0;
	end
	
	if not tbPlayerAward.tbAwards[nIndex] then
		return 0;
	end
	if tbPlayerAward.tbAwards[nIndex].bSelected then
		me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", "该张卡牌已经被选过了，请重新选一张"});
		me.Msg("该张卡牌已经被选过了，请重新选一张。");
		return 0;
	end
	
	if tbPlayerAward.tbCallBack and tbPlayerAward.tbCallBack.tbPayCondition then
 		if type(tbPlayerAward.tbCallBack.tbPayCondition[1]) ~= "function" then
 			print("回调函数不正确！！！")
 			return;
 		end
		local nRet = tbPlayerAward.tbCallBack.tbPayCondition[1](tbPlayerAward.tbCallBack.tbPayCondition[2]);
		if nRet == 0 then
			return 0;
		end
 	end
 	
	local bItem = 0;
	if tbPlayerAward.tbPayItem then
		for i, tb in ipairs(tbPlayerAward.tbPayItem) do
			local tbFind = me.FindItemInBags(tb[1], tb[2], tb[3], tb[4]);
			if #tbFind >= tb[5] then
				bItem = 1;
			end
		end
	else
		bItem = 1;
	end
	if bItem == 0 then
		me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", "没有可以继续翻牌的道具了"});
		me.Msg("没有可以继续翻牌的道具了。");
		return 0;
	end
	--扣除付费道具
	if tbPlayerAward.tbPayItem then
		for i, tb in ipairs(tbPlayerAward.tbPayItem) do
			local nRet = me.ConsumeItemInBags2(tb[5], tb[1], tb[2], tb[3], tb[4]);
			if nRet == 0 then
				return 1;
			end
		end
	else
		return 1;
	end
	return 0;
end

--开始一轮摇奖，需要扣除必要的道具，回调调用程序，告诉已经开始了
function CardAward:OnStart()
	local nCount = self:CheckCanStart();
	if nCount == 0 then
		return 0;
	end
	local tbPlayerAward = self:GetMyAward();
 	if tbPlayerAward.tbCallBack and tbPlayerAward.tbCallBack.tbHandUp then
 		Lib:CallBack({tbPlayerAward.tbCallBack.tbHandUp[1], tbPlayerAward.tbCallBack.tbHandUp[2], nCount});
 	end
 	tbPlayerAward.nState = 2;
 	me.CallClientScript({"CardAward:OnStart_C2"});
end

--付费打开一个奖励（需要判断条件的）
function CardAward:OpenOneCard(nIndex)
	if self:CheckOpenCard(nIndex) ~= 1 then
		return 0;
	end
	local tbPlayerAward = self:GetMyAward();
	local nCurIndex = nil;
	--这里可以做回调处理
	if tbPlayerAward.tbCallBack and tbPlayerAward.tbCallBack.tbGetAward then
		if type(tbPlayerAward.tbCallBack.tbGetAward[1]) ~= "function" then
 			print("回调函数不正确！！！")
 			return;
 		end
		nCurIndex = tbPlayerAward.tbCallBack.tbGetAward[1](tbPlayerAward.tbCallBack.tbGetAward[2], tbPlayerAward.tbAwards);
	end
	if not nCurIndex then
	 	nCurIndex = self:MathRandom(tbPlayerAward.tbAwards);
	 end
 	local tbAwardSelect = tbPlayerAward.tbAwards[nCurIndex];
 	tbPlayerAward.tbAwards[nCurIndex] = tbPlayerAward.tbAwards[nIndex];
 	tbPlayerAward.tbAwards[nIndex] = tbAwardSelect;
 	tbPlayerAward.tbAwards[nIndex].bSelected = nIndex;		--记录付费开启的卡牌顺序（作为保留现场用）
 	self:GiveAward(tbPlayerAward.tbAwards[nIndex]);
 	tbPlayerAward.nPerPayCount = tbPlayerAward.nPerPayCount - 1;
	
 	if tbPlayerAward.tbCallBack and tbPlayerAward.tbCallBack.tbOpenOneCard then
 		Lib:CallBack({tbPlayerAward.tbCallBack.tbOpenOneCard[1], tbPlayerAward.tbCallBack.tbOpenOneCard[2], tbAwardSelect, 1});
 	end
 	self:OnGoNext(nIndex, 1);
end

--选择一个没有选过的随即
function CardAward:MathRandom(tbAwards)
	local tbEnableSelect 		= {};	--没有选择掉的奖励的序列表
	local tbSelected 		= {};
	local nRandomTotal 	= 0;
	local tbRate 			= {};	--修正概率
	for i, tbInfo in ipairs(tbAwards) do
		if not tbInfo.bSelected then
			table.insert(tbEnableSelect, i);
		end
		nRandomTotal = nRandomTotal + tbInfo.nRate or 0;
		table.insert(tbRate, nRandomTotal);
	end
	--都只剩一个了就没必要这么搞了
	if #tbEnableSelect == 1 then
		return tbEnableSelect[1];
	end
	if nRandomTotal <= 0 then
		return tbEnableSelect[MathRandom(#tbEnableSelect)];	--真正的Index
	else
		local nRate = MathRandom(nRandomTotal);
		for i, nRateEx in ipairs(tbRate) do
			if nRate <= nRateEx then
				return i;
			end
		end
	end
end

--获得一轮奖励（已经交过道具了）
function CardAward:GetRoundAward(nIndex)
	local tbPlayerAward = self:GetMyAward();
	if self:CheckRoundAward() == 0 then
		return;
	end
 	local nCurIndex = nil;
 	if tbPlayerAward.tbCallBack and tbPlayerAward.tbCallBack.tbGetAward then
 		if type(tbPlayerAward.tbCallBack.tbGetAward[1]) ~= "function" then
 			print("回调函数不正确！！！")
 			return;
 		end
		nCurIndex = tbPlayerAward.tbCallBack.tbGetAward[1](tbPlayerAward.tbCallBack.tbGetAward[2], tbPlayerAward.tbAwards);
	end
	if not nCurIndex then
	 	nCurIndex = self:MathRandom(tbPlayerAward.tbAwards);
	 end
 	local tbAwardSelect = tbPlayerAward.tbAwards[nCurIndex];
 	tbPlayerAward.tbAwards[nCurIndex] = tbPlayerAward.tbAwards[nIndex];
 	tbPlayerAward.tbAwards[nIndex] = tbAwardSelect;
 	tbPlayerAward.tbAwards[nIndex].bSelected = nIndex;
 	self:GiveAward(tbAwardSelect);
 	if tbPlayerAward.tbCallBack and tbPlayerAward.tbCallBack.tbOpenOneCard then
 		Lib:CallBack({tbPlayerAward.tbCallBack.tbOpenOneCard[1], tbPlayerAward.tbCallBack.tbOpenOneCard[2], tbAwardSelect});
 	end
 	self:OnGoNext(nIndex);
end

function CardAward:CheckRoundAward()
	local tbPlayerAward = self:GetMyAward();
	if tbPlayerAward.nState ~= 2 then
		me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", "还不可以翻开任何一张牌"});
		me.Msg("还不可以翻开任何一张牌");
		return 0;
	end
	for i, tbInfor in ipairs(tbPlayerAward.tbAwards) do
		if tbInfor.bSelected then
			me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", "已经翻开一张牌了"});
			me.Msg("已经翻开一张牌了");
			return 0;
		end
	end
	return 1;
end

function CardAward:OnGoNext(nIndex, bPay)
	local tbPlayerAward = self:GetMyAward();
	if not tbPlayerAward.nPerPayCount or tbPlayerAward.nPerPayCount <= 0 then
 		self:GoEnd();
 	else
 		self:GoNextPay(nIndex, bPay);
 	end
end

--开始一轮付费抽奖
function CardAward:GoNextPay(nIndex, bPay)
	local tbPlayerAward = self:GetMyAward();
	me.CallClientScript({"CardAward:GoNextPay_C", tbPlayerAward.tbAwards[nIndex], nIndex, bPay});
end

--一轮摇奖完成，回调给调用的程序 ，如果没有就关闭窗口
function CardAward:GoEnd()
 	local tbPlayerAward = self:GetMyAward();
 	tbPlayerAward.nState = 3;
 	if tbPlayerAward.tbCallBack and tbPlayerAward.tbCallBack.tbEnd then
 		Lib:CallBack({unpack(tbPlayerAward.tbCallBack.tbEnd)});
 	end
 	local bContinue = 0;
 	if tbPlayerAward.tbCallBack and tbPlayerAward.tbCallBack.tbContinue then
 		bContinue = 1;
 	end
 	--展示奖励并关闭卡牌界面
 	me.CallClientScript({"CardAward:OnEnd_C", tbPlayerAward.tbAwards, bContinue});
end

function CardAward:OnBackEnd()
	local tbPlayerAward = self:GetMyAward();
	if not tbPlayerAward.bBack then
		return 0;
	end
	if tbPlayerAward.tbCallBack and tbPlayerAward.tbCallBack.tbBackEnd then
 		Lib:CallBack({unpack(tbPlayerAward.tbCallBack.tbBackEnd)});
 	end
end

--界面继续抽奖回调
function CardAward:OnContinue()
	local tbPlayerAward = self:GetMyAward();
	if tbPlayerAward.nState ~= 3 then
		me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", "还没结束本轮翻牌不能继续"});
		me.Msg("还没结束本轮翻牌不能继续");
		return 0;
	end
	if tbPlayerAward.tbCallBack and tbPlayerAward.tbCallBack.tbContinue then
 		Lib:CallBack({tbPlayerAward.tbCallBack.tbContinue[1], tbPlayerAward.tbCallBack.tbContinue[2]});
 	end
end

 --发奖励（背包不足，银两，绑银携带上限发邮件给奖励）
function CardAward:GiveAward(tbAward)
	local szType	= tbAward.szType;
	local varValue	= tbAward.varValue;
	local szStatLogName = tbAward.szStatLogName;
	local nNum		= tonumber(tbAward.szAddParam1) or 1;
	if (szType == "exp") then
		local nExp = me.AddExp2(varValue);
		if nExp > 0 then
			me.Msg("您得到了 <color=green>"..nExp.."<color> 点经验值！");
		end
	elseif (szType == "bindcoin") then
		me.AddBindCoin(varValue);
	elseif (szType == "money") then
		if me.nCashMoney + varValue <= me.GetMaxCarryMoney() then
			me.Earn(varValue, Player.emKEARN_EVENT);
			me.Msg("您得到了 <color=yellow>"..varValue.."<color> 两银子！");
		else
			KPlayer.SendMail(me.szName, "奖励物品发放", "补发因背包银两达上限未领取到的奖励。", 0, varValue);
			me.Msg("请注意查看邮件，查收奖励物品。");
		end
	elseif (szType == "bindmoney") then
		if me.GetBindMoney() + varValue <= me.GetMaxCarryMoney() then
			me.AddBindMoney(varValue);
		else
			--绑银不能直接邮件，借助任务变量和道具实现
			local nGetMoney = me.GetTask(self.TASK_GROUP, self.TASK_BINDMONEY);
			if nGetMoney > 0 then
				me.SetTask(self.TASK_GROUP, self.TASK_BINDMONEY, nGetMoney + varValue);
				me.Msg(varValue.."绑银已经累计到您的道具[银袋]中，请您收取之前发送的道具领取绑银。");
			else
				me.SetTask(self.TASK_GROUP, self.TASK_BINDMONEY, varValue);
				KPlayer.SendMail(me.szName, "奖励物品发放", "补发因背包绑定银两达上限未领取到的奖励。", 0, 0, 1, unpack(self.tbBindMoney));
				me.Msg("请注意查看邮件，查收奖励物品。");
			end
		end
	elseif (szType == "repute") then
		me.AddRepute(unpack(varValue));
	elseif (szType == "title") then
		me.AddTitle(unpack(varValue));
	elseif (szType == "item") then
		--GDPL 绑定属性 数量
		local nNeedBag = KItem.GetNeedFreeBag(varValue[1], varValue[2], varValue[3], varValue[4], {bTimeOut=varValue[7]}, varValue[6]);
		if me.CountFreeBagCell() >= nNeedBag then
			me.AddStackItem(varValue[1], varValue[2], varValue[3], varValue[4], {bForceBind = varValue[5]}, varValue[6]);
			me.Msg(string.format("Bạn nhận được %s vật phẩm phần thưởng!", varValue[6]));
		else
			KPlayer.SendMail(me.szName, "奖励物品发放", "补发因背包不足未领取到的奖励", 0, 0, varValue[6], varValue[1], varValue[2], varValue[3], varValue[4]);
			me.Msg("请注意查看邮件，查收奖励物品。");
		end
	elseif (szType == "gatherpoint") then
		me.ChangeCurGatherPoint(varValue)
		me.Msg("您得到了 <color=green>"..varValue.."<color> 点活力！");
	elseif (szType == "makepoint") then
		me.ChangeCurMakePoint(varValue)
		me.Msg("您得到了 <color=green>"..varValue.."<color> 点精力！");
	end;
end;

--计算卡牌选定的数目
function CardAward:CaleCountSelect()
	local tbPlayerAward = self:GetMyAward();
	local nCount = 0;
	for i, tbInfor in ipairs(tbPlayerAward.tbAwards) do
		if tbInfor.bSelected then
			nCount = nCount + 1;
		end
	end
	return nCount;
end

