-------------------------------------------------------
-- 文件名　：womenday_2011_gs.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-02-25 15:31:06
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\201103_womenday\\womenday_2011_def.lua");

local tbWomenday_2011 = SpecialEvent.Womenday_2011;

-- 特殊对话
function tbWomenday_2011:OnDialog(pNpc)
	
	-- 活动开关
	if self:CheckIsOpen() ~= 1 then
		Dialog:SendInfoBoardMsg(pPlayer, "对不起，活动已经结束，无法再赠送花与酒。您可将其卖给商人。");
		return 0;
	end
	
	local szMsg = [[
    一顾倾人城，再顾倾人国，宁不知倾城与倾国，佳人再难得。
    情意半边天活动从<color=yellow>3月8日0点至3月12日24点<color>结束。在此期间，你可以通过逍遥谷闯关、军营任务、宋金战场、官府通缉、击杀精英首领方式获得花与酒。
    当点亮半边天卡中<color=yellow>10位美女<color>的名字便可以获得丰厚的奖励，快去为可爱的美女们赠送礼物吧。
]];
	local tbOpt =
	{
		{"组队赠送花与酒", self.TeamSendFlower, self, pNpc},
		{"单人赠送花与酒", self.SendFlower, self, pNpc},
		{"Ta hiểu rồi"},
	};
	Dialog:Say(szMsg, tbOpt);
end

-- 是否可以送花
function tbWomenday_2011:CheckSendFlower(pNpc)
	
	-- 活动开关
	if self:CheckIsOpen() ~= 1 then
		Dialog:SendInfoBoardMsg(me, "对不起，活动已经结束，无法再赠送花与酒。您可将其卖给商人。");
		return 0;
	end
	
	-- 未满60级
	if me.nLevel < 60 then
		Dialog:SendInfoBoardMsg(me, "你太小了，等长大了再来送吧。");
		return 0;
	end
	
	-- 未加入门派
	if me.nFaction <= 0 then
		Dialog:SendInfoBoardMsg(me, "你还没加入门派哟。");
		return 0;
	end
	
	-- 今天完成
	if me.GetTask(self.TASK_GID, self.TASK_DAY_AWARD) == 1 then
		Dialog:SendInfoBoardMsg(me, "你今天已经领取过卡册奖励，请明天再来吧。");
		return 0;
	end
	
	-- 没有卡册
	if me.GetTask(self.TASK_GID, self.TASK_GET_CARD) == 0 then
		if me.CountFreeBagCell() < 1 then
			Dialog:SendInfoBoardMsg(me, "请留出1格背包空间。");
			return 0;
		end
	end
	
	-- 送过此npc
	local nFlag = 0;	
	for _, tbLine in ipairs(self.TASK_CARD) do
		for _, tbTaskId in ipairs(tbLine) do
			if me.GetTask(self.TASK_GID, tbTaskId[1]) == 1 then
				if tbTaskId[3] == pNpc.nTemplateId then
					Dialog:SendInfoBoardMsg(me, "半边天卡里已经有这个姑娘了，还是另觅良缘吧。");
					return 0;
				end
				nFlag = nFlag + 1;
			end
		end
	end
	
	-- 全部点亮
	if nFlag >= self.MAX_NPC_COUNT then
		Dialog:SendInfoBoardMsg(me, "你的半边天卡已经全部点亮了，可以点击卡片领取奖励，无需再送了。");
		return 0;
	end
	
	-- 是否有花
	local nFind = me.GetItemCountInBags(unpack(self.FLOWER_ID));
	if nFind <= 0 then
		Dialog:SendInfoBoardMsg(me, "你身上没有花与酒，拿什么来送人啊。");
		return 0;
	end
		
	return 1;
end

function tbWomenday_2011:SendFlower(pNpc, nMemberCount)
	
	if self:CheckSendFlower(pNpc) ~= 1 then
		return 0;
	end
	
	-- 没有卡册发一个
	if me.GetTask(self.TASK_GID, self.TASK_GET_CARD) == 0 then
		local pItem = me.AddItem(unpack(self.CARD_ID));
		if pItem then
			local nSec = Lib:GetDate2Time(20120316);--Lib:GetDate2Time(20110316);
			pItem.SetTimeOut(0, nSec);
			pItem.Sync();
			me.SetTask(self.TASK_GID, self.TASK_GET_CARD, 1);
		end
	end
	
	-- 扣除道具
	local nRet = me.ConsumeItemInBags(1, self.FLOWER_ID[1], self.FLOWER_ID[2], self.FLOWER_ID[3], self.FLOWER_ID[4]);
	if nRet ~= 0 then
		Dbg:WriteLog("womenday_2011", "2012美女节", me.szAccount, me.szName, "扣除花与酒失败。");
		return 0;
	end
	
	-- 设置任务变量
	for _, tbLine in ipairs(self.TASK_CARD) do
		for _, tbTaskId in ipairs(tbLine) do
			if tbTaskId[3] == pNpc.nTemplateId and me.GetTask(self.TASK_GID, tbTaskId[1]) == 0 then
				me.SetTask(self.TASK_GID, tbTaskId[1], 1);
				break;
			end
		end
	end
	
	-- 奖励提示
	local nAdd = 0;
	local tbInfo = nil;
	local nRand = MathRandom(1, 1000);
	local nMulti = self.TEAM_RATE[nMemberCount or 1] or 1;

	for i = 1, #self.SEND_AWARD do
		nAdd = nAdd + self.SEND_AWARD[i].Rate;
		if nAdd >= nRand then
			tbInfo = self.SEND_AWARD[i];
			break;
		end
	end
	
	if not tbInfo then
		return 0;
	end
	
	if tbInfo.Type == "coin" then
		me.AddBindCoin(tbInfo.Count * nMulti);
	elseif tbInfo.Type == "money" then
		me.AddBindMoney(tbInfo.Count * nMulti);
	else
		Dbg:WriteLog("womenday_2011", "2012美女节", me.szAccount, me.szName, "获得奖励失败。");
 	end
 	
 	me.AddExp(me.GetBaseAwardExp() * 24 * nMulti);
	Dialog:SendBlackBoardMsg(me, string.format("你成功送出花与酒，<color=yellow>点亮<color>了半边天卡上的<color=yellow>%s<color>", pNpc.szName));
	
	-- log
	Dbg:WriteLog("womenday_2011", "2012美女节", me.szAccount, me.szName, string.format("赠送花与酒给：%s", pNpc.szName));
	StatLog:WriteStatLog("stat_info", "funvjie2012", "give", me.nId, nMemberCount or 1);
end

function tbWomenday_2011:TeamSendFlower(pNpc)
	
	local tbMemberList, nMemberCount = me.GetTeamMemberList();
	if not tbMemberList or nMemberCount == 1 then
		Dialog:SendInfoBoardMsg(me, "请与他人组队后再来赠送吧。");
		return 0;
	end
	
	if me.IsCaptain() ~= 1 then
		Dialog:SendInfoBoardMsg(me, "你不是队长，请叫队长来赠送。");
		return 0;
	end
	
	local nFlag = 0;
	for _, pMember in pairs(tbMemberList) do
		Setting:SetGlobalObj(pMember);
		if self:CheckSendFlower(pNpc) ~= 1 then
			KTeam.Msg2Team(me.nTeamId, string.format("[%s]无法赠送礼物。", me.szName));
			nFlag = 1;
		end
		Setting:RestoreGlobalObj();
	end
	
	if nFlag == 1 then
		return 0;
	end
	
	local nNearby = 0;
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId, 50);
	if tbPlayerList then
		for _, pPlayer in ipairs(tbPlayerList) do
			for _, pMember in pairs(tbMemberList) do
				if pMember.szName == pPlayer.szName then
					nNearby = nNearby + 1;
				end
			end
		end
	end
	
	if nNearby ~= nMemberCount then
		Dialog:SendInfoBoardMsg(me, "请叫你的队友们都过来吧。");
		return 0;
	end
	
	for _, pMember in pairs(tbMemberList) do
		Setting:SetGlobalObj(pMember);
		self:SendFlower(pNpc, nMemberCount);
		Setting:RestoreGlobalObj();
	end
end

function tbWomenday_2011:CheckFullCard(pPlayer)
	local nCount = 0;	
	for _, tbLine in ipairs(tbWomenday_2011.TASK_CARD) do
		for _, tbTaskId in ipairs(tbLine) do
			if pPlayer.GetTask(self.TASK_GID, tbTaskId[1]) == 1 then
				nCount = nCount + 1;
			end
		end
	end
	if nCount >= self.MAX_NPC_COUNT then
		return 1;
	end
	return 0;
end

local tbItem = Item:GetClass("womenday_card_2011");

function tbItem:OnUse()
	
	if tbWomenday_2011:CheckFullCard(me) ~= 1 then
		Dialog:Say("对不起，你没有点亮卡片上所有的名字，无法兑换奖励。");
		return 0;
	end
	
	local nNeed = 2;
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("请留出%s格背包空间。", nNeed));
		return 0;
	end

--  2011年妇女节	
--	if me.nSex == 1 then
--		me.AddTitle(unpack(tbWomenday_2011.TITLE_ID));
--		me.SetCurTitle(unpack(tbWomenday_2011.TITLE_ID));
--		if MathRandom(1, 100) == 1 then
--			me.AddItem(unpack(tbWomenday_2011.MARK_ID));
--			me.SendMsgToFriend(string.format("%s幸运的获得了神秘面具。", me.szName));
--		end
--	end
	
	for _, tbLine in ipairs(tbWomenday_2011.TASK_CARD) do
		for _, tbTaskId in ipairs(tbLine) do
			me.SetTask(tbWomenday_2011.TASK_GID, tbTaskId[1], 0);
		end
	end
	
	local tbItemId = tbWomenday_2011.SEX_BOX_ID[me.nSex];
	local pItem = me.AddItem(unpack(tbItemId));
	
	me.SetTask(tbWomenday_2011.TASK_GID, tbWomenday_2011.TASK_GET_CARD, 0);
	me.SetTask(tbWomenday_2011.TASK_GID, tbWomenday_2011.TASK_DAY_AWARD, 1);
	Dialog:SendBlackBoardMsg(me, string.format("你点亮了卡册上所有的名字，获得了一个<color=yellow>%s<color>", pItem.szName));
	
	-- log
	Dbg:WriteLog("womenday_2011", "2012美女节", me.szAccount, me.szName, "领取宝箱");
	StatLog:WriteStatLog("stat_info", "funvjie2012", "gain", me.nId, 1);
	
	return 1;
end

-- 每日事件
function tbWomenday_2011:DailyEvent_GS()
	me.SetTask(self.TASK_GID, self.TASK_DAY_AWARD, 0);
	me.SetTask(self.TASK_GID, self.TASK_DAY_FLOWER, 0);
end

-- 注册事件
PlayerSchemeEvent:RegisterGlobalDailyEvent({SpecialEvent.Womenday_2011.DailyEvent_GS, SpecialEvent.Womenday_2011});
Npc:RegisterSpecDialog(tbWomenday_2011.tbNpcGroup, tbWomenday_2011.OnDialog, tbWomenday_2011.CheckIsOpen, tbWomenday_2011, "<color=yellow>[活动]情意半边天<color>");
