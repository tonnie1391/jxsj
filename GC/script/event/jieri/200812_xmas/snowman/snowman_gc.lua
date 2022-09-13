-- 文件名　：snowman_gc.lua
-- 创建者　：zounan
-- 创建时间：2009-11-24 14:38:02
-- 描  述  ：

if not MODULE_GC_SERVER then
	return;
end

function SpecialEvent:Xmas2008_StartSnow()
	GlobalExcute{"SpecialEvent.Xmas2008.XmasSnowman:StartSnow"};
end 

function SpecialEvent:Xmas2008_StartAward()
	GlobalExcute{"SpecialEvent.Xmas2008.XmasSnowman:StartAward"};
end 
