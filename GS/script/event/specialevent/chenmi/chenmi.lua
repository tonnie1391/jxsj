-- 文件名  : chenmi.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-07-01 18:05:57
-- 描述    : 沉迷相关

SpecialEvent.tbChenMi = SpecialEvent.tbChenMi or {};
local tbChenMi = SpecialEvent.tbChenMi or {};

--开关沉迷系统
function tbChenMi:ChangeSwitch(nFlag)
	SetTiredSwitch(nFlag);	
end

--玩家上线打开沉迷界面
function tbChenMi:OpenWindow()
	if GetTiredState() == 1 then
		me.CallClientScript({"UiManager:OpenWindow", "UI_TIREDTIME"});
	end
end

--重启设置开关
function tbChenMi:ServerStartFunc()
	local nState = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_CHENMISWITCH);
	SetTiredSwitch(nState);
end

PlayerEvent:RegisterGlobal("OnLogin", SpecialEvent.tbChenMi.OpenWindow, SpecialEvent.tbChenMi);
ServerEvent:RegisterServerStartFunc(tbChenMi.ServerStartFunc, tbChenMi);