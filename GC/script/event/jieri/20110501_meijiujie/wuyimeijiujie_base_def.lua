    --
-- FileName: wuyimeijiujie_base_def.lua
-- Author: hanruofei
-- Time: 2011/4/21 20:25
-- Comment:
--

SpecialEvent.tbMeijiujie20110501 =  SpecialEvent.tbMeijiujie20110501 or {};
local tbMeijiujie20110501 = SpecialEvent.tbMeijiujie20110501;

tbMeijiujie20110501.bIsOpen 	= 1; 		-- 美酒节活动开关，主要用于在特殊情况下关闭活动
tbMeijiujie20110501.nStartTime 	= 20110430;	-- 美酒节活动开始时间
tbMeijiujie20110501.nEndTime 	= 20110504;	-- 美酒节活动结束时间
tbMeijiujie20110501.tbTimes = {{[0] = 1000, [1] = 1400}, {[0] = 1800, [1] = 2300,}};  -- [0]Call[1]删除