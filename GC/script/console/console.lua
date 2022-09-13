--¿ØÖÆÌ¨
--Ëï¶àÁ¼


Require("\\script\\console\\console_def.lua");
Require("\\script\\console\\console_global.lua");

if (not MODULE_GC_SERVER) then
Require("\\script\\console\\console_gs.lua");
Require("\\script\\console\\console_base_gs.lua");
end


if (MODULE_GC_SERVER) then
Require("\\script\\console\\console_gc.lua");
Require("\\script\\console\\console_base_gc.lua");
end

