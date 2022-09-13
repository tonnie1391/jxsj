-- 文件名　：zhenzai_gc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-04-15 17:01:29
-- 描  述  ：赈灾gc

Require("\\script\\event\\specialevent\\ZhenZai\\ZhenZai_def.lua");
SpecialEvent.ZhenZai = SpecialEvent.ZhenZai or {};
local ZhenZai = SpecialEvent.ZhenZai or {};

if not MODULE_GC_SERVER then
	return;
end

--增加许愿树
function SpecialEvent:AddZhenZaiVow_2010()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData >= ZhenZai.VowTreeOpenTime and nData <= ZhenZai.VowTreeCloseTime then	--活动期间内		
		local nCount = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_ZHENZAI_VOWNUM);
		if nCount >= ZhenZai.nTrapNumber  then			--数量超过了1001则重置全局变量(伪重新加载npc) 		
	 		KGblTask.SCSetDbTaskInt(DBTASD_EVENT_ZHENZAI_VOWNUM, 0);	 			 	
		end
		GlobalExcute{"SpecialEvent.ZhenZai:AddVowTree"};
	end
end

--删除许愿树
function SpecialEvent.DeleteZhenZaiVow_2010()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData > ZhenZai.VowTreeCloseTime then			--活动结束
		GlobalExcute{"SpecialEvent.ZhenZai:DeleteVowTree"};
	end		
end

--许愿树全局服务器数量加1
function ZhenZai:AddGTask(nPlayerId)
	local nCount = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_ZHENZAI_VOWNUM) + 1;
	if nCount == ZhenZai.nTrapNumber then 
		GlobalExcute{"SpecialEvent.ZhenZai:OnSpecialAward",nPlayerId};
	end
	
	KGblTask.SCSetDbTaskInt(DBTASD_EVENT_ZHENZAI_VOWNUM, nCount);	
end
