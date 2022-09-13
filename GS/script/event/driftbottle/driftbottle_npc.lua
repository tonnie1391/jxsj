-------------------------------------------------------
-- 文件名　：driftbottle_npc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-12-02 17:40:05
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\driftbottle\\driftbottle_def.lua");

local tbNpc = Npc:GetClass("drift_bottle_npc");

function tbNpc:OnDialog()
	if DriftBottle:CheckIsOpen() ~= 1 then
		return 0;
	end
	if me.nLevel < 60 then
		Dialog:Say("对不起，你的等级不满60，无法许愿。");
		return 0;
	end
	self:CloseAllWindow();
	me.CallClientScript({"UiManager:OpenWindow", "UI_DRIFT_MAIN"});
end

function tbNpc:CloseAllWindow()
	me.CallClientScript({"UiManager:CloseWindow", "UI_DRIFT_MAIN"});
	me.CallClientScript({"UiManager:CloseWindow", "UI_DRIFT_PICK"});
	me.CallClientScript({"UiManager:CloseWindow", "UI_DRIFT_MINE"});
	me.CallClientScript({"UiManager:CloseWindow", "UI_DRIFT_MARK"});
	me.CallClientScript({"UiManager:CloseWindow", "UI_DRIFT_NEW"});
	me.CallClientScript({"UiManager:CloseWindow", "UI_DRIFT_REPLY"});
	me.CallClientScript({"UiManager:CloseWindow", "UI_DRIFT_MINE_SHOW"});
	me.CallClientScript({"UiManager:CloseWindow", "UI_DRIFT_MARK_SHOW"});
end
