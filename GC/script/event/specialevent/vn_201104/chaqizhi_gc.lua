-- 文件名　：chaqizhi_gc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-04-06 17:10:07
--插旗

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\event\\specialevent\\vn_201104\\chaqizhi_def.lua");

SpecialEvent.tbChaQi2011 = SpecialEvent.tbChaQi2011 or {};
local tbChaQi2011 = SpecialEvent.tbChaQi2011;

function tbChaQi2011:SetPlantState(szName, nServerId, nFlag)
	if not nServerId then
		return;
	end
	self.tbPlantInfo[nServerId] = self.tbPlantInfo[nServerId] or {};
	if nFlag == 1 then
		self.tbPlantInfo[nServerId][szName] = GetTime();
	else
		self.tbPlantInfo[nServerId][szName] = nil;
	end
	GlobalExcute({"SpecialEvent.tbChaQi2011:SetPlantState",szName, nServerId, nFlag});
end

function tbChaQi2011:SyncData(nServerId)
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
		GlobalExcute({"SpecialEvent.tbChaQi2011:SyncData", nServerId, self.tbPlantInfo});
	end
end

