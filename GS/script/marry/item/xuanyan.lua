-------------------------------------------------------
-- 文件名　：xuanyan.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-01-21 10:16:33
-- 文件描述：
-------------------------------------------------------

local tbItem = Item:GetClass("marry_xuanyan");

tbItem.CD_TIME = 300;
tbItem.SYS_TEXT = 
{
	[1] = "世上最遥远的距离，不是生与死的距离，不是天各一方，而是我就站在你面前，你却不知道我想你。",
	[2] = "我真的想你，闭上眼，以为我能忘记，但流下的眼泪，却没有骗到自己……",
	[3] = "分手后不可以做朋友，因为彼此伤害过。不可以做敌人，因为彼此深爱过，所以我们变成了最熟悉的陌生人。",
	[4] = "你是我灵魂的唯一，也许我的表白很老套。但这是我的心里话，就这一辈子，让我好好疼你…… ",
	[5] = "亲爱的，不管你有多任性，有多调皮，俺都会永远让着你，不会让你受一点点委屈，俺会让你永远开心，幸福!",
	[6] = "我知道我现在离你很远！可是我,还是每天给你一声“晚安”。你知道你是我的唯一，现在、将来、永远。",
	[7] = "我要对全世界说，我愿意照顾你一辈子，永远呵护你，我要让你成为全世界最幸福，最快乐的女人。",
};

function tbItem:CanUse()
	
	local tbMemberList, nMemberCount = me.GetTeamMemberList();
	local szErrMsg = "";
	if not tbMemberList or nMemberCount ~= 2 then
		szErrMsg = "必须男女两人组队在一起才能使用纳吉誓言。";
		return 0, szErrMsg;
	end
	
	local pTeamMate = nil;
	for _, pMember in pairs(tbMemberList) do
		if pMember.szName ~= me.szName then
			pTeamMate = pMember;
		end
	end
	
	if not pTeamMate then
		return 0, szErrMsg;
	end
	
	if me.nSex == pTeamMate.nSex then
		szErrMsg = "性别不符，不能使用纳吉誓言。";
		return 0, szErrMsg;
	end
		
	local nNearby = 0;
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId, 50);
	if tbPlayerList then
		for _, pPlayer in ipairs(tbPlayerList) do
			if pPlayer.szName == pTeamMate.szName then
				nNearby = 1;
			end
		end
	end
	
	if nNearby ~= 1 then
		szErrMsg = "你们距离太远了，再靠近一点，靠近一点。。。";
		return 0, szErrMsg;
	end
	
	return 1;
end

function tbItem:OnUse()
	if (Marry:CheckState() == 0) then
		return 0;
	end
	local bCanUse, szErrMsg = self:CanUse();
	if bCanUse ~= 1 then
		if ("" ~= szErrMsg) then
			me.Msg(szErrMsg);
		end
		return 0;
	end
	
	local tbOpt = {};
	local szMsg = "将想对心上人说的话告知全世界吧，你可以选择以下几个句子。";
	local dwItemId = it.dwId;
	for nIndex, szText in ipairs(self.SYS_TEXT) do
		table.insert(tbOpt, {szText, self.SendMsg, self, nIndex, dwItemId});
	end
	
	table.insert(tbOpt, {"Để ta suy nghĩ thêm"});
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:SendMsg(nIndex, dwItemId)
	local pItem = KItem.GetObjById(dwItemId);
	if (not pItem) then
		return 0;
	end
	
	local tbMemberList, nMemberCount = me.GetTeamMemberList();
	if not tbMemberList or nMemberCount ~= 2 then
		return 0;
	end
	
	local pTeamMate = nil;
	for _, pMember in pairs(tbMemberList) do
		if pMember.szName ~= me.szName then
			pTeamMate = pMember;
		end
	end
	
	if not pTeamMate then
		return 0;
	end
	
	local szMsg = string.format("<color=green>【%s】<color>向<color=green>【%s】<color>发出纳吉誓言：<color=gold>%s<color>", me.szName, pTeamMate.szName, self.SYS_TEXT[nIndex]);
	self:BroadcastMsg(szMsg, me, pTeamMate);
	pItem.Delete(me);
	me.SetTask(Marry.TASK_GROUP_ID, Marry.TASK_TIME_XUANYAN, GetTime());
end

function tbItem:BroadcastMsg(szMsg, pAppPlayer, pDstPlayer)
	KDialog.NewsMsg(1, Env.NEWSMSG_COUNT, szMsg, 20);
	pAppPlayer.Msg(szMsg);
	pDstPlayer.Msg(szMsg);
end
