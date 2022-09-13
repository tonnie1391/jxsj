do return end

Require("\\script\\event\\manager\\define.lua");

local EventKind = {};
EventManager.EventKind.Npc.DropItem = EventKind;

function EventKind:ExeStartFun()
	local nFlag, szMsg = EventManager.tbFun:ExeParam(self.tbEventPart.tbParam);
	if nFlag == 1 then
		return 0;
	end	
	return 0;
end

function EventKind:ExeEndFun()
	local tbNpcName = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "DropNpc", 1);
	for nNpc, nNpcId in pairs(tbNpcName) do
		local tbNpc = EventManager:GetNpcClass(tonumber(nNpcId))
		if tbNpc then
			local tbDropItem = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "EventDropItem", 1);
			local tbDropRate = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "Droprate", 1);
			
			if #tbDropItem > 0 then
				local tbParamTemp = Lib:SplitStr(tbDropItem[1], ",");
				local nDropParam = tonumber(tbParamTemp[1]);
				for i, varPrarm in pairs(tbNpc.tbDropParam) do
					if varPrarm == nDropParam then
						table.remove(tbNpc.tbDropSum, i);
						table.remove(tbNpc.tbMaxProb, i);
						table.remove(tbNpc.tbDropType, i);
						table.remove(tbNpc.tbDropParam, i);
						table.remove(tbNpc.tbParam, i);
						break;
					end
				end
				if #tbNpc.tbDropParam <= 0 then
					tbNpc.OnEventDeath = nil;
				end				
			end
			if #tbDropRate > 0 then
				local tbParamTemp = Lib:SplitStr(tbDropRate[1], ",");
				local szDropParam = tostring(tbParamTemp[1]);
				for i, varPrarm in pairs(tbNpc.tbDropParam) do
					if varPrarm == szDropParam then
						table.remove(tbNpc.tbDropSum, i);
						table.remove(tbNpc.tbMaxProb, i);
						table.remove(tbNpc.tbDropType, i);
						table.remove(tbNpc.tbDropParam, i);
						table.remove(tbNpc.tbParam, i);
						break;
					end
				end
				if #tbNpc.tbDropParam <= 0 then
					tbNpc.OnEventDeath = nil;
				end				
			end
		end
	end	
	
	tbNpcName = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "DropNpcType", 1);
	for nNpc, szNpcType in pairs(tbNpcName) do
		local tbNpc = EventManager:GetNpcClass(tostring(szNpcType))
		if tbNpc then
			local tbDropItem = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "EventDropItem", 1);
			local tbDropRate = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "Droprate", 1);
			
			if #tbDropItem > 0 then
				local tbParamTemp = Lib:SplitStr(tbDropItem[1], ",");
				local nDropParam = tonumber(tbParamTemp[1]);
				for i, varPrarm in pairs(tbNpc.tbDropParam) do
					if varPrarm == nDropParam then
						table.remove(tbNpc.tbDropSum, i);
						table.remove(tbNpc.tbMaxProb, i);
						table.remove(tbNpc.tbDropType, i);
						table.remove(tbNpc.tbDropParam, i);
						table.remove(tbNpc.tbParam, i);
						break;
					end
				end
				if #tbNpc.tbDropParam <= 0 then
					tbNpc.OnEventDeath = nil;
				end				
			end
			if #tbDropRate > 0 then
				local tbParamTemp = Lib:SplitStr(tbDropRate[1], ",");
				local szDropParam = tostring(tbParamTemp[1]);
				for i, varPrarm in pairs(tbNpc.tbDropParam) do
					if varPrarm == szDropParam then
						table.remove(tbNpc.tbDropSum, i);
						table.remove(tbNpc.tbMaxProb, i);
						table.remove(tbNpc.tbDropType, i);
						table.remove(tbNpc.tbDropParam, i);
						table.remove(tbNpc.tbParam, i);
						break;
					end
				end
				if #tbNpc.tbDropParam <= 0 then
					tbNpc.OnEventDeath = nil;
				end				
			end
		end
	end	
	
	return 0;
end
