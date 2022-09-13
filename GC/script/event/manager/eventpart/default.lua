Require("\\script\\event\\manager\\define.lua");

local EventKind = {};
EventManager.EventKind.Module.default = EventKind;

function EventKind:ExeStartFun()
	
	local nFlag, szMsg = EventManager.tbFun:ExeParamWithOutPlayer(self.tbEventPart.tbParam);
	if nFlag and nFlag ~= 0 then
		return 0;
	end	

	return 0;	

end

function EventKind:ExeEndFun()
	local nEventId 	= self.tbEvent.nId;
	local nPartId 	= self.tbEventPart.nId;
	local tbNpcName = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "DropNpc", 1);
	for nNpc, nNpcId in pairs(tbNpcName) do
		local tbNpc = EventManager:GetNpcClass(tonumber(nNpcId))
		if tbNpc then
			local tbDropItem = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "SetDropItemId", 1);
			local tbDropRate = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "SetDroprate", 1);
	
			for _, szDropItem in pairs(tbDropItem) do
				local tbParamTemp = EventManager.tbFun:SplitStr(szDropItem);
				local nDropParam = tonumber(tbParamTemp[1]);
				for i, varPrarm in pairs(tbNpc.tbDropParam) do
					if varPrarm == nDropParam and tbNpc.tbEventList[i] == (nEventId * 10000 + nPartId) then
						table.remove(tbNpc.tbDropSum, i);
						table.remove(tbNpc.tbMaxProb, i);
						table.remove(tbNpc.tbDropType, i);
						table.remove(tbNpc.tbDropParam, i);
						table.remove(tbNpc.tbParam, i);
						table.remove(tbNpc.tbEventList, i);
						break;
					end
				end
				if #tbNpc.tbDropParam <= 0 then
					tbNpc.OnEventDeath = nil;
				end	
			end
			for _, szDropItem in pairs(tbDropRate) do
				local tbParamTemp = EventManager.tbFun:SplitStr(szDropItem);
				local szDropParam = tostring(tbParamTemp[1]);
				for i, varPrarm in pairs(tbNpc.tbDropParam) do
					if varPrarm == szDropParam and tbNpc.tbEventList[i] == (nEventId * 10000 + nPartId) then
						table.remove(tbNpc.tbDropSum, i);
						table.remove(tbNpc.tbMaxProb, i);
						table.remove(tbNpc.tbDropType, i);
						table.remove(tbNpc.tbDropParam, i);
						table.remove(tbNpc.tbParam, i);
						table.remove(tbNpc.tbEventList, i);
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
		local tbNpc = EventManager:GetNpcClass(tostring(EventManager.tbFun:SplitStr(szNpcType)[1]))
		if tbNpc then
			local tbDropItem = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "SetDropItemId", 1);
			local tbDropRate = EventManager.tbFun:GetParam(self.tbEventPart.tbParam, "SetDroprate", 1);
			
			for _, szDropItem in pairs(tbDropItem) do
				local tbParamTemp = EventManager.tbFun:SplitStr(szDropItem);
				local nDropParam = tonumber(tbParamTemp[1]);
				for i, varPrarm in pairs(tbNpc.tbDropParam) do
					if varPrarm == nDropParam and tbNpc.tbEventList[i] == (nEventId * 10000 + nPartId) then
						table.remove(tbNpc.tbDropSum, i);
						table.remove(tbNpc.tbMaxProb, i);
						table.remove(tbNpc.tbDropType, i);
						table.remove(tbNpc.tbDropParam, i);
						table.remove(tbNpc.tbParam, i);
						table.remove(tbNpc.tbEventList, i);
						break;
					end
				end
				if #tbNpc.tbDropParam <= 0 then
					tbNpc.OnEventDeath = nil;
				end				
			end
			for _, szDropItem in pairs(tbDropRate) do
				local tbParamTemp = Lib:SplitStr(szDropItem);
				local szDropParam = tostring(tbParamTemp[1]);
				for i, varPrarm in pairs(tbNpc.tbDropParam) do
					if varPrarm == szDropParam and tbNpc.tbEventList[i] == (nEventId * 10000 + nPartId) then
						table.remove(tbNpc.tbDropSum, i);
						table.remove(tbNpc.tbMaxProb, i);
						table.remove(tbNpc.tbDropType, i);
						table.remove(tbNpc.tbDropParam, i);
						table.remove(tbNpc.tbParam, i);
						table.remove(tbNpc.tbEventList, i);
						break;
					end
				end
				if #tbNpc.tbDropParam <= 0 then
					tbNpc.OnEventDeath = nil;
				end				
			end
		end
	end	
	local nFlag, szMsg = EventManager.tbFun:ExeParamCloseEvent(self.tbEventPart.tbParam);
	if nFlag and nFlag ~= 0 then
		return 0;
	end	
	return 0;
end

function EventKind:ExeNpcStartFun(tbParam)
	local tbNpc = tbParam[1];
	--执行召唤怪物开始；
	if type(tbNpc) ~= "table" then
		return 0;
	end
	local nMapId 	= tbNpc.nMapId;
	local nPosX 	= tbNpc.nPosX;
	local nPosY 	= tbNpc.nPosY;
	local nNpcId 	= tbNpc.nNpcId;
	local nLevel 	= tbNpc.nLevel;
	local nSeries 	= tbNpc.nSeries;
	local szAnnouce = tbNpc.szAnnouce;
	local szName	= tbNpc.szName;
	if SubWorldID2Idx(nMapId) < 0 then
		return 0;
	end
	local pNpc	= KNpc.Add2(nNpcId, nLevel, nSeries, nMapId, nPosX, nPosY);
	if pNpc then
		if self.tbNpcId  == nil then
			self.tbNpcId ={};
		end
		table.insert(self.tbNpcId, pNpc.dwId);
		if szName ~= "" then
			pNpc.szName = szName;
		end
		if szAnnouce ~= "" then
			KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szAnnouce);
		end
	end
	return 0;
end

function EventKind:ExeNpcEndFun()
	--执行召唤怪物结束;
	if self.tbNpcId ~= nil then
		for ni, nNpcId in ipairs(self.tbNpcId) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.Delete();
			end
		end
	end
	self.tbNpcId = {};
	return 0;
end

function EventKind:OnDialog(nCheck)
	local tbGRoleArgs = Dialog:GetMyDialog().tbGRoleArgs;
	local nSetGlobalObj = 0;
	if tbGRoleArgs then
		if tbGRoleArgs.npcId then
			local pNpc = KNpc.GetById((tbGRoleArgs.npcId)or 0);
			if pNpc then
				Setting:SetGlobalObj(nil, pNpc);
				nSetGlobalObj = 1;
			end
		end
	end
	
	local nFlag, szMsg = EventManager.tbFun:CheckParam(self.tbEventPart.tbParam);
	if nFlag and nFlag ~= 0 then
		if szMsg then
			Dialog:Say(szMsg);
		end
		if nSetGlobalObj == 1 then
			Setting:RestoreGlobalObj();
		end		
		return 0;
	end
		
	local tbSelect 	 = EventManager.tbFun:GetParam(self.tbEventPart.tbParam,"AddSelect", 1)
	if nCheck == nil and #tbSelect > 0 then
		local tbParam = EventManager.tbFun:SplitStr(tbSelect[1]);
		local tbOpt = {
				{tbParam[2] or "确定领取", self.OnDialog, self, 1},
				{EventManager.DIALOG_CLOSE},
			};
		Dialog:Say(EventManager.tbFun:StrVal(tbParam[1]) or "您好，有什么需要帮助吗？", tbOpt);
		if nSetGlobalObj == 1 then
			Setting:RestoreGlobalObj();
		end		
		return 0;
	end	
	--local nFlag, szMsg = EventManager.tbFun:CheckParam(self.tbEventPart.tbParam);
	--if nFlag and nFlag ~= 0 then
	--	if szMsg then
	--		Dialog:Say(szMsg);
	--	end
	--	return 0;
	--end		
	nFlag, szMsg = EventManager.tbFun:ExeParam(self.tbEventPart.tbParam);
	if nFlag and nFlag ~= 0 then
		if szMsg then
			me.Msg(szMsg);
		end
		if nSetGlobalObj == 1 then
			Setting:RestoreGlobalObj();
		end		
		return 0;
	end
	--Dialog:Say("您领取成功。");
	if nSetGlobalObj == 1 then
		Setting:RestoreGlobalObj();
	end
	return 0;
end

function EventKind:OnUse()
	--物品使用脚本
	local nFlag, szMsg = EventManager:GotoEventPartTable(self.tbEvent.nId, self.tbEventPart.nId, 0, nil, nil, nil, 1);
	if nFlag and nFlag ~= 0 then
		if szMsg then
			me.Msg(szMsg);
			Dialog:SendBlackBoardMsg(me, szMsg);
		end
		return 0;
	end
	return 1;
end

function EventKind:PickUp()
	--拾取执行脚本
	return 1;	
end

function EventKind:IsPickable()
	--是否允许拾取
	return 1;
end

function EventKind:InitGenInfo()
	--拾取执行脚本
	return {};
end
