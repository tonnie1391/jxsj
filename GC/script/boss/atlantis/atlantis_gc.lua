-------------------------------------------------------
-- 文件名　：atlantis_gc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-03-23 18:34:03
-- 文件描述：
-------------------------------------------------------

if not MODULE_GC_SERVER then
	return 0;
end

Require("\\script\\boss\\atlantis\\atlantis_def.lua");

function Atlantis:ServerDailyEvent_GC()
	GlobalExcute({"Atlantis:ServerDailyEvent_GS"});
end

function Atlantis:OpenSystem_GC()
	GlobalExcute({"Atlantis:OpenSystem_GS"});
end

function Atlantis:CloseSystem_GC()
	GlobalExcute({"Atlantis:CloseSystem_GS"});
end

function Atlantis:FreshBoss_GC()
	GlobalExcute({"Atlantis:FreshBoss_GS"});
end

