-- 文件名　：zhuzongzi_gs.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-21 16:10:10
-- 描  述  ：

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\specialevent\\vn_201101\\zhuzongzi_def.lua");

SpecialEvent.ZongZi2011 = SpecialEvent.ZongZi2011 or {};
local tbZongZi = SpecialEvent.ZongZi2011 or {};

-- 检查是否在活动时间内
function tbZongZi:CheckInEventTime()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < tbZongZi.OPEN_DAY or nDate > tbZongZi.CLOSE_DAY then
		return 0, "活动已经结束了！"
	end
	return 1, "";
end

-- 检查是否符合煮粽子的条件
function tbZongZi:CheckCanBoil(pPlayer)
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < tbZongZi.OPEN_DAY or nDate > tbZongZi.CLOSE_DAY then
		return 0, "活动已经结束了！";
	end
	if pPlayer.nLevel < tbZongZi.LEVEL_LIMIT then
		return 0, "您等级不足60级，无法煮粽子！";
	end
	if "city" ~= GetMapType(pPlayer.nMapId) then
		return 0, "只有各大主城才可以煮粽子，这里不是，所以现在赶快去吧！";
	end
	if self:CheckBoilingState(pPlayer) == 0 then
		return 0, "啊，您已经有锅子正在煮粽子或者因为离开了没有及时加木柴导致火熄灭了，请休息一下再来煮。";
	end
	local nRes, szMsg = self:CheckDayTask(pPlayer);
	if nRes == 0 then
		return 0, szMsg;
	end

	local tbNpcList = KNpc.GetAroundNpcList(pPlayer, 8);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 then
			return 0, string.format("正在这里煮粽子会把<color=green>%s<color>挡住了，还是换个地方煮吧。", pNpc.szName)
		end
	end
	local tbFind = pPlayer.FindItemInBags(unpack(self.ITEM_MUCAI_ID));
	if not tbFind[1] then
		return 0, "激活锅子需要消耗一个木材";
	end
	return 1, "";
end

function tbZongZi:CheckDayTask(pPlayer)
	local nToday = tonumber(GetLocalDate("%Y%m%d"));
	local nLastBoilDay = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_LAST_BOILED_DAY);
	if nLastBoilDay < nToday then
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_LAST_BOILED_DAY, nToday);
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BOIL_DAY_COUNT, 0); 
		return 1, string.format("您今天已经煮了<color=yellow>0/%s<color>个粽子", self.MAX_BOIL_DAY_COUNT);
	end
	local nBoilDayCount	= pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BOIL_DAY_COUNT); 
	if nBoilDayCount >= self.MAX_BOIL_DAY_COUNT then
		return 0, string.format("您今天已经煮了<color=yellow>%s<color>个粽子，还是休息下，明天再说吧。", self.MAX_BOIL_DAY_COUNT);
	end
	return 1,  string.format("您今天已经煮了<color=yellow>%s/%s<color>个粽子。", nBoilDayCount, self.MAX_BOIL_DAY_COUNT);
end

-- 检查能否煮粽子
function tbZongZi:CheckBoilingState(pPlayer)
	local nBoilState = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BOIL_STATE);
	if nBoilState == 0 then
		return 1;
	end
	local nStartTime = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_LAST_BOIL_TIME);
	local nNowTime = GetTime();
	if nNowTime > nStartTime + self.BOIL_CD_TIME then	-- 玩家掉线任务变量没有设上
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BOIL_STATE, 0);
		return 1;
	end
	return 0;
end

-- 检查是否在煮粽子
function tbZongZi:CheckIsBoiling(pPlayer)
	local nBoilState = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BOIL_STATE);
	if nBoilState < 1 then
		return 0;
	end
	local nStartTime = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_LAST_BOIL_TIME);
	local nNowTime = GetTime();
	if nNowTime > nStartTime + self.BOIL_CD_TIME then	-- 玩家掉线任务变量没有设上
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BOIL_STATE, 0);
		return 0;
	else
		local nEndTime = nStartTime;	-- 某一阶段结束时间
		for i = 1, nBoilState do
			nEndTime = nEndTime + self.BOIL_STEP_TIME[i];
		end
		if nNowTime <= nEndTime then
			return 1;
		else
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BOIL_STATE, -1);
			return 0;
		end
	end
	return 0;
end

-- 设置煮粽子的状态
function tbZongZi:SetBoilState(nPlayerId, nState)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BOIL_STATE, nState);
		if nState == 1 then
			pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_LAST_BOIL_TIME, GetTime());
		end
	end
end

-- 设置收获煮粽子之后的状态
function tbZongZi:SetDayTask(pPlayer)
	local nDayCount = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BOIL_DAY_COUNT);
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BOIL_DAY_COUNT, nDayCount+1); 
	nDayCount = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BOIL_DAY_COUNT);
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BOIL_STATE, 0);
end

-- 修正玩家的状态，防止玩家不在线时状态改变加不上组队经验
function tbZongZi:ReviseBoilState(pPlayer, nStep)
	local nBoilState = pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_BOIL_STATE);
	if nBoilState > 0 and nBoilState < nStep then
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BOIL_STATE, nStep);
	end
end

function tbZongZi:StartBoil(nPlayerId, nItemId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nRes, szMsg = self:CheckCanBoil(pPlayer);
	if nRes == 0 then
		return 0;
	end
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local nMapId, x, y = pPlayer.GetWorldPos();
	local _, nRes = self:GoNextStep(nPlayerId, -1, 1, nMapId, x, y);
	if not nRes or nRes == 0 then
		self:SetBoilState(pPlayer, 0);
		return 0;
	end
	pItem.Delete(pPlayer);
	me.ConsumeItemInBags(1, self.ITEM_MUCAI_ID[1], self.ITEM_MUCAI_ID[2], self.ITEM_MUCAI_ID[3], self.ITEM_MUCAI_ID[4], -1);
	self:SetBoilState(pPlayer.nId, 1);
	return 1;
end

function tbZongZi:AddBoilNpc(szPlayerName, nBoilIndex, nMapId, x, y)
	local nNpcId = self.BOIL_STEP_NPC[nBoilIndex];
	assert(nNpcId);
	local pNpc = KNpc.Add2(nNpcId, 1, -1, nMapId, x, y);
	if not pNpc then
		return 0;
	end
	pNpc.szName = string.format("%s的%s", szPlayerName, pNpc.szName);
	return 0, pNpc;
end

-- 熄火提示
function tbZongZi:FlameOutAlert(nPlayerId, nNpcId, nIndex)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	if pNpc.GetTempTable("Npc").tbBoilZongZi.nStepActive == 1 then -- 检查需要进入下一阶段的条件是否满足
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		local szMsg =  string.format(self.BOIL_STEP_MSG[nIndex].szAlert, self.ALERT_TIME);
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
		pPlayer.Msg(szMsg);
	end
	pNpc.GetTempTable("Npc").tbBoilZongZi.nTimerId_Alert = nil;
	return 0;
end

-- 进入下一阶段
function tbZongZi:GoNextStep(nPlayerId, nNpcId, nNextIndex, nMapId, x, y)
	if nNextIndex > 1 then	-- 第一阶段默认为激活状态且没有npc
		local pOldNpc = KNpc.GetById(nNpcId);
		if pOldNpc then
			local nStepActive = pOldNpc.GetTempTable("Npc").tbBoilZongZi.nStepActive;
			pOldNpc.Delete();
			if nStepActive and nStepActive == 0 then
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer then
					pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BOIL_STATE, -1);
					Dialog:SendBlackBoardMsg(pPlayer, self.BOIL_STEP_MSG[nNextIndex-1].szFlameOut);
					pPlayer.Msg(self.BOIL_STEP_MSG[nNextIndex-1].szFlameOut);
				end
				return 0;
			end
		else
			return 0;
		end
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if nNextIndex > #self.BOIL_STEP_TIME then
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BOIL_STATE, 0);
		return 0, 1;
	end
	
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	local _, pNewNpc = self:AddBoilNpc(szPlayerName, nNextIndex, nMapId, x, y);
	if not pNewNpc then
		return 0, 0;
	end
	local tbTemp = pNewNpc.GetTempTable("Npc");
	local nTimerId_Alert = nil;
	
	local nStepActive = 1;
	local nTimerId_Exp = Timer:Register(self.EXP_TIME * Env.GAME_FPS, self.GiveExp, self, nPlayerId, pNewNpc.dwId, nMapId, x, y, nNextIndex);
	if nNextIndex > 1 then
		nTimerId_Alert = Timer:Register((self.BOIL_STEP_TIME[nNextIndex] - self.ALERT_TIME) * Env.GAME_FPS, self.FlameOutAlert, self, nPlayerId, pNewNpc.dwId, nNextIndex);
		nStepActive = 0;
	end
	local nTimerId_NextStep = Timer:Register(self.BOIL_STEP_TIME[nNextIndex] * Env.GAME_FPS, self.GoNextStep, self, nPlayerId, pNewNpc.dwId, nNextIndex + 1, nMapId, x, y);
	tbTemp.tbBoilZongZi = 
	{
		["nPlayerId"] = nPlayerId,
		["nBoilIndex"] = nNextIndex,
		["nTimerId_Alert"] = nTimerId_Alert,
		["nTimerId_NextStep"] = nTimerId_NextStep,
		["nTimerId_Exp"] = nTimerId_Exp,
		["nStepActive"] = nStepActive,
	};
	
	if pPlayer then
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_BOIL_STATE, nNextIndex);
		Dialog:SendBlackBoardMsg(pPlayer, self.BOIL_STEP_MSG[nNextIndex].szStep);
		pPlayer.Msg(self.BOIL_STEP_MSG[nNextIndex].szStep);
	end
	return 0, 1;
end

function tbZongZi:GetOwnerId(pNpc)
	return pNpc.GetTempTable("Npc").tbBoilZongZi.nPlayerId;
end

-- 是否是收获状态
function tbZongZi:IsWellDone(pNpc)
	local nBoilIndex = pNpc.GetTempTable("Npc").tbBoilZongZi.nBoilIndex;
	if nBoilIndex == #self.BOIL_STEP_TIME then
		return 1;
	end
	return 0;
end

function tbZongZi:IsActived(pNpc)
	return pNpc.GetTempTable("Npc").tbBoilZongZi.nStepActive;
end

-- 最后一个状态是否还有粽子
function tbZongZi:HasZongZi(pNpc)
	if self:IsWellDone(pNpc) == 1 then
		if pNpc.GetTempTable("Npc").tbBoilZongZi.nStepActive == 1 then
			return 0;
		end
		return 1;
	end
	return 0;
end

-- 获取距离下个阶段剩余时间
function tbZongZi:GetRestTime(pNpc)
	local nTimerId_NextStep = pNpc.GetTempTable("Npc").tbBoilZongZi.nTimerId_NextStep;
	if not nTimerId_NextStep or nTimerId_NextStep == -1 then
		return 0;
	end
	local nTimerRem = Timer:GetRestTime(nTimerId_NextStep);
	return math.ceil(tonumber(Timer:GetRestTime(nTimerId_NextStep)) / 18);
end

-- 获取各个阶段的dialog描述
function tbZongZi:GetDialogMsg(pNpc)
	local nIndex = pNpc.GetTempTable("Npc").tbBoilZongZi.nBoilIndex;
	local nResTime = self:GetRestTime(pNpc);
	if nResTime <= 0 then
		return 0;
	end
	local nActived = pNpc.GetTempTable("Npc").tbBoilZongZi.nStepActive;
	local szMsg = "你好，有什么能帮您的";
	if nActived == 0 and self.BOIL_STEP_MSG[nIndex].szMsgNoActive then
		szMsg = string.format(self.BOIL_STEP_MSG[nIndex].szMsgNoActive, nResTime);
	end
	if nActived == 1 and self.BOIL_STEP_MSG[nIndex].szMsgActived then
		szMsg = string.format(self.BOIL_STEP_MSG[nIndex].szMsgActived, nResTime);
	end
	return 1, szMsg;
end

-- 加木柴,
function tbZongZi:AddMuChai(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not Npc then
		Dialog:Say("很可惜，你的火已经熄灭了。");
		return 0;
	end
	local tbFind = pPlayer.FindItemInBags(unpack(self.ITEM_MUCAI_ID));
	if not tbFind[1] then
		Dialog:Say("你身上没有木柴，快去买点木柴，不然火熄灭了就糟糕了。");
		return 0;
	end
	if pNpc.GetTempTable("Npc").tbBoilZongZi.nStepActive == 1 then
		Dialog:Say("你已经加过木柴了，暂时不用加了");
		return 0;
	end
	me.ConsumeItemInBags(1, self.ITEM_MUCAI_ID[1], self.ITEM_MUCAI_ID[2], self.ITEM_MUCAI_ID[3], self.ITEM_MUCAI_ID[4], -1);
	pNpc.GetTempTable("Npc").tbBoilZongZi.nStepActive = 1;
	Dialog:SendBlackBoardMsg(pPlayer, "你成功添加了木柴，请耐心等待粽子熟");
	pPlayer.Msg("你成功添加了木柴，请耐心等待粽子熟");
end

-- 收获粽子
function tbZongZi:GetZongZi(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		Dialog:Say("很可惜，你的火已经熄灭了。");
		return;
	end
	local nState = tbZongZi:HasZongZi(pNpc);
	if nState == 1 then
		if pPlayer.CountFreeBagCell() < 1 then
			Dialog:Say("Hành trang không đủ chỗ trống");
		end
		pPlayer.AddItem(unpack(self.ITEM_ZONGZI_ID));
		self:DeleteNpc(pNpc);
		self:SetDayTask(pPlayer);
		Dialog:SendBlackBoardMsg(pPlayer, "你成功收获了粽子");
		pPlayer.Msg("你成功收获了粽子");
	end
end

-- 给予经验
function tbZongZi:GiveExp(nPlayerId, nNpcId, nMapId, x, y, nStep)
	local pNpc = KNpc.GetById(nNpcId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer and pPlayer.nMapId == nMapId and self:CheckInExpAround(pPlayer, x, y) == 1 then
		if pNpc then
			self:ReviseBoilState(pPlayer, nStep);
		end
		local nTimes = 1;
		local tbMemberList, nMemberCount = me.GetTeamMemberList();
		if tbMemberList then
			for _, pMember in pairs(tbMemberList) do
				if pMember.nId ~= pPlayer.nId and pMember.nMapId == nMapId and self:CheckIsBoiling(pMember) == 1 and self:CheckInExpAround(pMember, x, y) == 1 then	-- 同一地图才能获得组队经验	
					nTimes = nTimes + 1;
				end
			end
		end
		local nExp = math.floor(pPlayer.GetBaseAwardExp() / 8 * self.BASE_EXP_MULTIPLE) * nTimes;
		pPlayer.CastSkill(377, 10, -1, pPlayer.GetNpc().nIndex);
		pPlayer.AddExp(nExp);
	end
	if not pNpc then
		return 0;
	end
end

-- 检测是否在指定范围内煮粽子
function tbZongZi:CheckInExpAround(pPlayer, x, y)
	local _, nPlayerPosX, nPlayerPosY = pPlayer.GetWorldPos();
	local nX = nPlayerPosX - x;
	local nY = nPlayerPosY - y;
	if (nX * nX + nY * nY) < (self.RANGE_EXP * self.RANGE_EXP) then
		return 1;
	end
	return 0;
end

-- 删除npc以及关闭定时器
function tbZongZi:DeleteNpc(pNpc)
	local nTimerId_GiveExp = pNpc.GetTempTable("Npc").tbBoilZongZi.nTimerId_Exp;
	if nTimerId_GiveExp then
		Timer:Close(nTimerId_GiveExp);
	end
	local nTimerId_Alert = pNpc.GetTempTable("Npc").tbBoilZongZi.nTimerId_Alert;
	if nTimerId_Alert then
		Timer:Close(nTimerId_Alert);
	end
	local nTimerId_NextStep = pNpc.GetTempTable("Npc").tbBoilZongZi.nTimerId_NextStep;
	if nTimerId_NextStep then
		Timer:Close(nTimerId_NextStep);
	end
	pNpc.Delete();
end

-- 随机奔宵
function tbZongZi:RandomBenXiao()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	local nDay = KGblTask.SCGetDbTaskInt(DATASK_VN_BENXIAO_LAST_DAY);
	local nCount = KGblTask.SCGetDbTaskInt(DATASK_VN_BENXIAO_ALL_COUNT);
	if nDay >= nNowDate or nCount >= self.MAX_BENXIAO_COUNT then	-- 今天已经随到过奔宵了或服务器超过10个
		return 0;
	end
	local nRand = MathRandom(1, self.BENXIAO_MAXVALUE);
	if nRand <=  self.BENXIAO_PROBABILITY then	
		return 1;
	end
	return 0;
end

function tbZongZi:RandomBenXiao_GS2(nPlayerId, nResult, nLastDay, nCount)
	KGblTask.SCSetDbTaskInt(DATASK_VN_BENXIAO_LAST_DAY, nLastDay);
	KGblTask.SCSetDbTaskInt(DATASK_VN_BENXIAO_ALL_COUNT, nCount);
	local cPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not cPlayer then
		return 0;
	end
	if nResult == 1 then	
		if cPlayer.CountFreeBagCell() >= 1 then
			local pItem = cPlayer.AddItem(unpack(self.ITEM_BENXIAO_ID));
			if pItem then
				local szDate = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + self.ITEM_VALIDITY_BENXIAO);
       			cPlayer.SetItemTimeout(pItem, szDate);
			end
		end
	end
	cPlayer.AddWaitGetItemNum(-1);
end