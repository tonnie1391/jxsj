-- 文件名　：qixi2012_item.lua
-- 创建者　：huangxiaoming
-- 创建时间：2012-08-10 14:10:10
-- 描  述  ：

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\201208_qixi\\qixi2012_def.lua");
SpecialEvent.QiXi2012 = SpecialEvent.QiXi2012 or {};
local tbQiXi2012 = SpecialEvent.QiXi2012 or {};

local tbSeed = Item:GetClass("qixi2012_seed");

function tbSeed:OnUse()
	if tbQiXi2012:CheckIsOpen() ~= 1 then
		return;
	end
	local nRet, szMsg = tbQiXi2012:CheckCanPlant(me);
	if nRet ~= 1 then
		me.Msg(szMsg);
		return;
	end
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
	}
	GeneralProcess:StartProcess("种玫瑰中", 5 * Env.GAME_FPS, 
		{tbQiXi2012.PlantSeed, tbQiXi2012, me.nId}, nil, tbEvent);
end


local tbAwardBox = Item:GetClass("qixi2012_awardbox");

function tbAwardBox:OnUse()
	local szMapType = GetMapType(me.nMapId);
	if szMapType ~= "city" and szMapType ~= "village" then
		Dialog:Say("该道具只能在城市和新手村使用。");
		return;
	end
	local nSuoxinyuCount = it.GetExtParam(1) or 1;
	local szMsg = "<color=yellow>金风玉露一相逢，便胜却人间无数。<enter><enter>两情若是久长时，又岂在朝朝暮暮。<color><enter><enter>你想许下什么愿望？";
	local tbOpt = 
	{
		{"求姻缘", self.OpenAwardBox, self, it.dwId, 1},
		{"求包养", self.OpenAwardBox, self, it.dwId, 2},
		{"求发财", self.OpenAwardBox, self, it.dwId, 3},
		{"别无所求", self.OpenAwardBox, self, it.dwId, 4},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbAwardBox:OpenAwardBox(dwItemId, nType)
	local pItem = KItem.GetObjById(dwItemId);
	if (not pItem) then
		return;
	end
	local szMapType = GetMapType(me.nMapId);
	if szMapType ~= "city" and szMapType ~= "village" then
		Dialog:Say("该道具只能在城市和新手村使用。");
		return;
	end
	local nSuoxinyuCount = pItem.GetExtParam(1) or 1;
	if me.CountFreeBagCell() < nSuoxinyuCount + 1 then
		Dialog:Say(string.format("Hành trang không đủ chỗ trống，需要%s格背包空间", nSuoxinyuCount + 1));
		return;
	end
	local nOpenDay = math.floor((GetTime() - KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME)) / (60 * 60 * 24));
	local tbAward = Lib._CalcAward:RandomAward(3, 4, 2, tbQiXi2012.AWARDBOX_BASEVALUE, Lib:_GetXuanReduce(nOpenDay), {8, 2, 0});
	local nMaxMoney = tbQiXi2012:GetMaxMoney(tbAward);
	if nMaxMoney + me.GetBindMoney() > me.GetMaxCarryMoney() then
		Dialog:Say("对不起，您身上的绑定银两可能会超出上限，请整理后再来领取。");
		return 0;
	end
	local nRet, szPrompt = tbQiXi2012:AddXuyuandeng(me, nType);
	if nRet ~= 1 then
		if szPrompt then
			Dialog:Say(szPrompt);
			return;
		end
	end
	if pItem.Delete(me) ~= 1 then
		print("qixi2012", "delete awardbox fail", me.szName, nSuoxinyuCount);
		return;
	end
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	local nValidTime = Lib:GetDate2Time(nDate) + 24 * 3600 - 1;
	for i = 1, nSuoxinyuCount do
		local pItem = me.AddItem(unpack(tbQiXi2012.ITEMID_SUOXINYU));
		if pItem then
			pItem.Bind(1);
			me.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/%S", nValidTime));
			pItem.Sync();
		else
			print("qixi2012", "add suoxinyu fail", me.szName);
		end
	end
	StatLog:WriteStatLog("stat_info", "qixi_2012", "suoxinyu_get", me.nId, nSuoxinyuCount);
	tbQiXi2012:RandomAward(me, tbAward);
end

local tbGrapUsed = Item:GetClass("qixi2012_grapused");

function tbGrapUsed:OnUse()
	local nLevel = it.nLevel;
	Dialog:Say("<newdialog>" .. tbQiXi2012.PATH_ROSE_SHARP_SPR[nLevel] .. "\n以上阵图代表红玫瑰与粉玫瑰分布图，请指导你的前世有缘人，浇灌出<color=yellow>9朵红玫瑰<color>,真爱之花将会盛开。（小心不要浇出粉玫瑰哦）");
end

local tbSuoxinyu = Item:GetClass("qixi2012_suoxinyu");

function tbSuoxinyu:OnUse()
	local nId = tbQiXi2012:GetTodayOpenSuoxinyuTimes(me);
	local nNextFloor = nId + 1;
	local nMaxFloor = #tbQiXi2012.OPENSUOXINYU_INFO;
	if nNextFloor > nMaxFloor then
		Dialog:Say(string.format("你今天已经开了%s次锁心玉，无法开启", nId));
		return 0;
	end
	local nSeedCount = me.GetItemCountInBags(unpack(tbQiXi2012.ITEMID_JIEXINYU));
	local nNeedCount = tbQiXi2012.OPENSUOXINYU_INFO[nNextFloor][1];
	if nSeedCount < nNeedCount then
		local szMsg = string.format("开启第%s层需要消耗%s个解心玉，你身上的解心玉数量不足。确定<color=yellow>每个10金<color>购买解心玉？", nNextFloor, nNeedCount);
		local tbOpt = 
		{
			{"<color=yellow>购买解心玉<color>", self.BuyItem, self},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	else
		local szMsg = string.format("今日已开启%s/%s个<color=yellow>锁心玉<color>,本次开启需要消耗%s个<color=green>解心玉<color>，确定开启？", nId, nMaxFloor, nNeedCount);
		local tbOpt = 
		{
			{"开启", self.SureOpen, self, it.dwId},
			{"Để ta suy nghĩ thêm"},	
		};
		Dialog:Say(szMsg, tbOpt);
	end
end

function tbSuoxinyu:BuyItem(nFlag, nNum)
	if not nFlag then
		Dialog:AskNumber("请输入您要购买物品的数量", 20, self.BuyItem, self, 1);
		return;
	end
	local tbBuyItem = {625, 10};
	if nNum <= 0 then
		Dialog:Say("您输入的数目不正确。");
		return;
	end
	if me.nCoin < tbBuyItem[2] * nNum then
		Dialog:Say("您的金币不足！", {{"我知道啦"}});
		return;
	end
	if me.CountFreeBagCell() < nNum then
		Dialog:Say("Hành trang không đủ chỗ trống.", {{"我知道啦"}});
		return;
	end
	me.ApplyAutoBuyAndUse(tbBuyItem[1], nNum, 0);
	return;
end

function tbSuoxinyu:SureOpen(dwItemId)
	local pItem = KItem.GetObjById(dwItemId);
	if (not pItem) then
		return;
	end
	local nId = tbQiXi2012:GetTodayOpenSuoxinyuTimes(me);
	local nNextFloor = nId + 1;
	local nMaxFloor = #tbQiXi2012.OPENSUOXINYU_INFO;
	if nNextFloor > nMaxFloor then
		return 0;
	end
	if me.CountFreeBagCell() < 2 then
		me.Msg("Hành trang không đủ chỗ trống，需要2格背包空间。");
		return 0;
	end
	local nSeedCount = me.GetItemCountInBags(unpack(tbQiXi2012.ITEMID_JIEXINYU));
	local nNeedCount = tbQiXi2012.OPENSUOXINYU_INFO[nNextFloor][1];
	if nSeedCount < nNeedCount then
		local szMsg = string.format("开启第%s层需要消耗%s个解心玉，你身上的解心玉数量不足。确定每个10金购买？", nNextFloor, nNeedCount);
		local tbOpt = 
		{
			{"<color=yellow>购买解心玉<color>", self.BuyItem, self},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	local nOpenDay = math.floor((GetTime() - KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME)) / (60 * 60 * 24));
	local tbAward = Lib._CalcAward:RandomAward(3, 4, 2, tbQiXi2012.OPENSUOXINYU_INFO[nNextFloor][2], Lib:_GetXuanReduce(nOpenDay), {8, 2, 0});
	local nMaxMoney = tbQiXi2012:GetMaxMoney(tbAward);
	if nMaxMoney + me.GetBindMoney() > me.GetMaxCarryMoney() then
		Dialog:Say("对不起，您身上的绑定银两可能会超出上限，请整理后再来领取。");
		return 0;
	end
	-- 需要先扣活动产出的,如何区别？先扣绑定的如何？
	local nBindCount = me.GetItemCountInBags(tbQiXi2012.ITEMID_JIEXINYU[1], tbQiXi2012.ITEMID_JIEXINYU[2], tbQiXi2012.ITEMID_JIEXINYU[3], tbQiXi2012.ITEMID_JIEXINYU[4], -1, 1);
	if nBindCount > 0 then
		local nNeedConsume = nNeedCount;
		if nBindCount < nNeedCount then
			nNeedConsume = nBindCount;
		end
		local nRet = me.ConsumeItemInBags2(nNeedConsume, tbQiXi2012.ITEMID_JIEXINYU[1], tbQiXi2012.ITEMID_JIEXINYU[2], tbQiXi2012.ITEMID_JIEXINYU[3], tbQiXi2012.ITEMID_JIEXINYU[4], -1, 1);	
		if nRet ~= 0 then
			Dbg:WriteLog("qixi2012", "consume bind jiexinyu", me.szAccount, me.szName, nNeedConsume, nRet);
			return 0;
		end
		nNeedCount = nNeedCount - nNeedConsume;
	end
	if nNeedCount > 0 then
		local nRet = me.ConsumeItemInBags2(nNeedCount, unpack(tbQiXi2012.ITEMID_JIEXINYU));
		if nRet ~= 0 then
			Dbg:WriteLog("qixi2012", "consume unbind jiexinyu", me.szAccount, me.szName, nNeedCount, nRet);
			return 0;
		end
	end
	if pItem.Delete(me) ~= 1 then
		Dbg:WriteLog("qixi2012", "delete suoxinyu fail", me.szAccount, me.szName, nNextFloor, nRet);
		return 0;
	end
	me.SetTask(tbQiXi2012.TASK_GROUP_ID, tbQiXi2012.TASK_OPENSUOXINYU_TIMES, nNextFloor);
	tbQiXi2012:RandomAward(me, tbAward);
	tbQiXi2012:RandPet(me, nNextFloor);
	StatLog:WriteStatLog("stat_info", "qixi_2012", "cost_jiexinyu", me.nId, tbQiXi2012.OPENSUOXINYU_INFO[nNextFloor][1]);
	return 0;
end

local tbJiexinyu = Item:GetClass("qixi2012_jiexinyu")

function tbJiexinyu:OnUse()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate > tbQiXi2012.CLOSE_DAY then
		me.AddBindCoin(30);
		return 1;
	end
end


-- 情缘礼包
local tbQingyuanlibao = Item:GetClass("qixi2012_qingyuanlibao");

function tbQingyuanlibao:OnUse()
	local nType = it.nParticular;
	if not tbQiXi2012.QINGYUANLIBAO_AWARD[nType] then
		return;
	end
	local nAwardCount = #tbQiXi2012.QINGYUANLIBAO_AWARD[nType];
	local tbFlag = {};
	for i = 1, nAwardCount do
		tbFlag[i] = it.GetGenInfo(i, 0);
	end
	local szMsg = "打开礼包可获得以下道具：";
	local tbAwardList = tbQiXi2012.QINGYUANLIBAO_AWARD[nType];
	local tbOpt = {};
	for i = 1, nAwardCount do
		local szOpt = tbAwardList[i][1];
		if tbFlag[i] ~= 0 then
			szOpt = "<color=gray>" .. szOpt .. "<color>";
		end
		table.insert(tbOpt, {szOpt, self.GetAward, self, it.dwId, i, nType});
	end
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say(szMsg, tbOpt);
end

function tbQingyuanlibao:GetAward(dwItemId, nIndex, nType)
	local pItem = KItem.GetObjById(dwItemId);
	if (not pItem) then
		return;
	end
	local nAwardCount = #tbQiXi2012.QINGYUANLIBAO_AWARD[nType];
	if nIndex <= 0 or nIndex > nAwardCount then
		return;
	end
	local nFlag = pItem.GetGenInfo(nIndex, 0);
	if nFlag ~= 0 then
		Dialog:Say("你已经领取过该奖励。");
		return;
	end
	local tbAward = tbQiXi2012.QINGYUANLIBAO_AWARD[nType][nIndex];
	if tbAward[2] == 1 then -- 绑金
		pItem.SetGenInfo(nIndex, 1)
		me.AddBindCoin(tbAward[3]);
	elseif tbAward[2] == 2 then -- 道具
		if me.CountFreeBagCell() < tbAward[4] then
			Dialog:Say(string.format("Hành trang không đủ chỗ trống，需要%s格空间", tbAward[4]));
			return;
		end
		pItem.SetGenInfo(nIndex, 1)
		local pAddItem = me.AddItem(unpack(tbAward[3]));
		if pAddItem then
			pAddItem.Bind(1);
			me.SetItemTimeout(pAddItem, tbAward[5], 0);
			pAddItem.Sync();
		end
	elseif tbAward[2] == 3 then -- 称号
		pItem.SetGenInfo(nIndex, 1)
		me.AddTitle(unpack(tbAward[3]));
	end
	for i = 1, nAwardCount do
		if pItem.GetGenInfo(i, 0) == 0 then
			return;
		end
	end
	pItem.Delete(me);
end

-- 未打开的玫瑰阵图
local tbRoseGrap = Item:GetClass("qixi2012_grap")

function tbRoseGrap:OnUse()
	Dialog:SendInfoBoardMsg(me, "当前状态无法打开阵图");
	Dialog:SendBlackBoardMsg(me, "只有你的前世有缘人为你种下玫瑰后将自动打开")
end