-------------------------------------------------------
-- 文件名　：wldh_battle_gc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-08-26 08:55:59
-- 文件描述：
-------------------------------------------------------

if not MODULE_GC_SERVER then
	return;
end	

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_def.lua");

local tbBattle = Wldh.Battle;

-------------------------------------------------------
-- 常规赛
-------------------------------------------------------

-- 计划任务事件
function Wldh:BattleStart()
	
	if Wldh.Battle:CheckTime() ~= 1 then
		return;
	end
	
	Wldh.Battle:RoundStart_GC();
end

-- 每日对战分组(在战局启动之前)
function Wldh:DivideGroup()
	
	if Wldh.Battle:CheckTime() ~= 1 then
		return;
	end
	
	Wldh.Battle:DivideGroup_GC();
end

-- 排行榜
function Wldh:BattleLeagueRank()
	
	if Wldh.Battle:CheckTime() ~= 1 then
		return;
	end
	
	Wldh.Battle:LeagueRank();
end
-- end

-- 战局启动
function tbBattle:RoundStart_GC()
	
	-- 万一没有表数据，则启动之前再分次组
	if not self.tbGroupIndex then
		self:DivideGroup_GC();
	end
			
	GlobalExcute{"Wldh.Battle:RoundStart_GS", self.tbGroupIndex};
end

-- 战局结束: 胜利1，失败-1，平局0
-- tbResult = {[1] = {szLeagueName1, 1}, [2] = {szLeagueName2,-1}}
function tbBattle:RoundEnd_GC(nBattleIndex, tbResult)
	
	-- 调用战队接口保存成绩
	self:GetResult(tbResult[1][1], tbResult[1][2], tbResult[2][1]);
	self:GetResult(tbResult[2][1], tbResult[2][2], tbResult[1][1]);
end

-- 分组：每次6场比赛，偶数原则，轮空为胜
function tbBattle:DivideGroup_GC()
	
	-- 保证有数据先排次
	self:LeagueRank();
		
	local tbLeague = {};
	for nRank, tbInfo in pairs(self.tbLeagueRank) do
		tbLeague[nRank] = tbInfo.szName;
	end	
	
	-- 第一次打的时候没有排行榜数据
	if #tbLeague <= 0 then
		tbLeague = self:GetLeagueList();
	end
	
	-- 再没有数据就返回
	if #tbLeague <= 0 then
		return;
	end
	
	local nCount = #tbLeague;
	
	-- 最后一名直接胜利
	if math.mod(nCount, 2) == 1 then
		self:GetResult(tbLeague[nCount], self.RESULT_WIN);
	end
	
	nCount = math.floor(nCount / 2);
	
	local tbGroupIndex = {};
	for i = 1, nCount do
		tbGroupIndex[i] = 
		{
			self.tbLGName_GateWay[tbLeague[i * 2 - 1]],
			self.tbLGName_GateWay[tbLeague[i * 2]],
		};
	end
	
	self.tbGroupIndex = tbGroupIndex;
	
	GlobalExcute{"Wldh.Battle:DivideGroup_GS", self.tbGroupIndex};
end

-------------------------------------------------------
-- 总决赛
-------------------------------------------------------

-- 计划任务
function Wldh:FinalStart_1()	
	
	if Wldh.Battle:CheckTime() ~= 2 then
		return;
	end
	
	Wldh.Battle:FinalStart_GC(1);
end

function Wldh:FinalStart_2()
	
	if Wldh.Battle:CheckTime() ~= 2 then
		return;
	end
	
	Wldh.Battle:FinalStart_GC(2);
end

function Wldh:FinalGroup_1()
	
	if Wldh.Battle:CheckTime() ~= 2 then
		return;
	end
	
	Wldh.Battle:FinalGroup_GC(1);
end

function Wldh:FinalGroup_2()
	
	if Wldh.Battle:CheckTime() ~= 2 then
		return;
	end
	
	Wldh.Battle:FinalGroup_GC(2);
end
-- end

-- tbFinalList = { 
--	[1] = {{szLeagueName1, szLeagueName4}, {szLeagueName2, szLeagueName3}}, 
--	[2] = {szLeagueNameF1, szLeagueNameF2},
--	[3] = {szLeagueNameT1},
--}

-- 决赛分组
function tbBattle:FinalGroup_GC(nStep)

	-- 半决赛
	if nStep == 1 then
		
		-- 保证有数据先排次
		self:LeagueRank();
		
		-- 保护: 没有4个队伍
		if #self.tbLeagueRank < 4 then
			return;
		end
			
		local tbFinalList = {{}};
		local tbGroupIndex = {};
	
		-- 取排行榜前4名
		for i = 1, 2 do
			tbGroupIndex[i] = 
			{
				self.tbLGName_GateWay[self.tbLeagueRank[i].szName],
				self.tbLGName_GateWay[self.tbLeagueRank[4 - i + 1].szName],
			};
			tbFinalList[1][i] = 
			{
				self.tbLeagueRank[i].szName,
				self.tbLeagueRank[4 - i + 1].szName,
			};
		end
	
		self.tbGroupIndex = tbGroupIndex;
		self.tbFinalList = tbFinalList;

	-- 决赛
	elseif nStep == 2 then
		
		-- 如果第一场没开起来，那么第二场也开不了
		if not self.tbFinalList then
			return;
		end
		
		self.tbGroupIndex = 
		{ 
			{self.tbLGName_GateWay[self.tbFinalList[2][1]], self.tbLGName_GateWay[self.tbFinalList[2][2]]}
		};
	
	-- 返回，不同步数据 	
	else
		return;
	end
	
	GlobalExcute{"Wldh.Battle:FinalGroup_GS", self.tbGroupIndex, self.tbFinalList, nStep};
end

-- 决赛启动
function tbBattle:FinalStart_GC(nStep)

	if not self.tbGroupIndex then
		self:FinalGroup_GC(nStep);
	end
		
	GlobalExcute{"Wldh.Battle:FinalStart_GS", self.tbGroupIndex, nStep};	
end

-- 战局结束: 胜利1，失败-1，平局0
-- tbResult = {[1] = {szLeagueName1, 1}, [2] = {szLeagueName2,-1}}
function tbBattle:FinalEnd_GC(nBattleIndex, tbResult, nStep)
	
	-- 半决赛
	if nStep == 1 then
		
		if not self.tbFinalList[2] then
			self.tbFinalList[2] = {};
		end
		
		-- 1.保存数据在内存里
		for _, tbLeague in pairs(tbResult) do
			if tbLeague[2] == self.RESULT_WIN then
				self.tbFinalList[2][nBattleIndex] = tbLeague[1];
			end
		end
		
		-- 平局
		if not self.tbFinalList[2][nBattleIndex] then
			self.tbFinalList[2][nBattleIndex] = tbResult[1][1];
		end
		
	-- 总决赛
	elseif nStep == 2 then
		
		if not self.tbFinalList[3] then
			self.tbFinalList[3] = {};
		end
		
		-- 记录冠军
		for _, tbLeague in pairs(tbResult) do
			if tbLeague[2] == self.RESULT_WIN then
				self.tbFinalList[3][1] = tbLeague[1];
			end
		end
		
		-- 平局
		if not self.tbFinalList[3][1] then
			self.tbFinalList[3][1] = tbResult[1][1];
		end
		
		-- 处理最终数据
		self:FinalResult(self.tbFinalList);
		
		-- 排行一次
		self:LeagueRank(1);
		
		-- 跨服全局：记录前4名
		for i = 1, 4 do
			local nGateWay = self.tbLGName_GateWay[self.tbLeagueRank[i].szName];
			SetGlobalSportTask(self.GBTASK_BATTLE_GROUP, self.GBTASK_BATTLE_FINAL[i], nGateWay);
		end
	end
end

function tbBattle:FinalResult(tbFinalList)
	
	for nIndex, tbInfo in pairs(tbFinalList) do
		
		if nIndex == 1 then
			League:SetLeagueTask(self.MATCH_TYPE, tbFinalList[1][1][1], self.LGTASK_FINAL, 3);
			League:SetLeagueTask(self.MATCH_TYPE, tbFinalList[1][1][2], self.LGTASK_FINAL, 3);
			League:SetLeagueTask(self.MATCH_TYPE, tbFinalList[1][2][1], self.LGTASK_FINAL, 3);
			League:SetLeagueTask(self.MATCH_TYPE, tbFinalList[1][2][2], self.LGTASK_FINAL, 3);
			
		elseif nIndex == 2 then
			League:SetLeagueTask(self.MATCH_TYPE, tbFinalList[2][1], self.LGTASK_FINAL, 2);
			League:SetLeagueTask(self.MATCH_TYPE, tbFinalList[2][2], self.LGTASK_FINAL, 2);
			
		elseif nIndex == 3 then
			League:SetLeagueTask(self.MATCH_TYPE, tbFinalList[3][1], self.LGTASK_FINAL, 1);
		end
	end
	
	GlobalExcute{"Wldh.Battle:SyncDate", tbFinalList, 3};	
end

-- 启动事件
function tbBattle:StartEvent()
	
	if Wldh.IS_OPEN == 0 then
		return;
	end
	
	local nTaskId;
 
 	nTaskId = KScheduleTask.AddTask("武林大会团体决赛分组", "Wldh", "FinalGroup_1");
	KScheduleTask.RegisterTimeTask(nTaskId, 1920, 1);
	
	nTaskId = KScheduleTask.AddTask("武林大会团体决赛启动", "Wldh", "FinalStart_1");
	KScheduleTask.RegisterTimeTask(nTaskId, 1930, 1);
	
	nTaskId = KScheduleTask.AddTask("武林大会团体决赛分组", "Wldh", "FinalGroup_2");
	KScheduleTask.RegisterTimeTask(nTaskId, 2050, 1);
	
	nTaskId = KScheduleTask.AddTask("武林大会团体决赛启动", "Wldh", "FinalStart_2");
	KScheduleTask.RegisterTimeTask(nTaskId, 2100, 1);
end

GCEvent:RegisterGCServerStartFunc(Wldh.Battle.StartEvent, Wldh.Battle);
