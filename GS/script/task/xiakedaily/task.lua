Require("\\script\\task\\linktask\\linktask_head.lua");

-- 在旅行者服务器中可否完成任务步骤
function Task:IsCanDoTargetSpeCondition(pPlayer, nTaskId, nCurStep)
	return self:IsCanDoTargetOnMyServer(nTaskId, nCurStep);
end

-- 默认都能完成
function Task:IsCanDoTargetOnMyServer(nTaskId, nCurStep)	
	-- 默认不能做
	local tbNotCanDoOnMyServer = self.tbTaskDoTargetServerCondition.tbNotCanDoOnMyServer;
	if (not tbNotCanDoOnMyServer) then
		return 1;
	end

	local tbTaskInfo = tbNotCanDoOnMyServer[nTaskId];
	if (not tbTaskInfo) then
		return 1;
	end
	
	if (not tbTaskInfo[nCurStep]) then
		return 1;
	end
	
	return 0, "Bước nhiệm vụ này không thể hoàn thành trong server này!";
end

function Task:LoadTargetCanDoBySpeCondFile()
	self.tbTaskDoTargetServerCondition = {
			tbNotCanDoOnMyServer = {},
			tbCanDoOnTravelServer = {},
		}
	local tbFile = Lib:LoadTabFile("\\setting\\task\\targetservercondition.txt");
	if (not tbFile) then
		return 0;
	end
	for nId, tbRow in ipairs(tbFile) do
		-- if (nId > 1) then
			local nTaskId	= tonumber(tbRow["TaskId"]) or 0;
			local nTaskStep	= tonumber(tbRow["TaskStep"]) or 0;
			local nIsNotCaDoOnMyServer = tonumber(tbRow["NotCanDoOnMyServer"]);
			local nIsCanDoOnTravel = tonumber(tbRow["CanDoOnTravelServer"]);
			if (nTaskId > 0 and nTaskStep > 0) then
				local tbNotCanDoOnMyServer = self.tbTaskDoTargetServerCondition.tbNotCanDoOnMyServer;
				local tbCanDoOnTravelServer = self.tbTaskDoTargetServerCondition.tbCanDoOnTravelServer;
				if (nIsNotCaDoOnMyServer > 0) then
					if (not tbNotCanDoOnMyServer[nTaskId]) then
						tbNotCanDoOnMyServer[nTaskId] = {};
					end
										
					tbNotCanDoOnMyServer[nTaskId][nTaskStep] = 1;
				end
				
				if (nIsCanDoOnTravel > 0) then
					if (not tbCanDoOnTravelServer[nTaskId]) then
						tbCanDoOnTravelServer[nTaskId] = {};
					end
					tbCanDoOnTravelServer[nTaskId][nTaskStep] = 1;
				end
			end
		-- end
	end
	return 1;
end

Task:LoadTargetCanDoBySpeCondFile();
