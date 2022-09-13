-------------------------------------------------------------------
--File: 	factionbattle_gs.lua
--Author: 	zhengyuhua
--Date: 	2008-1-8 17:38
--Describe:	门派战--gamecenter端脚本
-------------------------------------------------------------------
-- 开启门派战
function FactionBattle:StartFactionBattle_GS(nModel)
	local nRet = 0
	self.tbData = {};
--	local nCurDate = tonumber(os.date("%d", GetTime()))
--	if nCurDate <= 7  then
--		self.MAX_LEVEL = 150;
--	else
--		self.MAX_LEVEL = 100;
--	end
	self:SetDefByMode(nModel);
	assert(nModel == FactionBattle._MODEL_NEW or nModel == FactionBattle._MODEL_OLD or nModel == FactionBattle._MODEL_96_DAY_WEEK_2);
	if self._MODEL_NEW == nModel then
		assert(self:LoadArenaPoint_New(self.SETTING_PATH) == 1);		-- 进入到晋级场中两个阵营的传入点
		assert(self:LoadBoxPoint_New(self.SETTING_PATH) == 1);		-- 读取箱子的刷点
	end
	assert(self:LoadArenaRange(self.SETTING_PATH..self.ARENA_RANGE) == 1);	-- 读取混战随机范围配置
	assert(self:LoadArenaPoint(self.SETTING_PATH..self.ARENA_POINT) == 1);	-- 读取淘汰定点配置
	assert(self:LoadBoxPoint(self.SETTING_PATH..self.BOX_POINT) == 1);		-- 读取箱子的刷点
	
	if not self.tbBattleFlag then
		self.tbBattleFlag = {}
	end
	for i = 1, Player.FACTION_NUM do
		self.tbBattleFlag[i] = 1;
	end
	
	for nFaction, nMapId in pairs(self.FACTION_TO_MAP) do
		if IsMapLoaded(nMapId) == 1 then	-- 地图加载则开启活动		
			self.tbData[nFaction] = Lib:NewClass(self.tbBaseFaction, nFaction, nMapId);	-- 创建活动数据对象
			nRet = 1;
			
			--额外事件，活动系统
			SpecialEvent.ExtendEvent:DoExecute("Open_FactionBattle", nFaction, nMapId);
		end
	end
	if nRet == 1 then
		self:StartSignUp(nModel);
		-- 记录任务变量
		KGblTask.SCSetDbTaskInt(DATASK_FACTIONBATTLE_MODEL, nModel);
	end

end

function FactionBattle:EndBattle_GS2(nFaction)
	if not self.tbBattleFlag then
		self.tbBattleFlag = {}
	end
	self.tbBattleFlag[nFaction] = 0;
end

function FactionBattle:GetBattleFlag(nFaction)
	if not self.tbBattleFlag then
		self.tbBattleFlag = {}
	end
	return self.tbBattleFlag[nFaction];
end

function FactionBattle:GetFactionData(nFaction)
	if self.tbData then
		return self.tbData[nFaction];
	end
end

-- 启动活动
function FactionBattle:StartSignUp(nModel)
	for i, tbInfo in pairs(self.tbData) do
		tbInfo:TimerStart();
		tbInfo:CheckMap();
	end
	local szMsg = "       Thi đấu môn phái đã mở, hãy đến gặp chưởng môn của mình để vào ghi danh tham dự."
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);
end

-- 离开地图
function FactionBattle:OnLeaveMap(nFaction)
	local tbData = self:GetFactionData(nFaction);
	local nPlayerId = me.nId;
	if tbData then
		local tbAttendPlayer = tbData:GetAttendPlayerTable();
		if tbData:FindAttendPlayer(nPlayerId) == 1 and tbAttendPlayer then		-- 暂时恢复原来状态
			tbData:KickPlayerFromArena(nPlayerId);
			tbData:ResumeNormalState(nPlayerId);
			local tbInfo = tbAttendPlayer[nPlayerId];
			-- 移除称号
			if FactionBattle._MODEL_NEW == FactionBattle.FACTIONBATTLE_MODLE and
				tbInfo.nCamp and FactionBattle.TB_TITLE and
				(tbInfo.nCamp == FactionBattle.CAMP_RED or tbInfo.nCamp == FactionBattle.CAMP_BLUE) then
					
				if me.FindSpeTitle(FactionBattle.TB_TITLE[tbInfo.nCamp][1]) then
					me.RemoveSpeTitle(FactionBattle.TB_TITLE[tbInfo.nCamp][1]);	-- 移除称号
				end
			end
		end
		tbData:DelMapPlayerTable(nPlayerId);
	end
	me.nForbidChangePK = 0;
	me.ForbidEnmity(0);		--仇杀
	me.ForbidExercise(0); 	--切磋 
	me.DisabledStall(0);	--摆摊
end

-- 进入地图
function FactionBattle:OnEnterMap(nFaction, bIsNewWorld)
	self:TrapIn(me);
	me.SetFightState(0);
	me.nPkModel = Player.emKPK_STATE_PRACTISE;
	me.nForbidChangePK = 1;
	me.ForbidEnmity(1);		-- 禁止仇杀
	me.ForbidExercise(1); 	-- 禁止切磋 
	me.DisabledStall(1);	--禁止摆摊
	local tbData = self:GetFactionData(nFaction)
	if tbData then
		tbData:AddMapPlayerTable(me.nId);
		if tbData:FindAttendPlayer(me.nId) == 1 then		-- 设置比赛准备状态
			-- TODO
		end
	end
end

-- 读取各个比赛场地的随机进入点
function FactionBattle:LoadArenaRange(szFullPath)
	self.tbArenaRange = {}
	local tbNumColName = {ARENA_ID = 1, X = 1, Y = 1, RADII = 1};
	local tbFileData = Lib:LoadTabFile(szFullPath, tbNumColName);
	if not tbFileData then
		return 0;
	end
	for nIndex, tbRow in pairs(tbFileData) do
		if not self.tbArenaRange[tbRow.ARENA_ID] then
			self.tbArenaRange[tbRow.ARENA_ID] = {}
		end
		local tbPoint = {nX = tbRow.X, nY = tbRow.Y, nR = tbRow.RADII};	-- 中心X,Y,半径
		table.insert(self.tbArenaRange[tbRow.ARENA_ID], tbPoint);
	end
	return 1;
end

-- 淘汰赛定点载入
function FactionBattle:LoadArenaPoint(szFullPath)
	self.tbArenaPoint = {}
	local tbNumColName = {ARENA_ID = 1, X1 = 1, Y1 = 1, X2 = 1, Y2 = 1};
	local tbFileData = Lib:LoadTabFile(szFullPath, tbNumColName);
	if not tbFileData then
		return 0;
	end
	for nIndex, tbRow in pairs(tbFileData) do
		self.tbArenaPoint[tbRow.ARENA_ID] = {}	-- 有重复定点则会覆盖
		self.tbArenaPoint[tbRow.ARENA_ID][1] = {tbRow.X1, tbRow.Y1};
		self.tbArenaPoint[tbRow.ARENA_ID][2] = {tbRow.X2, tbRow.Y2};
	end
	return 1;
end

-- 加载奖励箱子的刷点
function FactionBattle:LoadBoxPoint(szFullPath)
	self.tbBoxPoint = {}
	local tbNumColName = {GROUP = 1, X = 1, Y = 1};
	local tbFileData = Lib:LoadTabFile(szFullPath, tbNumColName);
	if not tbFileData then
		return 0;
	end
	for nIndex, tbRow in pairs(tbFileData) do
		if not self.tbBoxPoint[tbRow.GROUP] then
			self.tbBoxPoint[tbRow.GROUP] = {}
		end
		local tbPoint = {nX = tbRow.X, nY = tbRow.Y};	-- 中心X,Y,半径
		table.insert(self.tbBoxPoint[tbRow.GROUP], tbPoint);
	end
	return 1;
end

-- 加载奖励箱子的刷点
function FactionBattle:LoadBoxPoint(szFullPath)
	self.tbBoxPoint = {}
	local tbNumColName = {GROUP = 1, X = 1, Y = 1};
	local tbFileData = Lib:LoadTabFile(szFullPath, tbNumColName);
	if not tbFileData then
		return 0;
	end
	for nIndex, tbRow in pairs(tbFileData) do
		if not self.tbBoxPoint[tbRow.GROUP] then
			self.tbBoxPoint[tbRow.GROUP] = {}
		end
		local tbPoint = {nX = tbRow.X, nY = tbRow.Y};	-- 中心X,Y,半径
		table.insert(self.tbBoxPoint[tbRow.GROUP], tbPoint);
	end
	return 1;
end
-- 載入新模式下的宝箱随机点，和晋级赛的传入点
function FactionBattle:LoadBoxPoint_New(szPath)
	self.tbBoxPoint_New = {};
	local szFileName = szPath .. FactionBattle.SZ_BOX_POINT
	local tbNumColName = {TRAPX = 1, TRAPY = 1};
	for i = FactionBattle.N_BAOXIANG_BASE, FactionBattle.N_BAOXIANG_MAX do
		local sz = szFileName .. tostring(i) .. ".txt";
		local tbFileData = Lib:LoadTabFile(sz, tbNumColName);
		if tbFileData then
			self.tbBoxPoint_New[i] = {};
			for k, tbPoint in ipairs(tbFileData) do
				table.insert(self.tbBoxPoint_New[i], tbPoint);
			end
		else
			assert(false, "read tab file failed ".. sz)
		end
	end
	return 1;
end

function FactionBattle:GetBoxPoint_New(nMapIndex)
	return self.tbBoxPoint_New[nMapIndex];
end

-- 载入阵营晋级场的传入点
function FactionBattle:LoadArenaPoint_New(szPath)
	self.tbArenaPoint_New = {};
	local szFileName = szPath .. FactionBattle.SZ_ARENA_POINT;
	local tbNumColName = {TRAPX = 1, TRAPY = 1};
	for i = FactionBattle.N_ZHENYING_BASE, FactionBattle.N_ZHENYING_MAX do
		local sz = szFileName .. tostring(i) .. ".txt";
		local tbFileData = Lib:LoadTabFile(sz, tbNumColName);
		if tbFileData and #tbFileData >= 2 then
			self.tbArenaPoint_New[i] = {};
			self.tbArenaPoint_New[i][FactionBattle.CAMP_RED] = tbFileData[1];
			self.tbArenaPoint_New[i][FactionBattle.CAMP_BLUE] = tbFileData[2];
		else
			assert(false, "read tab file failed ".. sz)
		end
	end
	return 1;
end

function FactionBattle:GetArenaPoint_New(nArena)
	return self.tbArenaPoint_New[nArena];
end
-- 获取某个混战区的一个随机点
function FactionBattle:GetRandomPoint(nArenaId)
	if not self.tbArenaRange or not self.tbArenaRange[nArenaId] then
		return;
	end
	local nArenaRangeNum = #self.tbArenaRange[nArenaId];
	local tbRandomRange = self.tbArenaRange[nArenaId][MathRandom(nArenaRangeNum)];
	if not tbRandomRange then
		return;
	end
	local nAngle = 6.28 * MathRandom()				-- 随机弧度度 3.14 * 2 = 6.28
	local nRadii = MathRandom(tbRandomRange.nR)	-- 随机距离
	local nX = math.floor(math.cos(nAngle) * nRadii + tbRandomRange.nX);
	local nY = math.floor(math.sin(nAngle) * nRadii + tbRandomRange.nY);
	return nX, nY;
end

-- 获取某个淘汰赛区域的两个定点
function FactionBattle:GetElimFixPoint(nArenaId)
	if self.tbArenaPoint and self.tbArenaPoint[nArenaId] then
		return self.tbArenaPoint[nArenaId][1], self.tbArenaPoint[nArenaId][2];
	end
end

-- 关闭活动
function FactionBattle:ShutDown(nFaction)
	if self.tbData and self.tbData[nFaction]then
		self.tbData[nFaction] = nil;
	end
	GCExcute{"FactionBattle:EndBattle_GC" , nFaction};
end

function FactionBattle:ShowMsgToMapPlayer(nFaction, szMsg)
	if self.tbData and self.tbData[nFaction] then 
		self.tbData[nFaction]:MsgToMapPlayer(szMsg);
	end
end

-- 传送玩家至某个传入点
function FactionBattle:TrapIn(pPlayer)
	local nRandom = MathRandom(4);
	if pPlayer and self.REV_POINT[nRandom] then
		pPlayer.NewWorld(self.FACTION_TO_MAP[pPlayer.nFaction], unpack(self.REV_POINT[nRandom]));
	end
end

function FactionBattle:FinalWinner(nFaction, nPlayerId)
	GCExcute{"FactionBattle:FinalWinner_GC", nFaction, nPlayerId};
	-- 冠军旗子
	self:AwardChampionStart(nFaction, nPlayerId);
end


function FactionBattle:ShowCandidate(nFaction)
	local tbCandidate = GetCurCandidate(nFaction);
	print("本月：")
	Lib:ShowTB(tbCandidate);
	tbCandidate = GetLastMonthCandidate(nFaction);
	print("上月:");
	Lib:ShowTB(tbCandidate);
	print("历届:");
	tbCandidate = GetAllElectWinner(nFaction);
	Lib:ShowTB(tbCandidate);
	print("最近:")
	local tbPlayer = GetCurWinner(nFaction);
	if tbPlayer then
		Lib:ShowTB(tbPlayer);
	end
end
