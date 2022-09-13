--固定预先加载的脚本，会是所有脚本加载的第一个
if  MODULE_GAMECLIENT then
	return;
end

print("Preload gc script files...");

-- GS、GC通用
Require("\\script\\misc\\globaltaskdef.lua");
Require("\\script\\misc\\gcevent.lua");
Require("\\script\\misc\\s2gcevent.lua");
Require("\\script\\event\\manager\\define.lua");
Require("\\script\\ladder\\ladder_gc.lua");
Require("\\script\\task\\help\\help.lua");
