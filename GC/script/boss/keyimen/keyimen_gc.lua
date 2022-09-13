-------------------------------------------------------
-- 文件名　：keyimen_gc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2012-02-22 11:31:58
-- 文件描述：
-------------------------------------------------------

if not MODULE_GC_SERVER then
	return 0;
end

Require("\\script\\boss\\keyimen\\keyimen_def.lua");

-------------------------------------------------------
-- boss
-------------------------------------------------------

-- 刷新大boss
function Keyimen:UpdateBoss_GC()
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	for nCamp, tbInfo in pairs(self.NPC_BOSS_LIST) do
		local nRand = MathRandom(1, #tbInfo.tbPos);
		local nMapId, nMapX, nMapY = unpack(tbInfo.tbPos[nRand][1]);
		local nTmpMapId, nTmpMapX, nTmpMapY = unpack(tbInfo.tbPos[nRand][2]);
		-- 最后的龙柱跟boss一起刷
		GlobalExcute({"Keyimen:UpdateBoss_GS", tbInfo.nBossId, nMapId, nMapX, nMapY, nCamp});
		GlobalExcute({"Keyimen:UpdateDragon_GS", tbInfo.nDragonId, nTmpMapId, nTmpMapX, nTmpMapY, nCamp, self.FINAL_DRAGON});
	end
	GlobalExcute({"KDialog.NewsMsg", 0, Env.NEWSMSG_NORMAL, "Thống Soái Mông Cổ - Tây Hạ xuất hiện tại Chiến trường Khắc Di Môn!"});
	self:ClearTimer("DoAnnounce_GC");
end

-- 刷新小boss
function Keyimen:UpdateGuard_GC(nCamp)
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	local tbInfo = self.NPC_GUARD_LIST[nCamp];
	if not tbInfo then
		return 0;
	end
	local tbT = {};
	for i = 1, #tbInfo.tbPos do
		tbT[i] = i;
	end
	Lib:SmashTable(tbT);
	for i = 1, #tbInfo.tbGuardId do
		local nGuardId = tbInfo.tbGuardId[i];
		local nMapId, nMapX, nMapY = unpack(tbInfo.tbPos[tbT[i]]);
		GlobalExcute({"Keyimen:UpdateGuard_GS", nGuardId, nMapId, nMapX, nMapY, nCamp});
	end
end

-- 刷新随机boss
function Keyimen:UpdateMonster_GC()
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	for i = 1, #self.NPC_MONSTER_LIST do 
		local nRand = MathRandom(1, self.RAND_TIME);
		self:StartTimer(nRand * Env.GAME_FPS, self.DoUpdateMonster_GC, "DoUpdateMonster_GC" .. i, i);
	end
end

function Keyimen:DoUpdateMonster_GC(nIndex)
	local tbInfo = self.NPC_MONSTER_LIST[nIndex];
	if not tbInfo then
		return 0;
	end
	local nMonsterId = tbInfo.nMonsterId;
	local nMapId, nMapX, nMapY = unpack(tbInfo.tbPos[MathRandom(1, #tbInfo.tbPos)]);
	GlobalExcute({"Keyimen:UpdateMonster_GS", nMonsterId, nMapId, nMapX, nMapY});
	return 0;
end

-- 刷新幽玄龙柱
function Keyimen:UpdateDragon_GC()
	for nCamp, tbCamp in ipairs(self.NPC_DRAGON_LIST) do
		for i, tbInfo in ipairs(tbCamp) do
			local nNpcId = tbInfo.nNpcId;
			local nMapId, nMapX, nMapY = unpack(tbInfo.tbPos);
			GlobalExcute({"Keyimen:UpdateDragon_GS", nNpcId, nMapId, nMapX, nMapY, nCamp, i});
		end
	end
	local szMsg = "Trên bầu trời, hàng nghìn tia sét lướt qua, Long Hồn thoát ra từ Chiến trường Khắc Di Môn biến thành vô số Long Trụ.";
	GlobalExcute({"KDialog.NewsMsg", 0, Env.NEWSMSG_NORMAL, szMsg});
	GlobalExcute({"KDialog.Msg2SubWorld", string.format("<color=green>%s<color>", szMsg)});
end

-------------------------------------------------------
-- 阵营相关
-------------------------------------------------------

-- 帮会选择阵营
function Keyimen:TongSignup_GC(nTongId, nCamp)
	if not self.tbTongBuffer[nTongId] then
		self.tbTongBuffer[nTongId] = {};
	end
	self.tbTongBuffer[nTongId].nPreCamp = nCamp;
	self:SaveBuffer_GC(GBLINTBUF_KEYIMEN_TONG);
end

-- 家族插旗
function Keyimen:KinFlag_GC(nPlayerId, nTongId, nKinId, tbPos)
	
	-- 必须有帮会
	local nCamp = self:GetTongCamp(nTongId);
	if nCamp <= 0 then
		GlobalExcute({"Keyimen:KinFlagFailed_GS", nPlayerId, nKinId});
		return 0;
	end
	
	if not self.tbKinBuffer[nKinId] then
		self.tbKinBuffer[nKinId] = {};
	end
	
	-- 判断插旗时间
	local nFlagTime = self.tbKinBuffer[nKinId].nFlagTime or 0;
	if GetTime() - nFlagTime < self.FLAG_INTERVAL then
		GlobalExcute({"Keyimen:KinFlagFailed_GS", nPlayerId, nKinId});
		return 0;
	end
	GlobalExcute({"Keyimen:KinFlagSuccess_GS", nPlayerId, nTongId, nKinId, tbPos});
	
	-- 保存时间和坐标
	self.tbKinBuffer[nKinId].nFlagTime = GetTime();
	self.tbKinBuffer[nKinId].tbFlagPos = tbPos;
	self:SaveBuffer_GC(GBLINTBUF_KEYIMEN_KIN);
end

-- 帮会开启任务
function Keyimen:TongStartTask_GC(nTongId)
	
	-- 开启标记和龙珠编号
	self.tbTongBuffer[nTongId].tbTask = {};
	
	-- 这里基本不需要检查了
	local nCamp = 3 - self:GetTongCamp(nTongId);
	local tbInfo = self.NPC_DRAGON_LIST[nCamp];	
	if not tbInfo then
		return 0;
	end
	
	-- 从11个龙柱中随4个，最后一个固定
	local tbT = {};
	for i = 1, #tbInfo do
		tbT[i] = i;
	end
	Lib:SmashTable(tbT);
	for i = 1, #self.TASK_TARGET - 1 do
		self.tbTongBuffer[nTongId].tbTask[i] = tbT[i];
	end
	self.tbTongBuffer[nTongId].tbTask[#self.TASK_TARGET] = self.FINAL_DRAGON;
	self:SaveBuffer_GC(GBLINTBUF_KEYIMEN_TONG);
end

-- 关闭帮会任务
function Keyimen:TongCloseTask_GC(nTongId)
	if self.tbTongBuffer[nTongId] then
		self.tbTongBuffer[nTongId].tbTask = nil;
	end
	self:SaveBuffer_GC(GBLINTBUF_KEYIMEN_TONG);
end

-- 每日阵营维护
function Keyimen:DailySignup_GC()
	for nTongId, tbInfo in pairs(self.tbTongBuffer) do
		local nDate = tonumber(GetLocalDate("%Y%m%d"));
		-- 帮会阵营
		if tbInfo.nDate ~= nDate then
			if tbInfo.nPreCamp > 0 then
				tbInfo.nCurCamp = tbInfo.nPreCamp;
				tbInfo.nPreCamp = 0;
			end
			tbInfo.nDate = nDate;
			-- 任务清了
			tbInfo.tbTask = nil;
		end
		-- log
		local pTong = KTong.GetTong(nTongId);
		if pTong then
			StatLog:WriteStatLog("stat_info", "keyimen_battle", "choose", 0, pTong.GetName(), tbInfo.nCurCamp);
		end
	end
	self:SaveBuffer_GC(GBLINTBUF_KEYIMEN_TONG);
end

-- 全局广播
function Keyimen:BroadCast_GC(szMsg, nType)
	GlobalExcute({"Keyimen:OnBroadCast", szMsg, nType});
end

-- 刷新预告
function Keyimen:Announce_GC()
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	self:StartTimer(55 * Env.GAME_FPS, self.DoAnnounce_GC, "DoAnnounce_GC");
end

function Keyimen:DoAnnounce_GC()
	GlobalExcute({"KDialog.Msg2SubWorld", "<color=green>Thống soái Mông Cổ - Tây Hạ chuẩn bị xuất chiến ở Chiến trường Khắc Di Môn<color>"});
	return 55 * Env.GAME_FPS;
end

-------------------------------------------------------
-- buffer
-------------------------------------------------------

-- load
function Keyimen:LoadBuffer_GC(nIndex)
	local szBuffer = self.GBLBUFFER_LIST[nIndex];
	if not szBuffer then
		return 0;
	end
	local tbBuffer = GetGblIntBuf(nIndex, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self[szBuffer] = tbBuffer;
	end
end

-- save
function Keyimen:SaveBuffer_GC(nIndex)
	local szBuffer = self.GBLBUFFER_LIST[nIndex];
	if not szBuffer then
		return 0;
	end
	SetGblIntBuf(nIndex, 0, 1, self[szBuffer]);
	GlobalExcute({"Keyimen:LoadBuffer_GS", nIndex});
end

-- clear
function Keyimen:ClearBuffer_GC(nIndex)	
	local szBuffer = self.GBLBUFFER_LIST[nIndex];
	if not szBuffer then
		return 0;
	end
	self[szBuffer] = {};
	SetGblIntBuf(nIndex, 0, 1, {});
	GlobalExcute({"Keyimen:ClearBuffer_GS", nIndex});
end

-- 启动事件
function Keyimen:StartEvent_GC()
	for nIndex, _ in pairs(self.GBLBUFFER_LIST) do
		self:LoadBuffer_GC(nIndex);
	end
	self:DailySignup_GC();
	self:AddTempScheduleTask();
end

function Keyimen:CoZoneUpdateKeyimenBuf(tbSubBuf)
	
	print("[GCEvent] CoZoneUpdateKeyimenBuf start");
	self.tbTongBuffer = {};
	
	local tbLoadBuffer = GetGblIntBuf(self.BUFFER_INDEX, 0);
	if tbLoadBuffer and type(tbLoadBuffer) == "table" then
		self.tbTongBuffer = tbLoadBuffer;
	end
	
	for nTongId, tbInfo in pairs(tbSubBuf) do
		if (self.tbTongBuffer[nTongId]) then
			print("[GCEvent] CoZoneUpdateKeyimenBuf ERROR", nTongId);
		else
			self.tbTongBuffer[nTongId] = tbInfo;
		end
	end

	SetGblIntBuf(self.BUFFER_INDEX, 0, 1, self.tbTongBuffer);
	print("[GCEvent] CoZoneUpdateKeyimenBuf end");
end

function Keyimen:ScheduleCallEvent()
	GlobalExcute{"Keyimen:ClearAllDragon"};
end

function Keyimen:AddTempScheduleTask()
	local nTaskId = KScheduleTask.AddTask("克夷门临时清除龙柱", "Keyimen", "ScheduleCallEvent");
	assert(nTaskId > 0);
	KScheduleTask.RegisterTimeTask(nTaskId, 1515, 1);
	KScheduleTask.RegisterTimeTask(nTaskId, 2215, 2);
end

-- 注册gamecenter启动事件
GCEvent:RegisterGCServerStartFunc(Keyimen.StartEvent_GC, Keyimen);
