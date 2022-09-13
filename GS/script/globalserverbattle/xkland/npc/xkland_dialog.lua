-------------------------------------------------------
-- 文件名　：xkland_dialog.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-05-13 18:03:16
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\xkland\\xkland_def.lua");

local tbNpc = Npc:GetClass("xkland_city");

function tbNpc:OnDialog()
	Xkland.Npc:OnDialogCity();
end

local tbNpc = Npc:GetClass("xkland_jieyin");

function tbNpc:OnDialog()
	Xkland.Npc:OnDialogLand();
end

local tbNpc = Npc:GetClass("xkland_chefu");

function tbNpc:OnDialog()
	Xkland.Npc:OnDialogChefu();
end

local tbNpc = Npc:GetClass("xkland_trader");

function tbNpc:OnDialog()
	Xkland.Npc:OnDialogTrader();
end

local tbNpc = Npc:GetClass("xkland_task");

function tbNpc:OnDialog()
	Xkland.Npc:OnDialogTask();
end
