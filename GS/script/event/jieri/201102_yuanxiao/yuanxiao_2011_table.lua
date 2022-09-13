-------------------------------------------------------
-- 文件名　：yuanxiao_2011_table.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-01-06 17:27:15
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\201102_yuanxiao\\yuanxiao_2011_def.lua");

-- 汤圆盛宴
local tbNpc = Npc:GetClass("table2011");
local tbYuanxiao_2011 = SpecialEvent.Yuanxiao_2011;

function tbNpc:OnDialog()
	
	if tbYuanxiao_2011:CheckIsOpen() ~= 1 then
		Dialog:Say("对不起，活动已经结束。");
		return 0;
	end
	
	if me.nLevel < 60 then
		Dialog:Say("你还没有达到60级哟。");
		return 0;
	end
	
	if me.nFaction <= 0 then
		Dialog:Say("你还没加入门派哟。");
		return 0;
	end
	
	local szOwner = him.GetTempTable("SpecialEvent").szOwner;
	local nLeft = him.GetTempTable("SpecialEvent").nLeft;
	local tbQuest = him.GetTempTable("SpecialEvent").tbQuest;
	
	if not szOwner or not nLeft or not tbQuest then
		him.Delete();
		return 0;
	end

	local szMsg = "";
	local tbOpt = {{"Ta hiểu rồi"}};
	
	if szOwner == me.szName then
		szMsg = string.format("<color=yellow>\t%s<color>的汤圆盛宴，快请5位好友或家族帮会成员来尝尝吧！\n\n", szOwner);
		if nLeft > 0 then
			table.insert(tbOpt, 1, {"<color=gray>领取奖励<color>", self.GetOwnerAward, self, him.dwId});
		else
			table.insert(tbOpt, 1, {"<color=yellow>领取奖励<color>", self.GetOwnerAward, self, him.dwId});
		end

	else
		local nEat = me.GetTask(tbYuanxiao_2011.TASK_GID, tbYuanxiao_2011.TASK_EAT_DINNER);
		szMsg = string.format("<color=yellow>\t%s<color>的汤圆盛宴，快来尝尝吧。凉了就不能吃了，数量有限，只有5人份，先到先得！您今天还可享用<color=green>%s<color>碗汤圆\n\n", szOwner, tbYuanxiao_2011.MAX_EAT_DINNER - nEat);
		if nLeft > 0 then
			table.insert(tbOpt, 1, {"取用汤圆", self.EatDinner, self, him.dwId});
		end
	end
	
	if #tbQuest > 0 then
		szMsg = szMsg .. "已经品尝过的宾客有：\n";
		for _, szQuestName in pairs(tbQuest) do
			szMsg = szMsg .. string.format("    <color=yellow>%s<color>\n", szQuestName);
		end
	end
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetOwnerAward(nNpcId)
	
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	
	local szOwner = pNpc.GetTempTable("SpecialEvent").szOwner;
	local nLeft = pNpc.GetTempTable("SpecialEvent").nLeft;
	local tbQuest = pNpc.GetTempTable("SpecialEvent").tbQuest;
	
	if not szOwner or not nLeft or not tbQuest then
		pNpc.Delete();
		return 0;
	end
	
	if szOwner ~= me.szName then
		Dialog:Say("对不起，这不是你摆下的汤圆盛宴。");
		return 0;
	end
	
	if nLeft ~= 0 then
		Dialog:Say("宾客们还没有吃完所有汤圆，无法领取奖励。");
		return 0;
	end
	
	local nNeed = 1;
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("请留出%s格背包空间。", nNeed));
		return 0;
	end
	
	me.AddItem(unpack(tbYuanxiao_2011.ITEM_JADE_ID));
	me.AddExp(me.GetBaseAwardExp() * 180);
	pNpc.Delete();
	
	Dialog:SendBlackBoardMsg(me, "恭喜您，获得了一颗稀有的金珍珠，赶快打开吧。");
	Dbg:WriteLog("yuanxiao_2011", "2011元宵节", me.szAccount, me.szName, "获得金珍珠");
end

function tbNpc:EatDinner(nNpcId)
	
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	
	local szOwner = pNpc.GetTempTable("SpecialEvent").szOwner;
	local nLeft = pNpc.GetTempTable("SpecialEvent").nLeft;
	local tbQuest = pNpc.GetTempTable("SpecialEvent").tbQuest;
	
	if not szOwner or not nLeft or not tbQuest then
		pNpc.Delete();
		return 0;
	end
	
	if nLeft <= 0 then
		Dialog:Say("对不起，该宴席的汤圆已经被吃完了。");
		return 0;
	end
	
	if self:CheckFriendKinTong(szOwner) ~= 1 then
		Dialog:Say("对不起，只有宴席主人的好友、家族成员、帮会成员才可以取用汤圆。");
		return 0;
	end
	
	local nTotal = me.GetTask(tbYuanxiao_2011.TASK_GID, tbYuanxiao_2011.TASK_TOTAL_EAT);
	if nTotal >= tbYuanxiao_2011.MAX_TOTAL_EAT then
		Dialog:Say("你已经吃满了120个汤圆，无法继续吃了。");
		return 0;
	end
	
	local nEat = me.GetTask(tbYuanxiao_2011.TASK_GID, tbYuanxiao_2011.TASK_EAT_DINNER);
	if nEat >= tbYuanxiao_2011.MAX_EAT_DINNER then
		Dialog:Say("对不起，你今天已经吃饱了，请明天再来吃吧");
		return 0;
	end
	
	for _, szName in pairs(tbQuest) do
		if szName == me.szName then
			Dialog:Say("别贪心，你已经吃过一个了。");
			return 0;
		end
	end
	
	local nNeed = 1;
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("请留出%s格背包空间。", nNeed));
		return 0;
	end

	table.insert(tbQuest, me.szName);
	me.AddExp(me.GetBaseAwardExp() * 60);
	me.SetTask(tbYuanxiao_2011.TASK_GID, tbYuanxiao_2011.TASK_EAT_DINNER, nEat + 1);
	me.SetTask(tbYuanxiao_2011.TASK_GID, tbYuanxiao_2011.TASK_TOTAL_EAT, nTotal + 1);
	StatLog:WriteStatLog("stat_info", "chunjie2011", "yuanxiao", me.nId, "食用汤圆");
	
	pNpc.GetTempTable("SpecialEvent").nLeft = nLeft - 1;
	if pNpc.GetTempTable("SpecialEvent").nLeft <= 0 then
		local pOwner = KPlayer.GetPlayerByName(szOwner);
		if pOwner then
			pOwner.Msg("您的汤圆宴席已被享用完，快去领奖吧！");
			Dialog:SendBlackBoardMsg(pOwner, "您的汤圆宴席已被享用完，快去领奖吧！");
		end
	end
	
	if MathRandom(1, 5) == 1 then
		me.AddItem(unpack(tbYuanxiao_2011.ITEM_JADE_ID));
		Dialog:SendBlackBoardMsg(me, "恭喜您，获得了一颗稀有的金珍珠，赶快打开吧。");
		Dbg:WriteLog("yuanxiao_2011", "2011元宵节", me.szAccount, me.szName, "获得金珍珠");
	end
end

function tbNpc:CheckFriendKinTong(szPlayerName)
	
	if me.IsFriendRelation(szPlayerName) == 1 then
		return 1;
	end
	
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	
	local nKinId = me.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	
	local nTmpKinId = KKin.GetPlayerKinMember(KGCPlayer.GetPlayerIdByName(szPlayerName));
	local pTmpKin = KKin.GetKin(nTmpKinId);
	
	if pKin and pTmpKin and nKinId == nTmpKinId then
		return 1;
	end
	
	local pTong = KTong.GetTong(me.dwTongId);
	local pTmpTong = KTong.GetTong(pPlayer.dwTongId);
	if pTong and pTmpTong and me.dwTongId == pPlayer.dwTongId then
		return 1;
	end
	
	return 0;	
end
