-- 文件名　：songjin.lua
-- 创建者　：FanZai
-- 创建时间：2007-10-18 21:35:17
-- 文件说明：宋金道具


------------------------------------------------------------------------------------------
-- initialize

Require("\\script\\item\\class\\skillitem.lua");
Require("\\script\\item\\class\\medicine.lua");

local tbSongjinSkillitem	= Item:NewClass("songjinskillitem", "skillitem")
local tbSongjinMedicine		= Item:NewClass("songjinmedicine", "medicine")

