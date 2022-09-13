-------------------------------------------------------
-- 文件名　 : superbattle_item_pad.lua
-- 创建者　 : zhangjinpin@kingsoft
-- 创建时间 : 2011-06-02 18:46:37
-- 文件描述 :
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\superbattle\\superbattle_def.lua");

local tbPad = Item:GetClass("superbattle_item_pad");

function tbPad:OnUse()
	local szMsg = "Ngươi muốn đổi thứ gì?";
	local tbOpt = {};
	for i, tbInfo in ipairs(SuperBattle.PAD_CHANGE_ID) do
		table.insert(tbOpt, {tbInfo[1], self.Change, self, i, it.dwId});
	end
	tbOpt[#tbOpt + 1] = {"Ta hiểu rồi"};
	Dialog:Say(szMsg, tbOpt);
end

function tbPad:Change(nIndex, dwItemId)
	local pItem = KItem.GetObjById(dwItemId);
	if not pItem then
		return 0;
	end
	local tbInfo = SuperBattle.PAD_CHANGE_ID[nIndex];
	if not tbInfo then
		return 0;
	end
	local nNeed = 1;
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("Hành trang không đủ %s ô trống.", nNeed));
		return 0;
	end
	pItem.Delete(me);
	me.AddItem(unpack(tbInfo[2]));
end
