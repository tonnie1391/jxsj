-- 文件名　：nianshouseige_gs.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-28 14:10:10
-- 描  述  ：

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\specialevent\\nianshouseige\\nianshousiege_def.lua");
SpecialEvent.NianShouSiege = SpecialEvent.NianShouSiege or {};
local tbNianShouSiege = SpecialEvent.NianShouSiege or {};

function tbNianShouSiege:StartNianShouSiege_GS2(nSeg)
	self.nSeg = nSeg or 0;
	local nMapId = self.NIANSHOU_BORN_POS[1];
	if SubWorldID2Idx(nMapId) >= 0 then
		local nRes = self:EventStartRefreshNpc();
		if nRes == 1 then
			self.nNianShouId = Npc:GetClass("nianshou_2011"):StartSiege();
		end
	end
end

-- 检查每日任务变量
function tbNianShouSiege:CheckDayTask(pPlayer)
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	local nLastWinDay = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_LAST_WIN_DAY);
	local nDayWinTimes = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_DAY_WIN_TIMES);
	if nLastWinDay < nDate then
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_LAST_WIN_DAY, nDate);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_DAY_WIN_TIMES, 0);
		return 1, 0;
	end
	if nDayWinTimes >= self.MAX_DAY_WIN_TIMES then
		return 0, self.MAX_DAY_WIN_TIMES;
	end
	return 1, nDayWinTimes;
end

-- 检查npc是否在玩家的有效范围内
function tbNianShouSiege:CheckIsNearby(pPlayer, pNpc, nRange)
	local nPlayerMapId, nPlayerX, nPlayerY = pPlayer.GetWorldPos();
	local nNpcMapId, nNpcX, nNpcY = pNpc.GetWorldPos();
	if nPlayerMapId ~= nNpcMapId then
		return 0;
	end
	if (nPlayerX - nNpcX) * (nPlayerX - nNpcX) + (nPlayerY - nNpcY) * (nPlayerY - nNpcY) > nRange * nRange then
		return 0;
	end
	return 1;
end

-- 活动开始刷新战斗白秋林
function tbNianShouSiege:EventStartRefreshNpc()
	if self.nNianShouId then	-- 上轮年兽还在强制删除
		local pNpc = KNpc.GetById(self.nNianShouId);
			if pNpc then
				pNpc.Delete();
			end
		self.nNianShouId = nil;
	end
	if self.nNpcFightQiuYiId then	-- 上轮战斗白秋林还在强制删除
		local pNpc = KNpc.GetById(self.nNpcFightQiuYiId);
			if pNpc then
				pNpc.Delete();
			end
		self.nNpcFightQiuYiId = nil;
	end
	if self.nNpcDialogQiuYiId then	-- 删除对话白秋林
		local pNpc = KNpc.GetById(self.nNpcDialogQiuYiId);
			if pNpc then
				pNpc.Delete();
			end
		self.nNpcDialogQiuYiId = nil;
	end
	local pNpc = KNpc.Add2(self.NPC_BAIQIULING_FIGHT_ID, 120, -1, self.BAIQIULING_POS[1], self.BAIQIULING_POS[2], self.BAIQIULING_POS[3]);
	if pNpc then
		self.nNpcFightQiuYiId= pNpc.dwId;
		if self.BAIQIULING_MAX_LIFE then
			pNpc.SetMaxLife(self.BAIQIULING_MAX_LIFE);
			pNpc.RestoreLife();
		end
		return 1;
	end
	Dbg:WriteLog("tbNianShouSiege:EventStartRefreshNpc add npc fail");
	return 0;
end

-- 活动结束刷新对话白秋林
function tbNianShouSiege:EventEndRefreshNpc()
	if self.nNpcFightQiuYiId then
		local pNpc = KNpc.GetById(self.nNpcFightQiuYiId);
		if pNpc then
			pNpc.Delete();
		end
	end
	self.nNpcFightQiuYiId = nil;
	self:RefreshNpc();
end

-- 服务器启动事件
function tbNianShouSiege:StartEvent_GS()
	self:RefreshNpc();
end

function tbNianShouSiege:RefreshNpc()
	if self:CheckIsOpen() == 1 then
		if SubWorldID2Idx(self.BAIQIULING_POS[1]) >= 0 and not self.nNpcDialogQiuYiId then
			local pNpc = KNpc.Add2(self.NPC_BAIQIULING_ID, 120, -1, self.BAIQIULING_POS[1], self.BAIQIULING_POS[2], self.BAIQIULING_POS[3]);
			if pNpc then
				self.nNpcDialogQiuYiId = pNpc.dwId;
			end
		end
	else
		if SubWorldID2Idx(self.BAIQIULING_POS[1]) >= 0 and self.nNpcDialogQiuYiId then
			local pNpc = KNpc.GetById(self.nNpcDialogQiuYiId);
			if pNpc then
				pNpc.Delete();
			end
		end
	end
end


-- 注册启动事件
ServerEvent:RegisterServerStartFunc(tbNianShouSiege.StartEvent_GS, tbNianShouSiege);


-------------------------------------------- gm指令 -----------------------------------------------
-- 强制恢复正常状态
function tbNianShouSiege:RecoverState()
	if self.nNianShouId then	-- 上轮年兽还在强制删除
		local pNpc = KNpc.GetById(self.nNianShouId);
			if pNpc then
				pNpc.Delete();
			end
		self.nNianShouId = nil;
	end
	if self.nNpcFightQiuYiId then	-- 上轮战斗白秋林还在强制删除
		local pNpc = KNpc.GetById(self.nNpcFightQiuYiId);
			if pNpc then
				pNpc.Delete();
			end
		self.nNpcFightQiuYiId = nil;
	end
	if self.nNpcDialogQiuYiId then	-- 删除对话白秋林
		local pNpc = KNpc.GetById(self.nNpcDialogQiuYiId);
			if pNpc then
				pNpc.Delete();
			end
		self.nNpcDialogQiuYiId = nil;
	end
	self:RefreshNpc();
end

-- 设置年兽保护血量百分比(10, 100),10表示百分之10,100是最大血量,不填为默认血量
function tbNianShouSiege:SetProtectBloodPrecent(nPrec, nMaxBlood)
	self.NIANSHOU_MAX_LIFE = nMaxBlood or self.NIANSHOU_MAX_LIFE or 70000;
	self.PROTECT_BLOOD = math.floor(self.NIANSHOU_MAX_LIFE * nPrec / 100);
end

-- 设置白秋林的血量
function tbNianShouSiege:SetBaiQiuLingBlood(nBlood)
	self.BAIQIULING_MAX_LIFE = nBlood;
end

-- 重设年兽出发点
function tbNianShouSiege:ResetNianShouBornPos(nIndex)
	local tbRoute = Lib:LoadTabFile(self.TB_ROUTE);
	self.NIANSHOU_BORN_POS[2] = tonumber(tbRoute[nIndex]["POSX"]/32);
	self.NIANSHOU_BORN_POS[3] = tonumber(tbRoute[nIndex]["POSY"]/32);
	self.NIANSHOU_BORN_INDEX = nIndex;
end

-- 减少年兽血量
function tbNianShouSiege:ReduceNianShouBlood(nBlood)
	if self.nNianShouId then	-- 上轮年兽还在强制删除
		local pNpc = KNpc.GetById(self.nNianShouId);
		if pNpc then
			pNpc.ReduceLife(nBlood);
		end
	end
end

------------------------------------------------------------------------------------------------