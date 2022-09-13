if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\201201_springfestival\\201201_springfestival_def.lua");

SpecialEvent.SpringFestival2012 = SpecialEvent.SpringFestival2012 or {};
local SpringFestival = SpecialEvent.SpringFestival2012;


-- 汤圆盛宴
local tbNpc = Npc:GetClass("table2012");

function tbNpc:OnDialog()
	if SpringFestival:IsYuanxiaoOpen() ~= 1 then
		Dialog:Say("对不起，活动已经结束。");
		return 0;
	end
	if me.nLevel < 50 then
		Dialog:Say("你还没有达到50级,不能参加此活动。");
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
		szMsg = string.format("这是<color=yellow>\t%s<color>制作的汤圆宴席，快请%s位好友或家族帮会成员来尝尝吧！\n\n", szOwner,SpringFestival.nCanEatMaxCountPerTable);
		if nLeft > 0 then
			table.insert(tbOpt, 1, {"<color=gray>领取奖励<color>",self.GetOwnerAward,self,him.dwId});
		else
			table.insert(tbOpt, 1, {"<color=yellow>领取奖励<color>",self.GetOwnerAward,self,him.dwId});
		end

	else
		local nLastEatTime = me.GetTask(SpringFestival.nTaskGroupId, SpringFestival.nLastEatYuanxiaoTimeTaskId);
		if os.date("%Y%m%d",GetTime()) ~= os.date("%Y%m%d",nLastEatTime) then
			me.SetTask(SpringFestival.nTaskGroupId, SpringFestival.nLastEatYuanxiaoTimeTaskId,GetTime());
			me.SetTask(SpringFestival.nTaskGroupId, SpringFestival.nEatYuanxiaoCountTaskId,0);
		end
		local nEat = me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nEatYuanxiaoCountTaskId);
		szMsg = string.format("<color=yellow>\t%s<color>制作了一桌汤圆宴席，快来尝尝吧。凉了就不能吃了，数量有限，只有%s人份，先到先得！\n    您今天还可享用<color=green>%s<color>碗汤圆\n\n", szOwner,SpringFestival.nCanEatMaxCountPerTable,SpringFestival.nCanEatYuanxiaoMaxPerDay - nEat);
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
		Dialog:Say("对不起，这不是你摆下的汤圆宴席。");
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
	me.AddItem(unpack(SpringFestival.tbDropYuanxiaoPrizeGdpl));
	me.AddExp(me.GetBaseAwardExp() * 180);
	pNpc.Delete();
	Dialog:SendBlackBoardMsg(me,string.format("恭喜您，获得了<color=yellow>%s<color>！",KItem.GetNameById(unpack(SpringFestival.tbDropYuanxiaoPrizeGdpl))));
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
	local nTotal = me.GetTask(SpringFestival.nTaskGroupId,SpringFestival.nEatYuanxiaoTotalCountTaskId);
	if nTotal >= SpringFestival.nCanEatYuanxiaoMaxTotal then
		Dialog:Say(string.format("你已经吃满了%s个汤圆，无法继续吃了。",SpringFestival.nCanEatYuanxiaoMaxTotal));
		return 0;
	end
	local nEat = me.GetTask(SpringFestival.nTaskGroupId, SpringFestival.nEatYuanxiaoCountTaskId);
	if nEat >= SpringFestival.nCanEatYuanxiaoMaxPerDay then
		Dialog:Say("对不起，你今天已经吃的够多了，请明天再来吃吧。\n(每人每天最多可食用15次汤圆)");
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
	me.SetTask(SpringFestival.nTaskGroupId, SpringFestival.nEatYuanxiaoCountTaskId, nEat + 1);
	me.SetTask(SpringFestival.nTaskGroupId,SpringFestival.nEatYuanxiaoTotalCountTaskId, nTotal + 1);
	StatLog:WriteStatLog("stat_info", "spring_2012","desk_use",me.nId,szOwner);
	pNpc.GetTempTable("SpecialEvent").nLeft = nLeft - 1;
	if pNpc.GetTempTable("SpecialEvent").nLeft <= 0 then
		local pOwner = KPlayer.GetPlayerByName(szOwner);
		if pOwner then
			pOwner.Msg("你的5位朋友对你的汤圆赞不绝口，请点击宴席领取奖励！");
			Dialog:SendBlackBoardMsg(pOwner,"你的5位朋友对你的汤圆赞不绝口，请点击宴席领取奖励");
		end
	end
	if MathRandom(5) <= 1 then
		me.AddItem(unpack(SpringFestival.tbEatYuanxiaoPrizeGdpl));
		Dialog:SendBlackBoardMsg(me,string.format("恭喜您，获得了<color=yellow>%s<color>！",KItem.GetNameById(unpack(SpringFestival.tbEatYuanxiaoPrizeGdpl))));
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
