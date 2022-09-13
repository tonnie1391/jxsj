-------------------------------------------------------
-- 文件名　：marry_gc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-01-05 00:47:57
-- 文件描述：
-------------------------------------------------------

Require("\\script\\marry\\logic\\marry_def.lua");

if (not MODULE_GC_SERVER) then
	return 0;
end

-- 保存数据
function Marry:SaveBuffer_GC()
	SetGblIntBuf(GBLINTBUF_MARRY, 0, 1, self.tbGlobalBuffer);
	self:SyncBuffer_GC();
end

-- 清除数据
function Marry:ClearBuffer_GC()
	self.tbGlobalBuffer = {[1] = {}, [2] = {}, [3] = {}, [4] = {}};
	SetGblIntBuf(GBLINTBUF_MARRY, 0, 1, self.tbGlobalBuffer);
	GlobalExcute({"Marry:ClearBuffer_GS"});
end

-- 同步给gameserver
function Marry:SyncBuffer_GC()
	
	-- 先把所有的都清掉
	GlobalExcute({"Marry:ClearBuffer_GS"});

	-- 同步4个等级的表数据
	for nWeddingLevel, tbMap in pairs(self.tbGlobalBuffer) do
		for nDate, tbRow in pairs(tbMap) do
			-- 平民和贵族有2层
			if nWeddingLevel <= 2 then
				for nIndex, tbInfo in pairs(tbRow) do
					GlobalExcute({"Marry:SyncBuffer_GS", tbInfo, nWeddingLevel, nDate, nIndex});
				end
			-- 王侯和皇家只有1层
			else
				GlobalExcute({"Marry:SyncBuffer_GS", tbRow, nWeddingLevel, nDate});
			end
		end
	end
end

-- 解除求婚的数据
function Marry:SaveProposal_GC()
	SetGblIntBuf(GBLINTBUF_PROPOSAL, 0, 1, self.tbProposalBuffer);
	self:SyncProposal_GC();	
end

-- 清除解除数据
function Marry:ClearProposal_GC()
	self.tbProposalBuffer = {};
	SetGblIntBuf(GBLINTBUF_PROPOSAL, 0, 1, self.tbProposalBuffer);
	GlobalExcute({"Marry:ClearProposal_GS"});
end

-- 同步给gameserver
function Marry:SyncProposal_GC()
	GlobalExcute({"Marry:ClearProposal_GS"});
	for szPreName, szMatchName in pairs(self.tbProposalBuffer) do
		GlobalExcute({"Marry:SyncProposal_GS", szPreName, szMatchName});
	end
end

-- 解除侠侣的数据
function Marry:SaveDivorce_GC()
	SetGblIntBuf(GBLINTBUF_DIVORCE, 0, 1, self.tbDivorceBuffer);
	self:SyncDivorce_GC();	
end

-- 清除解除侠侣数据
function Marry:ClearDivorce_GC()
	self.tbDivorceBuffer = {};
	SetGblIntBuf(GBLINTBUF_DIVORCE, 0, 1, self.tbDivorceBuffer);
	GlobalExcute({"Marry:ClearDivorce_GS"});
end

-- 同步给gameserver
function Marry:SyncDivorce_GC()
	GlobalExcute({"Marry:ClearDivorce_GS"});
	for szPreName, szMatchName in pairs(self.tbDivorceBuffer) do
		GlobalExcute({"Marry:SyncDivorce_GS", szPreName, szMatchName});
	end
end

-- gameserver连接时同步
function Marry:OnRecConnectEvent(nConnectId)	
	for nWeddingLevel, tbMap in pairs(self.tbGlobalBuffer) do
		for nDate, tbRow in pairs(tbMap) do
			if nWeddingLevel <= 2 then
				for nIndex, tbInfo in pairs(tbRow) do
					GSExcute(nConnectId, {"Marry:SyncBuffer_GS", tbInfo, nWeddingLevel, nDate, nIndex});
				end
			else
				GSExcute(nConnectId, {"Marry:SyncBuffer_GS", tbRow, nWeddingLevel, nDate});
			end
		end
	end
	for szPreName, szMatchName in pairs(self.tbProposalBuffer) do
		GSExcute(nConnectId, {"Marry:SyncProposal_GS", szPreName, szMatchName});
	end
	for szPreName, szMatchName in pairs(self.tbDivorceBuffer) do
		GSExcute(nConnectId, {"Marry:SyncDivorce_GS", szPreName, szMatchName});
	end
end

-- 增加解除求婚关系
function Marry:AddProposal_GC(szPreName, szMatchName)
	self.tbProposalBuffer[szPreName] = szMatchName;
	self:SaveProposal_GC();
end

-- 删除解除求婚关系
function Marry:RemoveProposal_GC(szPreName)
	self.tbProposalBuffer[szPreName] = nil;
	self:SaveProposal_GC();
end

-- 增加解除侠侣关系
function Marry:AddDivorce_GC(szPreName, szMatchName)
	self.tbDivorceBuffer[szPreName] = szMatchName;
	self:SaveDivorce_GC();
end

-- 删除解除侠侣关系
function Marry:RemoveDivorce_GC(szPreName)
	self.tbDivorceBuffer[szPreName] = nil;
	self:SaveDivorce_GC();
end

-- 增加婚礼
function Marry:AddWedding_GC(nWeddingLevel, nDate, tbInfo, dwItemId, nTime)
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	-- gc加锁
	if self:CheckAddWedding(nWeddingLevel, nDate) ~= 1 then
		GlobalExcute({"Marry:AddWeddingResult_GS", 0, tbInfo, dwItemId, nTime, nDate});
		return 0;
	end
		
	-- 平民和贵族
	if nWeddingLevel <= 2 then
		
		-- 建立该日期表
		if not self.tbGlobalBuffer[nWeddingLevel][nDate] then
			self.tbGlobalBuffer[nWeddingLevel][nDate] = {};
		end

		-- 判断是否存在数据
		for nIndex, tbRow in pairs(self.tbGlobalBuffer[nWeddingLevel][nDate]) do
			if tbRow[1] == tbInfo[1] and tbRow[2] == tbInfo[2] then
				return 0;
			end
		end
		
		-- 插入表中
		table.insert(self.tbGlobalBuffer[nWeddingLevel][nDate], tbInfo);
		
	-- 王侯和皇家(不用检查重复性了)
	else
		self.tbGlobalBuffer[nWeddingLevel][nDate] = tbInfo;
	end
	
	-- 通知gs预定成功
	GlobalExcute({"Marry:AddWeddingResult_GS", 1, tbInfo, dwItemId, nTime, nDate});
	
	-- 同步数据
	self:SaveBuffer_GC();
end

-- 删除婚礼
function Marry:RemoveWedding_GC(nWeddingLevel, nDate, tbInfo)
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	-- 平民和贵族
	if nWeddingLevel <= 2 then
		if self.tbGlobalBuffer[nWeddingLevel][nDate] then
			for nIndex, tbRow in pairs(self.tbGlobalBuffer[nWeddingLevel][nDate]) do
				if tbRow[1] == tbInfo[1] and tbRow[2] == tbInfo[2] then
					table.remove(self.tbGlobalBuffer[nWeddingLevel][nDate], nIndex);
				end
			end
		end
		
	-- 王侯和皇家
	else
		local tbRow = self.tbGlobalBuffer[nWeddingLevel][nDate];
		if tbRow and tbRow[1] == tbInfo[1] and tbRow[2] == tbInfo[2] then
			self.tbGlobalBuffer[nWeddingLevel][nDate] = nil;
		end
	end
	
	-- 同步数据
	self:SaveBuffer_GC();
end

-- 清除玩家所有婚期
function Marry:RemovePlayerWedding_GC(szPlayerName)
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	for nWeddingLevel, tbMap in pairs(self.tbGlobalBuffer) do
		for nDate, tbRow in pairs(tbMap) do
			if nWeddingLevel <= 2 then
				for nIndex, tbInfo in pairs(tbRow) do
					if tbInfo[1] == szPlayerName or tbInfo[2] == szPlayerName then
						table.remove(self.tbGlobalBuffer[nWeddingLevel][nDate], nIndex);
					end
				end
			elseif tbRow[1] == szPlayerName or tbRow[2] == szPlayerName then
				self.tbGlobalBuffer[nWeddingLevel][nDate] = nil;
			end
		end
	end

	-- 同步数据
	self:SaveBuffer_GC();
end

-- 删除合服婚礼
function Marry:RemoveCozoneWedding_GC(nWeddingLevel, nDate, tbInfo)
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	if self.tbGlobalBuffer[nWeddingLevel][nDate] then
		for nIndex, tbRow in pairs(self.tbGlobalBuffer[nWeddingLevel][nDate]) do
			if tbRow[1] == tbInfo[1] and tbRow[2] == tbInfo[2] then
				table.remove(self.tbCozoneBuffer[nWeddingLevel][nDate], nIndex);
			end
		end
	end
	
	-- 同步数据
	SetGblIntBuf(GBLINTBUF_MARRY_COZONE, 0, 1, self.tbCozoneBuffer);
end

-- 每天中午12点执行，开启所有婚礼场地
-- tbMissionInfo = {MaleName, FemaleName, MapLevel, ServerIndex, MissionIndex, WeddingLevel, StartDate};
function Marry:StartWedding_GC()
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	-- 禁止反复调用
	if self.nStartWedding == 1 then
		return 0;
	end
	
	self.nStartWedding = 1;

	local tbName = {};
	local nCurrDate = tonumber(GetLocalDate("%Y%m%d"));

	for nWeddingLevel, tbMap in pairs(self.tbGlobalBuffer) do
		
		-- 匹配日期的数据表
		local tbRow = tbMap[nCurrDate];
		
		if tbRow then
			-- 平民和贵族有2层
			if nWeddingLevel <= 2 then
				for nIndex, tbInfo in pairs(tbRow) do
					local nRand = MathRandom(1, self.MAX_SERVER);
					self.tbMissionInfo[#self.tbMissionInfo + 1] = 
					{
						MaleName = tbInfo[1], 
						FemaleName = tbInfo[2], 
						MapLevel = tbInfo[3], 
						WeddingLevel = nWeddingLevel,
						MissionIndex = #self.tbMissionInfo + 1,
						ServerIndex = nRand,
						StartDate = nCurrDate,
					};
				end
			-- 王侯和皇家只有1层
			else
				local nRand = MathRandom(1, self.MAX_SERVER);
				self.tbMissionInfo[#self.tbMissionInfo + 1] = 
				{
					MaleName = tbRow[1], 
					FemaleName = tbRow[2], 
					MapLevel = tbRow[3], 
					WeddingLevel = nWeddingLevel,
					MissionIndex = #self.tbMissionInfo + 1,
					ServerIndex = nRand,
					StartDate = nCurrDate,
				};
				tbName[nWeddingLevel] = {tbRow[1], tbRow[2]};
			end
		end
	end
	
	-- 同步给gs
	for _, tbInfo in pairs(self.tbMissionInfo) do
		GlobalExcute({"Marry:SyncMissionInfo_GS", tbInfo});
	end
	
	-- 刷npc
	if Lib:CountTB(tbName) > 0 then
		self:AddSpecNpc_GC(tbName);
	end
	
	-- 下一帧调用
	Timer:Register(1, self.StartWedding_Frame, self);
end

-- 通知所有gs开启婚礼
function Marry:StartWedding_Frame()
	GlobalExcute({"Marry:StartWedding_GS"});
	return 0;
end

-- 每天早上6点执行，关闭执行条件场地
function Marry:CloseWedding_GC()
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	self.nStartWedding = 0;
	self.tbMissionInfo = {};
	
	-- 清所有城市婚礼npc
	self:ClearSpecNpc_GC();
	
	-- 下一帧调用
	Timer:Register(1, self.CloseWedding_Frame, self);
end

-- 通知所有gs关闭婚礼
function Marry:CloseWedding_Frame()
	GlobalExcute({"Marry:CloseWedding_GS"});
	return 0;
end

-- 申请动态地图
function Marry:ApplyDynMap_GC(nDynMapId, nIndex)
	self.tbMissionMap[nIndex] = nDynMapId;
	GlobalExcute({"Marry:SyncMissionMap_GS", self.tbMissionMap});
end

-- 释放动态地图
function Marry:FreeDynMap_GC(nDynMapId, nIndex)
	self.tbMissionMap[nIndex] = nil;
	GlobalExcute({"Marry:SyncMissionMap_GS", self.tbMissionMap});
end

-- 取内存中婚礼预订信息
function Marry:GetMarryInfo(nNeedDate, nEndDate)
	local szMsg = "\n日期\t场地等级\t礼包等级\t结婚新人\t结婚新人";
	nNeedDate = tonumber(nNeedDate) or 0;
	nEndDate = tonumber(nNeedDate) or 0;
	if Marry.tbGlobalBuffer then
		for nLevel, tbData in pairs(Marry.tbGlobalBuffer) do
			for nDate, tbMarrys in pairs(tbData) do
				if tonumber(nDate) >= nNeedDate and (nEndDate == 0 or tonumber(nDate) <= nEndDate) then
					if nLevel <= 2 then
						for _,tbMarry in pairs(tbMarrys) do
							szMsg = szMsg.."\n"..nDate.."\t"..nLevel.."\t"..tbMarry[3].."\t"..tbMarry[1].."\t"..tbMarry[2];
						end
					else
						szMsg = szMsg.."\n"..nDate.."\t"..nLevel.."\t"..tbMarrys[3].."\t"..tbMarrys[1].."\t"..tbMarrys[2];
					end
				end
			end
		end
	end
	return szMsg;
end

-- 刷城市npc
function Marry:AddSpecNpc_GC(tbName)
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	GlobalExcute({"Marry:AddSpecNpc_GS", tbName});
end

-- 清城市npc
function Marry:ClearSpecNpc_GC()
		
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	GlobalExcute({"Marry:ClearSpecNpc_GS"});
end

-- 保存礼金buff
function Marry:SaveLijinBuff_GC()
	SetGblIntBuf(GBLINTBUF_MARRY_LIJIN, 0, 1, self.tbGblBuffer_Lijin);
end

-- 发放礼金
function Marry:DeleverLijin_GC()
	for _, tbInfo in pairs(self.tbGblBuffer_Lijin) do
		local szMaleName = tbInfo.szMaleName;
		local szFemaleName = tbInfo.szFemaleName;
		local nServerId = tbInfo.nServerId;
		local nSum = tbInfo.nSum;
		GlobalExcute({"Marry:DeleverLijin_GS", nServerId, szMaleName, szFemaleName, nSum});
	end
	self.tbGblBuffer_Lijin = {};
end

-- 增加礼金记录
function Marry:AddLijin_GC(szMaleName, szFemaleName, nSum, nServerId)
	if (not szMaleName or not szFemaleName or not nSum or not nServerId or nSum <= 0) then
		return;
	end
	if (not self.tbGblBuffer_Lijin) then
		self.tbGblBuffer_Lijin = {};
	end
	self.nLiJinAllSum = self.nLiJinAllSum or 0;
	self.nLiJinAllSum = self.nLiJinAllSum + nSum;
	local bFind = 0;
	for _, tbInfo in pairs(self.tbGblBuffer_Lijin) do
		if (tbInfo.szMaleName and tbInfo.szFemaleName and
			tbInfo.szMaleName == szMaleName and
			tbInfo.szFemaleName == szFemaleName) then
			tbInfo.nSum = tbInfo.nSum + nSum;
			tbInfo.nServerId = nServerId;
			bFind = 1;
			break;
		end
	end
	if (0 == bFind) then
		local tbInfo = {};
		tbInfo.szMaleName = szMaleName;
		tbInfo.szFemaleName = szFemaleName;
		tbInfo.nSum = nSum;
		tbInfo.nServerId = nServerId;
		table.insert(self.tbGblBuffer_Lijin, tbInfo);
	end
	if self.nLiJinAllSum >= 1000000 then
		self:SaveLijinBuff_GC();
		Dbg:WriteLog("Marry", "ClearLiJinAllSum", self.nLiJinAllSum);
		self.nLiJinAllSum = 0;
	end
end

-- 启动时载入数据表
function Marry:StartEvent()
	
	-- 载入global buffer
	local tbBuffer = GetGblIntBuf(GBLINTBUF_MARRY, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbGlobalBuffer = tbBuffer;
	end
	
	local tbProposalBuffer = GetGblIntBuf(GBLINTBUF_PROPOSAL, 0);
	if tbProposalBuffer and type(tbProposalBuffer) == "table" then
		self.tbProposalBuffer = tbProposalBuffer;
	end
	
	local tbGblBuffer_Lijin = GetGblIntBuf(GBLINTBUF_MARRY_LIJIN, 0);
	if (tbGblBuffer_Lijin and type(tbGblBuffer_Lijin) == "table") then
		self.tbGblBuffer_Lijin = tbGblBuffer_Lijin;
	end
	
	local tbDivorceBuffer = GetGblIntBuf(GBLINTBUF_DIVORCE, 0);
	if (tbDivorceBuffer and type(tbDivorceBuffer) == "table") then
		self.tbDivorceBuffer = tbDivorceBuffer;
	end	
	
	local nTaskId = 0;
 
 	nTaskId = KScheduleTask.AddTask("每日婚礼开启", "Marry", "StartWedding_GC");
	KScheduleTask.RegisterTimeTask(nTaskId, 1200, 1);
	
	nTaskId = KScheduleTask.AddTask("每日婚礼关闭", "Marry", "CloseWedding_GC");
	KScheduleTask.RegisterTimeTask(nTaskId, 0500, 1);
	
	nTaskId = KScheduleTask.AddTask("每日礼金发放", "Marry", "DeleverLijin_GC");
	KScheduleTask.RegisterTimeTask(nTaskId, 0505, 1);
	
	-- 清除过期数据
	self:ClearOverdueDate();
end

-- gc通知gs玩家加入mission
function Marry:ApplyJoinMission_GC(nPlayerId, nDynMapId)
	GlobalExcute({"Marry:ApplyJoinMission_GS", nPlayerId, nDynMapId});
end

-- 开启系统
function Marry:_Start_GC()
	self.OPEN_STATE = 1;
	GlobalExcute({"Marry:_Start_GS"});
end

-- 测试用开启婚礼
function Marry:_StartWedding(nDate)
	
	-- 系统开关
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	-- 禁止反复调用
	if self.nStartWedding == 1 then
		return 0;
	end
	
	self.nStartWedding = 1;

	local tbName = {};
	local nCurrDate = nDate or tonumber(GetLocalDate("%Y%m%d"));

	for nWeddingLevel, tbMap in pairs(self.tbGlobalBuffer) do
		
		-- 匹配日期的数据表
		local tbRow = tbMap[nCurrDate];
		
		if tbRow then
			-- 平民和贵族有2层
			if nWeddingLevel <= 2 then
				for nIndex, tbInfo in pairs(tbRow) do
					local nRand = MathRandom(1, self.MAX_SERVER);
					self.tbMissionInfo[#self.tbMissionInfo + 1] = 
					{
						MaleName = tbInfo[1], 
						FemaleName = tbInfo[2], 
						MapLevel = tbInfo[3], 
						WeddingLevel = nWeddingLevel,
						MissionIndex = #self.tbMissionInfo + 1,
						ServerIndex = nRand,
						StartDate = nCurrDate,
					};
				end
			-- 王侯和皇家只有1层
			else
				local nRand = MathRandom(1, self.MAX_SERVER);
				self.tbMissionInfo[#self.tbMissionInfo + 1] = 
				{
					MaleName = tbRow[1], 
					FemaleName = tbRow[2], 
					MapLevel = tbRow[3], 
					WeddingLevel = nWeddingLevel,
					MissionIndex = #self.tbMissionInfo + 1,
					ServerIndex = nRand,
					StartDate = nCurrDate,
				};
				tbName[nWeddingLevel] = {tbRow[1], tbRow[2]};
			end
		end
	end
	
	-- 同步给gs
	for _, tbInfo in pairs(self.tbMissionInfo) do
		GlobalExcute({"Marry:SyncMissionInfo_GS", tbInfo});
	end
	
	-- 刷npc
	if Lib:CountTB(tbName) > 0 then
		self:AddSpecNpc_GC(tbName);
	end
	
	-- 下一帧调用
	Timer:Register(1, self.StartWedding_Frame, self);
end

-- 合服处理
-- 1. 将两个buffer表合并到一个备份buffer保存
-- 2. 原来的buffer清空
-- 3. 增加改期处理逻辑
-- 4. 解除订婚关系buffer直接合并
function Marry:CozoneProposalBuffer(tbSubBuffer)
	
	if not tbSubBuffer then
		return 0;
	end
	
	local tbProposalBuffer = GetGblIntBuf(GBLINTBUF_PROPOSAL, 0);
	if tbProposalBuffer and type(tbProposalBuffer) == "table" then
		self.tbProposalBuffer = tbProposalBuffer;
	end
	
	if not self.tbProposalBuffer then
		self.tbProposalBuffer = {};
	end
	
	for szPreName, szMatchName in pairs(tbSubBuffer) do
		self.tbProposalBuffer[szPreName] = szMatchName;
	end
	
	self:SaveProposal_GC();
end

function Marry:CozoneLijinBuffer(tbSubBuffer)
	if (not tbSubBuffer or #tbSubBuffer <= 0) then
		return;
	end
	self.tbGblBuffer_Lijin = GetGblIntBuf(GBLINTBUF_MARRY_LIJIN, 0) or {};
	Lib:MergeTable(self.tbGblBuffer_Lijin, tbSubBuffer);
	self:SaveLijinBuff_GC();
end

function Marry:CozoneGlobalBuffer(tbSubBuffer)
	
	local tbCozoneBuffer = {[1] = {}, [2] = {}, [3] = {}, [4] = {}};
	local tbGlobalBuffer = GetGblIntBuf(GBLINTBUF_MARRY, 0);
	
	if tbGlobalBuffer and type(tbGlobalBuffer) == "table" then
		for nWeddingLevel, tbMap in pairs(tbGlobalBuffer) do
			for nDate, tbRow in pairs(tbMap) do
				if not tbCozoneBuffer[nWeddingLevel][nDate] then
					tbCozoneBuffer[nWeddingLevel][nDate] = {};
				end
				if nWeddingLevel <= 2 then
					for nIndex, tbInfo in pairs(tbRow) do
						--table.insert(tbCozoneBuffer[nWeddingLevel][nDate], tbInfo);
						print("[Marry]CozoneGlobalBuffer tbglobal marry info ", nWeddingLevel, nDate, tbInfo[1], tbInfo[2], tbInfo[3]);
					end
				else
					-- table.insert(tbCozoneBuffer[nWeddingLevel][nDate], tbRow);
					print("[Marry]CozoneGlobalBuffer tbglobal marry info ", nWeddingLevel, nDate, tbRow[1], tbRow[2], tbRow[3]);
				end
			end
		end
	end
	
	if tbSubBuffer and type(tbSubBuffer) == "table" then
		for nWeddingLevel, tbMap in pairs(tbSubBuffer) do
			for nDate, tbRow in pairs(tbMap) do
				if not tbCozoneBuffer[nWeddingLevel][nDate] then
					tbCozoneBuffer[nWeddingLevel][nDate] = {};
				end
				if nWeddingLevel <= 2 then
					for nIndex, tbInfo in pairs(tbRow) do
						-- table.insert(tbCozoneBuffer[nWeddingLevel][nDate], tbInfo);
						print("[Marry]CozoneGlobalBuffer tbsubbuffer marry info ", nWeddingLevel, nDate, tbInfo[1], tbInfo[2], tbInfo[3]);
					end
				else
					-- table.insert(tbCozoneBuffer[nWeddingLevel][nDate], tbRow);
					print("[Marry]CozoneGlobalBuffer tbsubbuffer marry info ", nWeddingLevel, nDate, tbRow[1], tbRow[2], tbRow[3]);
				end
			end
		end
	end
	
	self.tbCozoneBuffer = tbCozoneBuffer;
	--SetGblIntBuf(GBLINTBUF_MARRY_COZONE, 0, 1, self.tbCozoneBuffer);
	
	self.tbGlobalBuffer = {[1] = {}, [2] = {}, [3] = {}, [4] = {}};
	self:SaveBuffer_GC();
end

function Marry:CoZoneMergeDivorce(tbSubBuffer)
	local tbDivorceBuffer = GetGblIntBuf(GBLINTBUF_DIVORCE, 0);
	if tbDivorceBuffer and type(tbDivorceBuffer) == "table" then
		self.tbDivorceBuffer = tbDivorceBuffer;
	end
	
	if not self.tbDivorceBuffer then
		self.tbDivorceBuffer = {};
	end
	if (tbSubBuffer) then
		for szName, szValue in pairs(tbSubBuffer) do
			self.tbDivorceBuffer[szName] = szValue;
		end
	end
	self:SaveDivorce_GC();
end

-- 清除过期数据
function Marry:ClearOverdueDate()
	local nTime = Lib:GetDate2Time(GetLocalDate("%Y%m%d"));
	for nWeddingLevel, tbMap in pairs(self.tbGlobalBuffer) do
		for nDate, tbRow in pairs(tbMap) do
			local nTmpTime = Lib:GetDate2Time(nDate);
			if nTime - nTmpTime > 300 * 24 * 3600 then
				self.tbGlobalBuffer[nWeddingLevel][nDate] = nil;
			end
		end
	end
	self:SaveBuffer_GC();
end

-- 注册gamecenter启动事件
GCEvent:RegisterGCServerStartFunc(Marry.StartEvent, Marry);
GCEvent:RegisterGS2GCServerStartFunc(Marry.OnRecConnectEvent, Marry);

-- 注册gamecenter正常关闭事件
GCEvent:RegisterGCServerShutDownFunc(Marry.SaveLijinBuff_GC, Marry);

-- 注册所有服务器启动完毕事件
if tonumber(GetLocalDate("%H%M")) > 1200 then
	GCEvent:RegisterAllServerStartFunc(Marry.StartWedding_GC, Marry);
end
