-- 文件名　：plantform_award.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-20 20:54:03
-- 功能    ：无差别竞技

function NewEPlatForm:GetPlayerAward_Single()
	local nAwardFlag = me.GetTask(self.TASKID_GROUP, self.TASKID_AWARDFLAG);
	if (0 >= nAwardFlag) then
		Dialog:Say("没有奖励可以领哦，想要奖励快快参加活动吧！");
		return 0;
	end
	local nSession, nAwardID = self:GetAwardFlagParam(nAwardFlag);
	if (nSession <= 0 or nAwardID <= 0) then
		return 0;
	end
	return self:OnGetAwardSingle(nSession, nAwardID);
end

function NewEPlatForm:GetPlayerAward_Month(nFlag)
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 1 ô.");
		return 0;
	end
	local nMonthNow = tonumber(GetLocalDate("%m"));
	local nLastDayMonth = tonumber(os.date("%m", GetTime() - 24*3600));
	if nMonthNow ~= nLastDayMonth and (tonumber(GetLocalDate("%H%M")) <= 300) then
		Dialog:Say("每月一号3点后才可以开始领取奖励。");
		return 0;
	end
	local nRet, nSelfGrade, nKinGrade = self:CheckMonthAward(me);
	if nRet == 1 then
		if not nFlag then
			Dialog:Say(string.format("您上个月家族趣味竞技总积分<color=yellow>%s分<color>，家族上个月总积分<color=yellow>%s分<color>，可以领取5个家族趣味竞技宝箱，您确定领取？", nSelfGrade, nKinGrade), {{"Xác nhận", self.GetPlayerAward_Month, self, 1}, {"Để ta suy nghĩ thêm"}})
			return;
		end
	elseif nRet == 0 then
		Dialog:Say("您好像都没有家族，不能领取奖励了。");
		return 0;
	elseif nRet == 2 then
		Dialog:Say(string.format("您不够资格领取奖励。\n\n<color=red>领取奖励的条件为：家族积分排名达到前10且达到1080分，个人积分需要达到%s分<color>", self.nPayerGradeLimit, self.nKinGradeLimit));
		return 0;
	elseif nRet == 3 then
		Dialog:Say("您上个月的奖励已经领取过了。");
		return 0;
	end
	self:AddMonthAward(me);
end

function NewEPlatForm:AddMonthAward(pPlayer)
	local nKinId, nMemberId = pPlayer.GetKinMember();
	pPlayer.AddWaitGetItemNum(1);
	GCExcute{"NewEPlatForm:GetKinMonthAward", nKinId, nMemberId, pPlayer.nId};
end

function NewEPlatForm:AddMonthAwardEx(nPlayerId, nRank, nSelfMonth, nKinGrade)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.AddWaitGetItemNum(-1);
		pPlayer.AddStackItem(self.tbMonthAward[1], self.tbMonthAward[2], self.tbMonthAward[3], self.tbMonthAward[4], nil, 5);
		pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_AWARD_MONTH, tonumber(GetLocalDate("%m")));
		if nRank == 1 then
			Achievement:FinishAchievement(pPlayer, 507);
		end
		Achievement:FinishAchievement(pPlayer, 508);
		Achievement:FinishAchievement(pPlayer, 509);
		StatLog:WriteStatLog("stat_info", "kin_sports", "get_award", pPlayer.nId, string.format("%s_%s_%s_%s,%s", self.tbMonthAward[1], self.tbMonthAward[2], self.tbMonthAward[3], self.tbMonthAward[4], 5));
		pPlayer.Msg("恭喜您获得家族趣味竞技月度奖励。");
	end	
end

--领取奖励失败
function NewEPlatForm:GetKinMonthAwardFailed(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.AddWaitGetItemNum(-1);
		pPlayer.Msg("您的奖励不正确。");
	end
end

function NewEPlatForm:CheckMonthAward(pPlayer)
	if not pPlayer then
		return 0;
	end
	local nMonthNow = tonumber(GetLocalDate("%m"));
	local nGetMonth = pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_AWARD_MONTH);
	if nMonthNow == nGetMonth then
		return 3;
	end
	local nKinId, nMemberId = pPlayer.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end
	local nKinMonth = pKin.GetKinGameMonth();
	local nKinTotalGrade = pKin.GetKinGameGrade();
	local nKinTotalGradeLast= pKin.GetKinGameGradeLast();
	local nNowMonth = tonumber(GetLocalDate("%m"));
	local nKinGrade = 0;
	if nNowMonth == math.fmod(nKinMonth, 12) + 1 then
		nKinGrade = nKinTotalGrade;
	elseif nNowMonth == nKinMonth then
		nKinGrade = nKinTotalGradeLast;
	end
	local nMemMonth = pMember.GetKinGameMonth();
	local nMemGrade = pMember.GetKinGameGrade();
	local nSelfMonth = 0;
	if nNowMonth == math.fmod(nMemMonth, 12) + 1 then
		nSelfMonth = nMemGrade;
	end
	local nRank = 0;
	local nLadderType	= Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_EVENTPLANT, Ladder.LADDER_TYPE_LADDER_EVENTPLANT_PRETEAM);
	local tbLadder = GetShowLadder(nLadderType) or {};
	for nId, tbInfo in ipairs(tbLadder) do
		if pKin.GetName() == tbInfo.szName then
			nRank = nId;
			break;
		end
	end
	if nSelfMonth >= self.nPayerGradeLimit and nKinGrade >= self.nKinGradeLimit and nRank > 0 then
		return 1, nSelfMonth, nKinGrade;
	end
	return 2, nSelfMonth, nKinGrade;
end


--领取单场胜利奖励
function NewEPlatForm:OnGetAwardSingle(nSession, nAwardID)
	-- 混战奖励
	if (not self.AWARD_WELEE_LIST[nSession]) then
		Dialog:Say("没有奖励");
		return 0;
	end	
	local tbAward = self.AWARD_WELEE_LIST[nSession][nAwardID];
	if (not tbAward) then
		Dialog:Say("没有奖励");
		return 0;	
	end	
	local nFree = self.Fun:GetNeedFree(tbAward);
	if me.CountFreeBagCell() < nFree then
		Dialog:Say(string.format("您的背包空间不够,请整理%s格背包空间.", nFree));
		return 0;
	end
	--奖励
	self.Fun:DoExcute(me, tbAward);
	me.SetTask(self.TASKID_GROUP, self.TASKID_AWARDFLAG, 0);
	self:WriteLog("OnGetAwardSingle", string.format("%s获得混战物品奖励 nSession, nAwardID", me.szName), nSession, nAwardID);	
	return 1;
end

function NewEPlatForm:GetAwardFlagParam(nAwardFlag)	
	local nSession	= KLib.GetByte(nAwardFlag, 2);
	local nAwardID	= KLib.GetByte(nAwardFlag, 1);
	return nSession, nAwardID;
end

function NewEPlatForm:SetAwardFlagParam(nAwardFlag, nSession, nAwardID)
	nAwardFlag	= KLib.SetByte(nAwardFlag, 2, nSession);
	nAwardFlag	= KLib.SetByte(nAwardFlag, 1, nAwardID);
	return nAwardFlag;
end


----------------------------------------------------------------------------------------------
--卡牌奖励回调及逻辑处理
----------------------------------------------------------------------------------------------

function NewEPlatForm:CaleAward(nRank, pPlayer, nIndexCur)
	if nRank > 6 then
		return;
	end
	local tbAward = Lib._CalcAward:CaleBindValue(61896);
	local nCount = pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_TOTLE);
	local nCardAward = pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_AWARD_CARD);
	local nAwardCount = math.floor(nCardAward / 10);
	local nIndex = 1;
	if nAwardCount == nCount then
		nIndex = math.fmod(nCardAward, 10) + 1;
	end
	if nIndexCur then
		nIndex = nIndexCur;
	end
	if nIndex > #self.tbCardAward or not self.tbCardAward[nIndex] then
		return;
	end
	pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_AWARD_CARD, nCount * 10 + nIndex);
	if nIndex == 1 then
		local tbAwardList = {};
		for _, tb in ipairs(self.tbCardAward[nIndex]) do
			table.insert(tbAwardList, tb);
		end
		for _, tb in ipairs(tbAward) do
			if tb.szType == "item" then
				table.insert(tbAwardList, {["szType"] = tb.szType, ["varValue"] = tb.varValue, ["nRate"] = math.floor(tb.nRate * 3 * self.tbXuanjingRate[nIndex] / 10000)});
			end
		end
		
		return tbAwardList;
	else
		return self.tbCardAward[nIndex];
	end
end

-- 开始一轮的回调，这里做购买道具提示
function NewEPlatForm:StarCondition()
	local nCardAward = me.GetTask(self.TASKID_GROUP, self.TASKID_AWARD_CARD);
	local nIndex = math.fmod(nCardAward, 10);
	local nCount = math.floor(nCardAward/10);
	local nTotalCount = me.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_TOTLE);
	if nTotalCount ~= nCount then
		nIndex = 0;
	end
	if nIndex > #self.tbCardAward then
		me.Msg("Tất cả phần thưởng đã được nhận.");
		me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", "Tất cả phần thưởng đã được nhận."});
		return 0;
	end
	local tbCostItem = self.tbPayItem[nIndex];
	if tbCostItem then
		local tbFind = me.FindItemInBags(tbCostItem[1][1], tbCostItem[1][2], tbCostItem[1][3], tbCostItem[1][4]);
		local nCount = 0;
		for i, tbItem in ipairs(tbFind) do
			nCount = nCount + tbItem.pItem.nCount;
		end
		local szName = "Quả Thắng Lợi (nhỏ)";
		if nIndex == 3 then
			
		end
		if nCount < tbCostItem[1][5] then
			local tbOpt = {{"Quả Thắng Lợi (nhỏ)", self.BuyItem, self, 1},{"Để ta suy nghĩ thêm"}}
			if nIndex == 3 then
				szName = "Quả Thắng Lợi (lớn)";	
				tbOpt[1] = {"Quả Thắng Lợi (lớn)", self.BuyItem, self, 2};
			end
			Dialog:Say("Vòng quay này cần <color=yellow>"..tbCostItem[1][5].." "..szName.."<color>, bạn có muốn mua không?\n\n<color=green>Quả Thắng Lợi (nhỏ): <color><color=yellow>100 đồng/quả<color>\n<color=green>Quả Thắng Lợi (lớn): <color><color=yellow>300 đồng/quả", tbOpt);
			return 0;
		end
	end
end

function NewEPlatForm:BuyItem(nIndex, nFlag)
	local tbName = {"Mua Quả Thắng Lợi (nhỏ)", "Mua Quả Thắng Lợi (lớn)"}
	local tbBuyItem = {[1] = {618, 100}, [2] = {619, 300}};
	if nIndex <= 0 or nIndex > 2 then
		print("传递的参数有问题。");
		return;
	end
	if me.nCoin < tbBuyItem[nIndex][2] then
		Dialog:Say("Không đủ <color=yellow>"..tbBuyItem[nIndex][2].."<color> đồng để mua!", {{"Ta hiểu rồi"}});
		return;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 1 chỗ trống.", {{"Ta hiểu rồi"}});
		return;
	end
	if not nFlag then
		Dialog:Say(string.format("Dùng <color=yellow>%s<color>đông mua 1 <color=yellow>%s<color>?", tbBuyItem[nIndex][2], tbName[nIndex]), {{"Đồng ý", self.BuyItem, self, nIndex, 1},{"Để ta suy nghĩ thêm"}});
		return;
	end
	me.ApplyAutoBuyAndUse(tbBuyItem[nIndex][1], 1, 0);
	return;
end

--付费打开一张卡牌回调，log等
function NewEPlatForm:OpenOneCard(tbAward, bPay)
	me.SetTask(self.TASKID_GROUP, self.TASKID_AWARD_HANDON, 10000);	--为了区别第一次0个道具设大点
	local nCardAward = me.GetTask(self.TASKID_GROUP, self.TASKID_AWARD_CARD);
	local nIndex = math.fmod(nCardAward, 10);
	local tbItem = tbAward.varValue;
	StatLog:WriteStatLog("stat_info", "kin_sports", "pick_card", me.nId, string.format("%s,%s_%s_%s_%s,%s", nIndex, tbItem[1], tbItem[2], tbItem[3], tbItem[4], tbItem[6]));
end

function NewEPlatForm:OnBackEnd(tbMission)
	if tbMission.tbMission:IsOpen() == 1 then
		tbMission.tbMission:KickPlayer(me);
	end
end

function NewEPlatForm:Continue(tbMission)
	local nCardAward = me.GetTask(self.TASKID_GROUP, self.TASKID_AWARD_CARD);
	local nIndex = math.fmod(nCardAward, 10);
	local nCount = math.floor(nCardAward/10);
	local nTotalCount = me.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_TOTLE);
	if nTotalCount ~= nCount then
		nIndex = 0;
	end
	if nIndex >= #self.tbCardAward then
		me.Msg("Tất cả phần thưởng đã được nhận.");
		me.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", "Tất cả phần thưởng đã được nhận."});
		return 0;
	end
	local nRank = tbMission.tbMission:GetCurRank(me);
	local tbAward = self:CaleAward(nRank, me);
	if not tbAward then
		return 0;
	end
	local tbCallBack = {
		["tbBackEnd"] 		= {tbMission.OnBackEnd, tbMission},
		["tbOpenOneCard"] 	= {self.OpenOneCard, self},
		["tbStarCondition"] 	= {self.StarCondition, self},
		["tbHandUp"] 		= {self.OnHandUp, self},
		};
	if nIndex < #self.tbCardAward - 1 then
		tbCallBack.tbContinue = {tbMission.Continue, tbMission};
	end
	CardAward:SendAskAward(self.szUITitle, self.tbMsg[nIndex + 1], tbAward, self.tbPayItem[nIndex + 1], nil, tbCallBack, 0, 1, 1, 1);
end

function NewEPlatForm:OnHandUp(nCount)
	--记录上交物品的数目
	me.SetTask(self.TASKID_GROUP, self.TASKID_AWARD_HANDON, nCount);
end

function NewEPlatForm:OnLevel(tbMission)
	local nCardAward = me.GetTask(self.TASKID_GROUP, self.TASKID_AWARD_CARD);
	local nIndex = math.fmod(nCardAward, 10);
	local nCount = math.floor(nCardAward / 10);
	local nTotalCount = me.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_TOTLE);
	local nHandOnCount = me.GetTask(self.TASKID_GROUP, self.TASKID_AWARD_HANDON);
	me.CallClientScript({"UiManager:CloseWindow", "UI_CARDAWARD"});
	me.CallClientScript({"UiManager:CloseWindow", "UI_KINGAMESCREEN"});
	local nHandOnNeed = -1;
	if nIndex <= 0 or nTotalCount ~= nCount then
		return;
	end
	if self.tbPayItem[nIndex] then
		nHandOnNeed = self.tbPayItem[nIndex][1][5];
	end
	if (nHandOnNeed ~= nHandOnCount) then
		return;
	end
	local nRank = tbMission.tbMission:GetCurRank(me);
	local tbAward = self:CaleAward(nRank, me, nIndex);
	if not tbAward then
		return;
	end
	local nCurIndex = CardAward:MathRandom(tbAward);
	CardAward:GiveAward(tbAward[nCurIndex]);
	local tbItem = tbAward[nCurIndex].varValue;
	StatLog:WriteStatLog("stat_info", "kin_sports", "pick_card", me.nId, string.format("%s,%s_%s_%s_%s,%s", nIndex, tbItem[1], tbItem[2], tbItem[3], tbItem[4], tbItem[6]));
	me.SetTask(self.TASKID_GROUP, self.TASKID_AWARD_CARD, nCount * 10 + nIndex);
end
