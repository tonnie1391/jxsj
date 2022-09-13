--=================================================
-- 文件名　：achive_zhenyuan_open.lua
-- 创建者　：furuilei
-- 创建时间：2010-09-13 16:14:27
-- 功能描述：真元成就系统的开放奖励
--=================================================

SpecialEvent.Achive_Zhaneyuan = SpecialEvent.Achive_Zhaneyuan or {};
local tbEvent = SpecialEvent.Achive_Zhaneyuan;

tbEvent.TSK_GROUP			= 2027;
tbEvent.TSK_ID_ACHIEVEMENT	= 174;	-- 是否领取过成就奖励的标志
tbEvent.TSK_ID_ZHENYUAN_6	= 175;	-- 是否领取过6级真元奖励的标志
tbEvent.TSK_ID_ZHENYUAN_7	= 176;	-- 是否领取过7级真元奖励的标志

-- 奖励类型
tbEvent.AWARD_TYPE_TITLE	= "title";
tbEvent.AWARD_TYPE_ITEM		= "item";
tbEvent.AWARD_TYPE_MONEY	= "money";

-- 发奖条件判断
tbEvent.FUN_CHECK_BAG		= "checkbag";
tbEvent.FUN_CHECK_MONEY		= "checkmoney";

-- 颜色
tbEvent.SZCOLOR_PASS		= "white";
tbEvent.SZCOLOR_FAIL		= "gray";

tbEvent.tbAchievement_AwardInfo = {
	nNeedAchivePoint = 160,
	
	nStartDate = 20100928,
	nEndDate = 20101004,
	
	tbAwardInfo = {
		nFlag 	= tbEvent.TSK_ID_ACHIEVEMENT,
		tbCheck = {
			{szCheck = tbEvent.FUN_CHECK_BAG,		tbParam = {1}},
			{szCheck = tbEvent.FUN_CHECK_MONEY,		tbParam = {1000000}},
			},
		tbAward = {
			{szType = tbEvent.AWARD_TYPE_TITLE,		tbParam = {6, 42, 1, 0}},
			{szType = tbEvent.AWARD_TYPE_ITEM,		tbParam = {tbGDPL = {18, 1, 114, 9}, nCount = 1, nTimeOut = 30 * 24 * 60, bStack = 0}},
			{szType = tbEvent.AWARD_TYPE_MONEY,		tbParam = {1000000}},
			},
		},
	};

tbEvent.tbZhenyuan_AwardInfo = {
	nStartDate = 20100920,
	nEndDate = 20101003,
	
	tbAwardInfo = {
		[6] = {
			nFlag 	= tbEvent.TSK_ID_ZHENYUAN_6,
			tbCheck = {
				{szCheck = tbEvent.FUN_CHECK_BAG, 		tbParam = {2}},
				},
			tbAward = {
				{szType = tbEvent.AWARD_TYPE_ITEM,		tbParam = {tbGDPL = {18, 1, 541, 2}, nCount = 3, bBind = 1, bStack = 1}},
				{szType = tbEvent.AWARD_TYPE_ITEM,		tbParam = {tbGDPL = {18, 1, 524, 1}, nCount = 15, bBind = 1, bStack = 1}},
				{szType = tbEvent.AWARD_TYPE_TITLE,		tbParam = {6, 40, 1, 0}},
				},
			},
		[7] = {
			nFlag 	= tbEvent.TSK_ID_ZHENYUAN_7,
			tbCheck = {
				{szCheck = tbEvent.FUN_CHECK_BAG, 		tbParam = {2}},
				},
			tbAward = {
				{szType = tbEvent.AWARD_TYPE_ITEM,		tbParam = {tbGDPL = {18, 1, 541, 2}, nCount = 5, bBind = 1, bStack = 1}},
				{szType = tbEvent.AWARD_TYPE_ITEM,		tbParam = {tbGDPL = {18, 1, 524, 1}, nCount = 30, bBind = 1, bStack = 1}},
				{szType = tbEvent.AWARD_TYPE_TITLE,		tbParam = {6, 41, 1, 0}},
				},
			},
		};
	};

--========================================

function tbEvent:OnDialog()
	local szMsg = "剑侠世界9月新资料片开放了！只要你体验如下系统，稍稍努力就可以获得丰厚奖励哦！";
	local tbOpt = self:GetOpt();
	Dialog:Say(szMsg, tbOpt);
end

function tbEvent:GetOpt()
	local tbOpt = {};
	
	-- 成就系统对话
	local tbSetting = self.tbAchievement_AwardInfo;
	if (1 == self:__GetOpt_CheckDate(tbSetting.nStartDate, tbSetting.nEndDate)) then
		local szColor = self:__GetOpt_Color_Achievement() or self.SZCOLOR_FAIL;
		local szOpt = string.format("<color=%s>成就系统领奖<color>", szColor);
		if (szColor == self.SZCOLOR_PASS) then
			table.insert(tbOpt, {szOpt, self.Opt_Achievement, self});
		else
			table.insert(tbOpt, {szOpt, self.Opt_Achievement_Fail, self});
		end
	end
	
	-- 真元系统对话
	local tbSetting = self.tbZhenyuan_AwardInfo;
	if (1 == self:__GetOpt_CheckDate(tbSetting.nStartDate, tbSetting.nEndDate)) then
		local szColor = self:__GetOpt_Color_Zhenyuan() or self.SZCOLOR_FAIL;
		local szOpt = string.format("<color=%s>真元系统领奖<color>", szColor);
		if (szColor == self.SZCOLOR_PASS) then
			table.insert(tbOpt, {szOpt, self.Opt_ZhenYuan, self});
		else
			table.insert(tbOpt, {szOpt, self.Opt_ZhenYuan_Fail, self});
		end
	end
	
	return tbOpt;
end

function tbEvent:Opt_Achievement()
	local szMsg = "当你的成就点数达到<color=yellow>160<color>就可以在我这里领奖！";
	local tbOpt = {
		{"领取奖励", self.OnAward, self, self.tbAchievement_AwardInfo.tbAwardInfo},
		{"我不领了"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbEvent:Opt_Achievement_Fail()
	local szMsg = "您还不能领取该奖励，请再次确认领奖条件：\n1. 成就点数达到160点\n2. 未领过该奖励\n3. 确认有1格包裹空间。";
	Dialog:Say(szMsg);
end

function tbEvent:Opt_ZhenYuan()
	local szMsg = "只要您装备到身上的护体真元任一属性资质达到<color=yellow>6星<color>以上就有奖励领取！";
	local tbOpt = {};
	
	-- 6星奖励
	local szColor = self:__GetOpt_Color_Zhenyuan_6() or self.SZCOLOR_FAIL;
	local szOpt = string.format("<color=%s>护体真元资质达到6星奖励领取<color>", szColor);
	if (szColor == self.SZCOLOR_PASS) then
		table.insert(tbOpt, {szOpt, self.OnAward, self, self.tbZhenyuan_AwardInfo.tbAwardInfo[6]});
	else
		table.insert(tbOpt, {szOpt, self.Opt_ZhenYuan_Fail, self});
	end
	
	-- 7星奖励
	szColor = self:__GetOpt_Color_Zhenyuan_7() or self.SZCOLOR_FAIL;
	szOpt = string.format("<color=%s>护体真元资质达到7星奖励领取<color>", szColor);
	if (szColor == self.SZCOLOR_PASS) then
		table.insert(tbOpt, {szOpt, self.OnAward, self, self.tbZhenyuan_AwardInfo.tbAwardInfo[7]});
	else
		table.insert(tbOpt, {szOpt, self.Opt_ZhenYuan_Fail, self});
	end
	
	table.insert(tbOpt, {"我不领奖了"});
	
	Dialog:Say(szMsg, tbOpt);
end

function tbEvent:Opt_ZhenYuan_Fail()
	local szMsg = "您还不能领取该奖励，请再次确认领奖条件：\n1. 您所装备的真元任一属性资质达到6（或7）星\n2. 未领过该奖励\n3. 确认有2格包裹空间。";
	Dialog:Say(szMsg);
end

function tbEvent:__GetOpt_CheckDate(nStartTime, nEndTime)
	if (not nStartTime or not nEndTime) then
		return 0;
	end
	
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	if (nCurDate >= nStartTime and nCurDate <= nEndTime) then
		return 1;
	end
	return 0;
end

--========================================

function tbEvent:__GetOpt_Color_Achievement()
	local szColor = self.SZCOLOR_FAIL;
	
	if (1 == self:__GetOpt_Check_Achievement()) then
		szColor = self.SZCOLOR_PASS;
	end
	
	return szColor;
end

function tbEvent:__GetOpt_Check_Achievement()
	local nCurPoint = Achievement:GetAchievementPoint(me);
	local tbSetting = self.tbAchievement_AwardInfo;
	
	if (nCurPoint < tbSetting.nNeedAchivePoint) then
		return 0;
	end
	
	if (me.GetTask(self.TSK_GROUP, self.TSK_ID_ACHIEVEMENT) == 1) then
		return 0;
	end
	
	return 1;
end

--========================================

function tbEvent:__GetOpt_Color_Zhenyuan()
	local szColor = self.SZCOLOR_FAIL;
	
	if (self:__GetOpt_Color_Zhenyuan_6() == self.SZCOLOR_PASS or
		self:__GetOpt_Color_Zhenyuan_7() == self.SZCOLOR_PASS) then
		szColor = self.SZCOLOR_PASS;
	end
	
	return szColor;
end

-- 获取护体真元的最大资质等级
function tbEvent:__GetOpt_Zhenyuan_GetLevel()
	local pItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_ZHENYUAN_MAIN);
	if (not pItem) then
		return 0;
	end
	
	local nLevel1 = Item.tbZhenYuan:GetAttribPotential1(pItem);
	local nLevel2 = Item.tbZhenYuan:GetAttribPotential2(pItem);
	local nLevel3 = Item.tbZhenYuan:GetAttribPotential3(pItem);
	local nLevel4 = Item.tbZhenYuan:GetAttribPotential4(pItem);
	
	local nMaxLevel = nLevel1;
	nMaxLevel = nMaxLevel > nLevel2 and nMaxLevel or nLevel2;
	nMaxLevel = nMaxLevel > nLevel3 and nMaxLevel or nLevel3;
	nMaxLevel = nMaxLevel > nLevel4 and nMaxLevel or nLevel4;
	
	return nMaxLevel / 2;
end

function tbEvent:__GetOpt_Color_Zhenyuan_6()
	local nZhenyuanLevel = self:__GetOpt_Zhenyuan_GetLevel();
	if (nZhenyuanLevel < 6) then
		return self.SZCOLOR_FAIL;
	end
	
	if (me.GetTask(self.TSK_GROUP, self.TSK_ID_ZHENYUAN_6) == 1) then
		return self.SZCOLOR_FAIL;
	end
	
	return self.SZCOLOR_PASS;
end

function tbEvent:__GetOpt_Color_Zhenyuan_7()
	local nZhenyuanLevel = self:__GetOpt_Zhenyuan_GetLevel();
	if (nZhenyuanLevel < 7) then
		return self.SZCOLOR_FAIL;
	end
	
	if (me.GetTask(self.TSK_GROUP, self.TSK_ID_ZHENYUAN_7) == 1) then
		return self.SZCOLOR_FAIL;
	end
	
	return self.SZCOLOR_PASS;
end

--========================================

function tbEvent:CheckCond(tbCond)
	local bRet = 1;
	
	for _, tbInfo in pairs(tbCond) do
		if (tbInfo.szCheck == self.FUN_CHECK_BAG) then
			bRet = self:__CheckCond_Bag(unpack(tbInfo.tbParam));
		elseif (tbInfo.szCheck == self.FUN_CHECK_MONEY) then
			bRet = self:__CheckCond_Money(unpack(tbInfo.tbParam));
		end
		
		if (not bRet or 0 == bRet) then
			break;
		end
	end
	
	return bRet;
end

function tbEvent:__CheckCond_Bag(nNeedBag)
	local bRet = 1;
	
	if (nNeedBag > 0 and me.CountFreeBagCell() < nNeedBag) then
		Dialog:Say(string.format("请清理出%s格包裹空间再来领取奖励。", nNeedBag));
		bRet = 0;
	end
	
	return bRet;
end

function tbEvent:__CheckCond_Money(nAddMoney)
	local bRet = 1;
	
	if (nAddMoney > 0) then
		local nMaxCarryMoney = me.GetMaxCarryMoney();
		local nBindMoney = me.GetBindMoney();
		if (nBindMoney + nAddMoney > nMaxCarryMoney) then
			Dialog:Say("您已经不能携带更多的绑定银两了。");
			bRet = 0;
		end
	end
	
	return bRet;
end

--========================================

function tbEvent:OnAward(tbAwardInfo)
	if (0 == self:CheckCond(tbAwardInfo.tbCheck)) then
		return;
	end
	
	self:GetAward(tbAwardInfo.tbAward);
	self:OnAward_SetFlag(tbAwardInfo.nFlag);
end

function tbEvent:OnAward_SetFlag(nTaskId)
	if (not nTaskId or nTaskId <= 0) then
		return;
	end
	me.SetTask(self.TSK_GROUP, nTaskId, 1);
end

function tbEvent:GetAward(tbAward)
	for _, tbInfo in pairs(tbAward) do
		if (tbInfo.szType == self.AWARD_TYPE_TITLE) then
			self:__GetAward_Title(tbInfo.tbParam);
		elseif (tbInfo.szType == self.AWARD_TYPE_ITEM) then
			self:__GetAward_Item(tbInfo.tbParam);
		elseif (tbInfo.szType == self.AWARD_TYPE_MONEY) then
			self:__GetAward_Money(tbInfo.tbParam);
		end
	end
end

function tbEvent:__GetAward_Title(tbInfo)
	if (not tbInfo) then
		return;
	end
	me.AddTitle(unpack(tbInfo));
end

function tbEvent:__GetAward_Item(tbInfo)
	if (not tbInfo) then
		return;
	end
	local nCount = tbInfo.nCount or 0;
	local bStack = tbInfo.bStack or 0;
	if (0 == bStack) then
		for i = 1, nCount do
			local pItem = me.AddItem(unpack(tbInfo.tbGDPL));
			if (pItem) then
				if (tbInfo.nTimeOut) then
					me.SetItemTimeout(pItem, tbInfo.nTimeOut, 0);
				end
				if (tbInfo.bBind and tbInfo.bBind == 1) then
					pItem.Bind(1);
				end
				pItem.Sync();
			end
		end
	elseif(1 == bStack) then
		me.AddStackItem(tbInfo.tbGDPL[1],tbInfo.tbGDPL[2], tbInfo.tbGDPL[3], tbInfo.tbGDPL[4], {bForceBind = 1}, nCount);
	end
end

function tbEvent:__GetAward_Money(tbInfo)
	if (not tbInfo) then
		return;
	end
	me.AddBindMoney(tbInfo[1], Player.emKBINDMONEY_ADD_EVENT);
end
