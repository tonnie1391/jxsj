-- 文件名  : planting_gc.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2011-02-24 10:05:10
-- 描述    : 
if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\event\\jieri\\201103_zhishujie\\planting_def.lua");

SpecialEvent.tbZhiShu2011 = SpecialEvent.tbZhiShu2011 or {};
local tbZhiShu2011 = SpecialEvent.tbZhiShu2011;

function tbZhiShu2011:SetPlantState(szName, nServerId, nFlag)
	if not nServerId then
		return;
	end
	self.tbPlantInfo[nServerId] = self.tbPlantInfo[nServerId] or {};
	if nFlag == 1 then
		self.tbPlantInfo[nServerId][szName] = GetTime();
	else
		self.tbPlantInfo[nServerId][szName] = nil;
	end
	GlobalExcute({"SpecialEvent.tbZhiShu2011:SetPlantState",szName, nServerId, nFlag});
end

function tbZhiShu2011:SyncData(nServerId)
	print(nServerId)
	if not nServerId then
		return;
	end
	local nFlag = 0;
	for i = 1 , 7 do
		if self.tbPlantInfo[nServerId] and Lib:CountTB(self.tbPlantInfo[nServerId]) > 0 then
			nFlag = 1;
			break;
		end
	end
	if nFlag == 1 then
		self.tbPlantInfo[nServerId] = {};	
		GlobalExcute({"SpecialEvent.tbZhiShu2011:SyncData", nServerId, self.tbPlantInfo});
	end
end

