-- 文件名　：sprintfrestival_gc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-29 10:39:36
-- 描  述  ：新年活动gc

Require("\\script\\event\\jieri\\201001_springfrestival\\springfrestival_def.lua");
SpecialEvent.SpringFrestival = SpecialEvent.SpringFrestival or {};
local SpringFrestival = SpecialEvent.SpringFrestival or {};

if not MODULE_GC_SERVER then
	return;
end

--增加许愿树
function SpecialEvent:AddVowTree_2010()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData >= SpringFrestival.VowTreeOpenTime and nData <= SpringFrestival.VowTreeCloseTime then	--活动期间内		
		local nCount = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_SPRINGFRESTIVAL_VOWNUM);
		if nCount >= SpringFrestival.nTrapNumber  then			--数量超过了1001则重置全局变量(伪重新加载npc) 		
	 		KGblTask.SCSetDbTaskInt(DBTASD_EVENT_SPRINGFRESTIVAL_VOWNUM, 0);	 			 	
		end
		GlobalExcute{"SpecialEvent.SpringFrestival:AddVowTree"};
	end		
end 

--删除许愿树
function SpecialEvent.DeleteVowTree_2010()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData > SpringFrestival.VowTreeCloseTime then			--活动结束
		GlobalExcute{"SpecialEvent.SpringFrestival:DeleteVowTree"};
	end		
end

--城市增加50盏花灯
function SpecialEvent:AddNewYearHuaDeng_2010()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData >= SpringFrestival.HuaDengOpenTime and nData <= SpringFrestival.HuaDengCloseTime then		--活动期间内	
		GlobalExcute{"SpecialEvent.SpringFrestival:AddNewYearHuaDeng"};
	end	
end 

--删除花灯
function SpecialEvent:DeleteNewYearHuaDeng_2010()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData > SpringFrestival.HuaDengCloseTime then		--活动结束
		GlobalExcute{"SpecialEvent.SpringFrestival:DeleteNewYearHuaDeng"};
	end		
end

--许愿树全局服务器数量加1
function SpringFrestival:AddGTask()
	KGblTask.SCSetDbTaskInt(DBTASD_EVENT_SPRINGFRESTIVAL_VOWNUM, KGblTask.SCGetDbTaskInt(DBTASD_EVENT_SPRINGFRESTIVAL_VOWNUM)+1);	
end
