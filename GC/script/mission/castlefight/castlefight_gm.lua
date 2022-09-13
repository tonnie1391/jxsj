-- GM
-- zhouchenfei
-- 测试用指令

Require("\\script\\mission\\castlefight\\castlefight_def.lua");

-- 设置加载动态地图数量
function CastleFight:Test_SetDyMapNum(nNum, nSyc)
	if (not nNum) then
		return 0;
	end
	
	if (MODULE_GAMESERVER) then
		if (not nSyc or nSyc ~= 1) then
			GCExcute{"CastleFight:Test_SetDyMapNum", nNum};
			return 1;
		end
	end
	
	
	local tbConsole = self:GetConsole();
	tbConsole.tbCfg.nMaxDynamic = nNum;
	
	if (MODULE_GC_SERVER) then
		GlobalExcute{"CastleFight:Test_SetDyMapNum", nNum, 1};
		return 1;
	end	
end

-- 设置准备场时间
function CastleFight:Test_SetReadyTime(nTime, nSyc)
	if (not nTime) then
		return 0;
	end
	
	if (MODULE_GAMESERVER) then
		if (not nSyc or nSyc ~= 1) then
			GCExcute{"CastleFight:Test_SetReadyTime", nTime};
			return 1;
		end
	end

	local tbConsole = self:GetConsole();
	tbConsole.tbCfg.nReadyTime = nTime;

	if (MODULE_GC_SERVER) then
		GlobalExcute{"CastleFight:Test_SetReadyTime", nTime, 1};
		return 1;
	end
end

-- 设置开启比赛的最少人数
function CastleFight:Test_SetMinOpenMatchNum(nNum, nSyc)
	if (not nNum) then
		return 0;
	end
	
	if (MODULE_GAMESERVER) then
		if (not nSyc or nSyc ~= 1) then
			GCExcute{"CastleFight:Test_SetMinOpenMatchNum", nNum};
			return 1;
		end
	end

	local tbConsole = self:GetConsole();
	tbConsole.tbCfg.nMinDynPlayer = nNum;
	
	if (MODULE_GC_SERVER) then
		GlobalExcute{"CastleFight:Test_SetMinOpenMatchNum", nNum, 1};
		return 1;
	end
end

-- 设置比赛地图最大人数
function CastleFight:Test_SetMaxDynPlayerNum(nNum, nSyc)
	if (not nNum) then
		return 0;
	end
	
	if (MODULE_GAMESERVER) then
		if (not nSyc or nSyc ~= 1) then
			GCExcute{"CastleFight:Test_SetMaxDynPlayerNum", nNum};
			return 1;
		end
	end

	local tbConsole = self:GetConsole();
	tbConsole.tbCfg.nMaxDynPlayer = nNum;
	
	if (MODULE_GC_SERVER) then
		GlobalExcute{"CastleFight:Test_SetMaxDynPlayerNum", nNum, 1};
		return 1;
	end
end

-- 设置准备场最大人数
function CastleFight:Test_SetMaxPlayerNum(nNum, nSyc)
	if (not nNum) then
		return 0;
	end
	
	if (MODULE_GAMESERVER) then
		if (not nSyc or nSyc ~= 1) then
			GCExcute{"CastleFight:Test_SetMaxPlayerNum", nNum};
			return 1;
		end
	end

	local tbConsole = self:GetConsole();
	tbConsole.tbCfg.nMaxPlayer = nNum;
	
	if (MODULE_GC_SERVER) then
		GlobalExcute{"CastleFight:Test_SetMaxPlayerNum", nNum, 1};
		return 1;
	end
end

-- 设置一个队伍最多人数
function CastleFight:Test_SetMaxTeamMemberNum(nNum, nSyc)
	if (not nNum) then
		return 0;
	end
	
	if (MODULE_GAMESERVER) then
		if (not nSyc or nSyc ~= 1) then
			GCExcute{"CastleFight:Test_SetMaxTeamMemberNum", nNum};
			return 1;
		end
	end

	local tbConsole = self:GetConsole();
	tbConsole.tbCfg.nMaxTeamMember = nNum;
	
	if (MODULE_GC_SERVER) then
		GlobalExcute{"CastleFight:Test_SetMaxTeamMemberNum", nNum, 1};
		return 1;
	end
end

function CastleFight:Test_SetOpenTime(nTime, nSyc)
	if (not nTime) then
		return 0;
	end
	
	if (MODULE_GAMESERVER) then
		if (not nSyc or nSyc ~= 1) then
			GCExcute{"CastleFight:Test_SetOpenTime", nTime};
			return 1;
		end
	end

	local tbConsole = self:GetConsole();
	tbConsole.tbCfg.nEventStartTime = nTime;
	
	if (MODULE_GC_SERVER) then
		GlobalExcute{"CastleFight:Test_SetOpenTime", nTime, 1};
		return 1;
	end
end

function CastleFight:Test_SetEndTime(nTime, nSyc)
	if (not nTime) then
		return 0;
	end
	
	if (MODULE_GAMESERVER) then
		if (not nSyc or nSyc ~= 1) then
			GCExcute{"CastleFight:Test_SetEndTime", nTime};
			return 1;
		end
	end

	local tbConsole = self:GetConsole();
	tbConsole.tbCfg.nEventEndTime = nTime;
	
	if (MODULE_GC_SERVER) then
		GlobalExcute{"CastleFight:Test_SetEndTime", nTime, 1};
		return 1;
	end

end

function CastleFight:Test_SetAwardTime(nTime, nSyc)
	if (not nTime) then
		return 0;
	end
	
	if (MODULE_GAMESERVER) then
		if (not nSyc or nSyc ~= 1) then
			GCExcute{"CastleFight:Test_SetAwardTime", nTime};
			return 1;
		end
	end

	local tbConsole = self:GetConsole();
	tbConsole.tbCfg.nEventAwardTime = nTime;
	
	if (MODULE_GC_SERVER) then
		GlobalExcute{"CastleFight:Test_SetAwardTime", nTime, 1};
		return 1;
	end

end

