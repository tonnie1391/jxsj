-------------------------------------------------------
-- 文件名　：qingren_2011_item.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-01-06 17:27:15
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\201102_qingren\\qingren_2011_def.lua");

-- 玫瑰花
local tbItem = Item:GetClass("rose2011");
local tbQingren_2011 = SpecialEvent.Qingren_2011;

function tbItem:OnUse()
	
	if tbQingren_2011:CheckIsOpen() ~= 1 then
		Dialog:Say("对不起，活动已经结束，无法再赠送玫瑰花，您可将其卖给商人。");
		return 0;
	end
	
	local tbMemberList, nMemberCount = me.GetTeamMemberList();
	if not tbMemberList or nMemberCount <= 1 then
		Dialog:Say("对不起，请与异性组队后使用。");
		return 0;
	end
	
	local szMsg = "请选择赠送的对象";
	local tbOpt = {};
	
	for _, pMember in pairs(tbMemberList) do
		if pMember.szName ~= me.szName then
			local szName = (pMember.nSex == me.nSex) and string.format("<color=gray>%s<color>", pMember.szName) or pMember.szName;
			table.insert(tbOpt, {szName, self.OnSelect, self, pMember.szName, it.dwId});
		end
	end
	
	table.insert(tbOpt, {"Để ta suy nghĩ thêm"});
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:OnSelect(szPlayerName, dwItemId, nSure)
	
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if not pPlayer then
		return 0;
	end
	
	if tbQingren_2011:CheckSendRose(me, pPlayer) ~= 1 then
		return 0;
	end
	
	if not nSure then
		local nFriend = me.IsFriendRelation(szPlayerName);
		local szMsg = (nFriend == 1) 
			and string.format("你确定赠送给好友<color=yellow>%s<color>么？\n（赠送给好友将累计亲密度点数，2月15日-2月21日可领取总点数排行榜奖励）", szPlayerName) 
			or string.format("%s<color=yellow>不是你的好友<color>，你确定赠送吗？\n（赠送给好友将累计亲密度点数，2月15日-2月21日可领取总点数排行榜奖励）", szPlayerName);
		local tbOpt = 
		{
			{"Xác nhận", self.OnSelect, self, szPlayerName, dwItemId, 1},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	tbQingren_2011:SendRose(me, pPlayer, dwItemId);
end

