-- 文件名　：changfaction.lua
-- 创建者　：maiyajin
-- 创建时间：2008-12-01 16:13:14
-- 门派多修以及转门派

Faction.OPEN_DUOXIU					= 1;
Faction.SWITCH_FACTION_CD			= 300;   -- 切换门派CD时间，单位：秒
Faction.SWITCH_FACTION_BUF_ID		= 897;
Faction.MAX_USED_FACTION			=  EventManager.IVER_bUseFactionMax;	-- 最大修炼门派数
Faction.MAX_MODIFY_TIME				= 4;	-- 最大换辅修次数

Faction.TSKGID_FACTION_INFO			= 7;	-- 修炼门派相关数据

Faction.TSKID_ORIGINAL_FACTION		= 1;	-- 原始门派
Faction.TSKID_CHANGE_FACTION_INDEX  = 2;	-- 要转第几修
Faction.TSKID_PREV_FACTION			= 3;	-- 上一次修炼的门派
Faction.TSKID_MODIFY_FACTION_NUM	= 4;	-- 已更换辅修门派次数
Faction.TSKID_MODIFY_FACTION_NUM_EX = 5;    -- 额外更换辅修门派次数

Faction.TSKID_USED_FACTION_START	= 100;	-- 修炼门派task id 起始, start 对应主修, start + 1 副修1， start + 2 副修2, etc.
Faction.TSKID_LAST_SWITCH_TIME		= 200;	-- 上一次切换门派的时间

Faction.nIsOpenFuXiuTask			= 0;

Faction.REPUTETASK_GROUPID			= 1025;
Faction.REPUTETASK_TASKID_XOYO_DAILY			= 85;
Faction.REPUTETASK_TASKID_XOYO_WEEKCOUNT		= 86;
Faction.REPUTETASK_TASKID_SHIGUANGDIAN			= 87;
Faction.REPUTETASK_TASKID_CHENCHONGZHEN			= 88;

Faction.TASK_DAILY_GAME = 536;
Faction.TASK_WEEK_GAME = 537;

Faction.TYPE_XOYO					= 1;
Faction.TYPE_YINYANGSHIGUANGDIAN	= 2;
Faction.TYPE_CHENCHONGZHEN			= 3;

-- 门派ID到其纪录GroupId的映射
Faction.tbFactionRecGroupId = {
	[Env.FACTION_ID_SHAOLIN]		= 8,   -- 少林
	[Env.FACTION_ID_TIANWANG]		= 9,   -- 天王
	[Env.FACTION_ID_TANGMEN]		= 10,  -- 唐门
	[Env.FACTION_ID_WUDU]			= 11,  -- 五毒
	[Env.FACTION_ID_EMEI]			= 12,  -- 峨嵋
	[Env.FACTION_ID_CUIYAN]			= 13,  -- 翠烟
	[Env.FACTION_ID_GAIBANG]		= 14,  -- 丐帮
	[Env.FACTION_ID_TIANREN]		= 15,  -- 天忍
	[Env.FACTION_ID_WUDANG]			= 16,  -- 武当
	[Env.FACTION_ID_KUNLUN]			= 17,  -- 昆仑
	[Env.FACTION_ID_MINGJIAO]		= 18,  -- 明教
	[Env.FACTION_ID_DALIDUANSHI]	= 19,  -- 大理段氏
	[Env.FACTION_ID_GUMU] 			= 20,  -- 古墓
};

Faction.TSKID_FACTION_ROUTE			 = 1;	-- 路线
Faction.TSKID_IS_FACTION_RECORD_USED = 2;	-- 本记录是否已经使用，未使用为0，已使用为1
Faction.TSKID_SKILL_POINT_START		 = 100;	-- 储存技能点的起始task id, 高位3字节为skill id, 低位一字节为等级
Faction.TSKID_SKILL_POINT_END		 = 200;

Faction.tbPotential2TaskId = {
	nBaseStrength	= 201,
	nBaseDexterity	= 202,
	nBaseVitality	= 203,
	nBaseEnergy		= 204,
};

Faction.TSKID_LEFT_SKILL		= 251;	-- 左键
Faction.TSKID_RIGHT_SKILL		= 252;	-- 右键
Faction.TSKID_SKILLTREE_START	= 260;	-- 左右快捷键
Faction.TSKID_SKILLTREE_END		= 300;

Faction.TSKID_SHORTCUT_START	= 600;	-- 物品栏
Faction.TSKID_SHORTCUT_END		= 700;

-- 五行到其记录的GroupId
Faction.tbSeriesRecGroupId = {
	[1] = 31;
	[2] = 32;
	[3] = 33;
	[4] = 34;
	[5] = 35;
};
Faction.TSKID_IS_REPUTE_RECORD_USED		 = 1; -- 这个五行的记录是否已经使用

Faction.TSKID_REPUTE_START			 = 5000;
Faction.REPUTE_REC_LENGTH			 = 16; -- 记录最大长度
                                        
Faction.OFFSET_REPUTE_CHANGE_TIME	 = 1;                                         
Faction.OFFSET_REPUTE_WEEK_DELTA	 = 2;                                         
Faction.OFFSET_REPUTE_LEVEL			 = 3;                                         
Faction.OFFSET_REPUTE_VALUE			 = 4;                                         
                                         
Faction.tbSeriesRec = 
{-- {camp, class}
	{4, 1},	-- 家族关卡
	{2, 1}, -- 宋金扬州
	{2, 2}, -- 宋金凤翔
	{2, 3}, -- 宋金襄阳
	{5, 1}, -- 白虎堂
	{1, 1}, -- 义军
};

Faction.GUMU_FRIEND_REPUTE_CAMP = 1;
Faction.GUMU_FRIEND_REPUTE_CLASS = 4;
Faction.GUMU_FRIEND_REPUTE_CAN_FUXIU_LEVEL = 2;

assert(Faction.TSKID_REPUTE_START + Faction.REPUTE_REC_LENGTH * #Faction.tbSeriesRec < 65535); -- 不能超过 task id 限制

-- 初始化转门派信息
function Faction:InitChangeFaction(pPlayer)
	if(pPlayer.GetTask(self.TSKGID_FACTION_INFO, self.TSKID_USED_FACTION_START) == 0)then
		pPlayer.SetTask(self.TSKGID_FACTION_INFO, self.TSKID_ORIGINAL_FACTION, pPlayer.nFaction); -- 原始门派
		pPlayer.SetTask(self.TSKGID_FACTION_INFO, self.TSKID_USED_FACTION_START, pPlayer.nFaction); -- 主修门派
	end
end

function Faction:IsInit(pPlayer)
	if(pPlayer.GetTask(self.TSKGID_FACTION_INFO, self.TSKID_USED_FACTION_START) > 0)then
		return 1;
	else
		return 0;
	end
end

-- 清数据
function Faction:Clear(pPlayer)
	pPlayer.ClearTaskGroup(Faction.TSKGID_FACTION_INFO);
	
	for k, v in pairs(self.tbFactionRecGroupId)do
		pPlayer.ClearTaskGroup(v);
	end
	
	for k, v in pairs(self.tbSeriesRecGroupId)do
		pPlayer.ClearTaskGroup(v);
	end
end

-- 设置要转那种门派, 1表示主修, 2表示二修, 3表示三修...设为0表示已经转过了
function Faction:SetChangeGenreIndex(pPlayer, nIndex)
	pPlayer.SetTask(self.TSKGID_FACTION_INFO, self.TSKID_CHANGE_FACTION_INDEX, nIndex);
end

-- 获取要转的门派
function Faction:GetChangeGenreIndex(pPlayer)
	return pPlayer.GetTask(self.TSKGID_FACTION_INFO, self.TSKID_CHANGE_FACTION_INDEX);
end

-- 转当前正在使用的门派（当前存储在 skillMgr 的门派）
-- pPlayer: KLuaPlayer
-- nFactionId: 目标门派id
-- 返回：转成功返回1，不成功返回0, szErrorMsg
-- 在确定所有条件ok的前提下，把对应门派类别（主修副修）转为指定的门派
-- 如果目标门派已有记录，则采用该记录里面的数据，否则洗潜能点以及技能点
function Faction:__ChangeFaction(pPlayer, nFactionId)
	assert(nFactionId >= 1 and nFactionId <= Player.FACTION_NUM);
	assert(pPlayer.nFaction >= 1);
	
	pPlayer.SetTask(self.TSKGID_FACTION_INFO, self.TSKID_PREV_FACTION, pPlayer.nFaction);
	local nOldSeries = Player.tbFactions[pPlayer.nFaction].nSeries;
	local nNewSeries = Player.tbFactions[nFactionId].nSeries;
	
	pPlayer.ClearTaskGroup(self.tbFactionRecGroupId[pPlayer.nFaction]);
	
	self:__RecordCurrLeftRightSkill(pPlayer);
	self:__RecordCurrShortCut(pPlayer)
	-- 清除被动触发技能
	pPlayer.ClearAutoCastSkill();
	
	local bSeriesIsChanged = (nOldSeries ~= nNewSeries);
	if(bSeriesIsChanged)then 
		local nSeries = Player.tbFactions[pPlayer.nFaction].nSeries;
		pPlayer.ClearTaskGroup(self.tbSeriesRecGroupId[nSeries]);
		self:__RecordCurrRepute(pPlayer);
		pPlayer.DelFightSkill(FightSkill.tbAngerSkill[nOldSeries]);
	end
	
	self:__RecordCurrFaction(pPlayer);
	
	-- 洗点
	pPlayer.SetTask(2,1,1);
	
	if (pPlayer.GetCamp() == 6) then
		if (pPlayer.IsHaveSkill(91)) then
			pPlayer.DelFightSkill(91);	-- 银丝飞蛛
		end
		if (pPlayer.IsHaveSkill(163)) then
			pPlayer.DelFightSkill(163);	-- 梯云纵
		end
		if (pPlayer.IsHaveSkill(1417)) then
			pPlayer.DelFightSkill(1417);	-- 1级移形换影
		end
	end

	pPlayer.ResetFightSkillPoint();
	pPlayer.UnAssignPotential();
	pPlayer.JoinFaction(nFactionId);
	
	-- GM号
	if (pPlayer.GetCamp() == 6) then
		pPlayer.AddFightSkill(91, 60);	-- 银丝飞蛛
		pPlayer.AddFightSkill(163, 60);	-- 梯云纵
		pPlayer.AddFightSkill(1417, 1);	-- 1级移形换影
	end

				---- 转门派后... ------
	self:__RestoreFaction(pPlayer, nFactionId);
	
	if(bSeriesIsChanged)then 
		self:__RestoreRepute(pPlayer, Player.tbFactions[nFactionId].nSeries);
		pPlayer.AddFightSkill(FightSkill.tbAngerSkill[nNewSeries],1);
	end
	
	self:__RestoreLeftRightSkill(pPlayer, nFactionId);
	self:__RestoreShortCut(pPlayer, nFactionId);
	self:__Change_WuXingYin_PiFeng(pPlayer, nFactionId);
	
	if (_KLuaPlayer.ClearState) then -- 检测此函数是否存在
  		pPlayer.ClearState(0, -1, 0, 0);
	end
end

function Faction:__RecordCurrFaction(pPlayer)
	if(pPlayer.nFaction == 0)then
		return;
	end
	
	local nFactionGroupId = self.tbFactionRecGroupId[pPlayer.nFaction];
	
	-- 记录路线
	pPlayer.SetTask(nFactionGroupId, self.TSKID_FACTION_ROUTE, pPlayer.nRouteId, 1);  -- 强制同步
	
	-- 标记本记录已使用
	pPlayer.SetTask(nFactionGroupId, self.TSKID_IS_FACTION_RECORD_USED, 1);
	
	-- 记录技能分配
	local tbSkillList = nil;
	if(pPlayer.nRouteId == 0)then
		tbSkillList = {}
	else
		tbSkillList = pPlayer.GetFightSkillList(pPlayer.nRouteId);
	end
	
	local nSkillTaskId;
	for i, v in ipairs(tbSkillList)do
		nSkillTaskId = self.TSKID_SKILL_POINT_START + i - 1; -- i从1开始
		assert(nSkillTaskId < self.TSKID_SKILL_POINT_END);	-- 技能数量超过任务变量允许范围
		local n_SkillId_Level = 0;
		n_SkillId_Level = Lib:SetBits(n_SkillId_Level, v.uId, 0, 23);
		n_SkillId_Level = Lib:SetBits(n_SkillId_Level, v.nLevel, 24, 31);
		pPlayer.SetTask(nFactionGroupId, nSkillTaskId, n_SkillId_Level);
	end
	
	-- 记录潜能分配
	for szAttr, nTaskId in pairs(self.tbPotential2TaskId) do
		pPlayer.SetTask(nFactionGroupId, nTaskId, pPlayer[szAttr]);
	end
end

function Faction:__RestoreFaction(pPlayer, nFactionId)
	if(nFactionId == 0)then
		return;
	end
	
	local nFactionGroupId = self.tbFactionRecGroupId[nFactionId];
	
	if(pPlayer.GetTask(nFactionGroupId, self.TSKID_IS_FACTION_RECORD_USED) == 0)then
		return;
	end
	
	local nRouteId = pPlayer.GetTask(nFactionGroupId, self.TSKID_FACTION_ROUTE);
	
	-- 恢复技能分配(分配技能后系统会自动洗潜能点，所以要先技能后潜能)
	for nSkillTaskId = self.TSKID_SKILL_POINT_START, self.TSKID_SKILL_POINT_END do
		local n_SkillId_Level = pPlayer.GetTask(nFactionGroupId, nSkillTaskId);
		
		if(n_SkillId_Level == 0)then
			break;
		end
		
		local nSkillId = Lib:LoadBits(n_SkillId_Level, 0, 23);
		local nSkillLevel = Lib:LoadBits(n_SkillId_Level, 24, 31); 
		if nFactionId == Env.FACTION_ID_CUIYAN and nRouteId == 2 then
			if nSkillId == 115 then
				nSkillId = 812;
				n_SkillId_Level = 0;
				n_SkillId_Level = Lib:SetBits(n_SkillId_Level, nSkillId, 0, 23);
				n_SkillId_Level = Lib:SetBits(n_SkillId_Level, nSkillLevel, 24, 31);
				pPlayer.SetTask(nFactionGroupId, nSkillTaskId, n_SkillId_Level);
			end
		end
		for i = 1, nSkillLevel do
			pPlayer.LevelUpFightSkill(nRouteId, nSkillId);
		end
	end
		
	-- 恢复潜能分配 nStr,nDex,nVit,nEng
	pPlayer.ApplyAssignPotential(
		pPlayer.GetTask(nFactionGroupId, self.tbPotential2TaskId.nBaseStrength) - pPlayer.nBaseStrength,
		pPlayer.GetTask(nFactionGroupId, self.tbPotential2TaskId.nBaseDexterity) - pPlayer.nBaseDexterity,
		pPlayer.GetTask(nFactionGroupId, self.tbPotential2TaskId.nBaseVitality) - pPlayer.nBaseVitality,
		pPlayer.GetTask(nFactionGroupId, self.tbPotential2TaskId.nBaseEnergy) - pPlayer.nBaseEnergy
	);
end

function Faction:__RecordCurrRepute(pPlayer)
	local nSeries = Player.tbFactions[pPlayer.nFaction].nSeries;
	local nGroupId = self.tbSeriesRecGroupId[nSeries];
	
	for nIndex, tbRepute in ipairs(self.tbSeriesRec)do
		local nCampId	  = tbRepute[1];
		local nClassId	  = tbRepute[2];
		local nValue	  = pPlayer.GetReputeValue(nCampId, nClassId);
		local nLevel	  = pPlayer.GetReputeLevel(nCampId, nClassId);
		local nChangeTime = pPlayer.GetReputeChangeTime(nCampId, nClassId);
		local nWeekDelta  = pPlayer.GetWeekRepute(nCampId, nClassId);
		
		local nBaseTaskId	= self.TSKID_REPUTE_START + (nIndex - 1) * self.REPUTE_REC_LENGTH;
		pPlayer.SetTask(nGroupId, nBaseTaskId + self.OFFSET_REPUTE_VALUE, nValue);
		pPlayer.SetTask(nGroupId, nBaseTaskId + self.OFFSET_REPUTE_LEVEL, nLevel);
		pPlayer.SetTask(nGroupId, nBaseTaskId + self.OFFSET_REPUTE_CHANGE_TIME, nChangeTime);
		pPlayer.SetTask(nGroupId, nBaseTaskId + self.OFFSET_REPUTE_WEEK_DELTA, nWeekDelta);
	end
	
	pPlayer.SetTask(nGroupId, self.TSKID_IS_REPUTE_RECORD_USED, 1);
end

function Faction:__RestoreRepute(pPlayer, nSeries)
	local nGroupId = self.tbSeriesRecGroupId[nSeries];
	if(pPlayer.GetTask(nGroupId, self.TSKID_IS_REPUTE_RECORD_USED) ~= 1)then
		-- 重置声望值
		for nIndex, tbRepute in ipairs(self.tbSeriesRec)do
			local nCampId	  = tbRepute[1];
			local nClassId	  = tbRepute[2];
			pPlayer.ResetReputeLevelAndValue(nCampId, nClassId);
		end
		
		return;
	end
	
	for nIndex, tbRepute in ipairs(self.tbSeriesRec) do
		local nCampId	  = tbRepute[1];
		local nClassId	  = tbRepute[2];
		local nValue, nLevel, nChangeTime, nWeekDelta = self:__GetReputeRecord(pPlayer, nSeries, nIndex);
		pPlayer.SetReputeLevelAndValue(nCampId, nClassId, nLevel, nValue);
		pPlayer.SetReputeWeekDelta(nCampId, nClassId, nWeekDelta, nChangeTime);
	end	
end

function Faction:__GetReputeRecord(pPlayer, nSeries, nIndex)
	local nGroupId    = self.tbSeriesRecGroupId[nSeries];
	local tbRepute	  = self.tbSeriesRec[nIndex];
	local nBaseTaskId = self.TSKID_REPUTE_START + (nIndex - 1) * self.REPUTE_REC_LENGTH;
	local nValue 	  = pPlayer.GetTask(nGroupId, nBaseTaskId + self.OFFSET_REPUTE_VALUE);
	local nLevel 	  = pPlayer.GetTask(nGroupId, nBaseTaskId + self.OFFSET_REPUTE_LEVEL);
	local nChangeTime = pPlayer.GetTask(nGroupId, nBaseTaskId + self.OFFSET_REPUTE_CHANGE_TIME);
	local nWeekDelta  = pPlayer.GetTask(nGroupId, nBaseTaskId + self.OFFSET_REPUTE_WEEK_DELTA);
	return nValue, nLevel, nChangeTime, nWeekDelta;
	
end

-- 记录当前左右键
function Faction:__RecordCurrLeftRightSkill(pPlayer)
	local nTaskGroup = self.tbFactionRecGroupId[pPlayer.nFaction];
	local nLeftSkill, nRightSkill = FightSkill:LoadSkillTask(pPlayer);
	pPlayer.SetTask(nTaskGroup, self.TSKID_LEFT_SKILL, nLeftSkill);
	pPlayer.SetTask(nTaskGroup, self.TSKID_RIGHT_SKILL, nRightSkill);
	
	for nKey = 0, FightSkill.SKILLTREE_KEY_COUNT  do
		local value = pPlayer.GetTask(FightSkill.TSKGID_LEFT_RIGHT_SKILL, nKey + 1);
		pPlayer.SetTask(nTaskGroup, self.TSKID_SKILLTREE_START + nKey, value);
	end
end

-- 恢复左右键
function Faction:__RestoreLeftRightSkill(pPlayer, nFactionId)
	local nTaskGroup = self.tbFactionRecGroupId[nFactionId];
	local nLeftSkill = pPlayer.GetTask(nTaskGroup, self.TSKID_LEFT_SKILL);
	local nRightSkill = pPlayer.GetTask(nTaskGroup, self.TSKID_RIGHT_SKILL);
	FightSkill:SaveLeftSkillEx(pPlayer, nLeftSkill);
	FightSkill:SaveRightSkillEx(pPlayer, nRightSkill);
	
	for nKey = 0, FightSkill.SKILLTREE_KEY_COUNT  do
		local value = pPlayer.GetTask(nTaskGroup, self.TSKID_SKILLTREE_START + nKey);
		pPlayer.SetTask(FightSkill.TSKGID_LEFT_RIGHT_SKILL, nKey + 1, value);
	end
end

-- 记录快捷栏
function Faction:__RecordCurrShortCut(pPlayer)
	local nTaskGroup = self.tbFactionRecGroupId[pPlayer.nFaction];
	for i = 1, Item.TSKID_SHORTCUTBAR_FLAG do -- copy 快捷栏用到的全部任务变量
		local value = pPlayer.GetTask(Item.TSKGID_SHORTCUTBAR, i);
		pPlayer.SetTask(nTaskGroup, self.TSKID_SHORTCUT_START + i - 1, value);
	end
end

-- 恢复快捷栏
function Faction:__RestoreShortCut(pPlayer, nFactionId)
	local nTaskGroup = self.tbFactionRecGroupId[nFactionId];
	-- 第一次切换到这个门派的话，就保留之前门派除了技能之外的快捷栏设定
	if (pPlayer.GetTask(nTaskGroup, self.TSKID_IS_FACTION_RECORD_USED) == 0) then
		local nTaskGroupPrev = self.tbFactionRecGroupId[self:GetPrevFaction(pPlayer)];
		local nFlags = pPlayer.GetTask(nTaskGroupPrev, self.TSKID_SHORTCUT_START + Item.TSKID_SHORTCUTBAR_FLAG - 1);
		local nNewFlags = nFlags;
		
		for nPos = 0, Item.SHORTCUTBAR_OBJ_MAX_SIZE - 1 do
			local nType = Lib:LoadBits(nFlags, nPos * 3, nPos * 3 + 2);	-- 每个类型占3位
			if (nType == Item.SHORTCUTBAR_TYPE_SKILL) then
				nNewFlags = Lib:SetBits(nNewFlags, Item.SHORTCUTBAR_TYPE_NONE, nPos * 3, nPos * 3 + 2);
			else -- 保留之前门派的药水和蔬菜
				local value = pPlayer.GetTask(nTaskGroupPrev, self.TSKID_SHORTCUT_START + nPos);
				pPlayer.SetTask(Item.TSKGID_SHORTCUTBAR, nPos + 1, value);
			end
		end	
		pPlayer.SetTask(Item.TSKGID_SHORTCUTBAR, Item.TSKID_SHORTCUTBAR_FLAG, nNewFlags);
	else
		for i = 1, Item.TSKID_SHORTCUTBAR_FLAG do
			local value = pPlayer.GetTask(nTaskGroup, self.TSKID_SHORTCUT_START + i - 1);
			pPlayer.SetTask(Item.TSKGID_SHORTCUTBAR, i, value);
		end
	end
end

-- 改变玩家身上五行印及披风的属性
function Faction:__Change_WuXingYin_PiFeng(pPlayer, nFactionId)
	local pItem = pPlayer.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_SIGNET, 0);
	if pItem then
		Item:ChangeEquipToFac(pItem, nFactionId);
	end
	
	pItem = pPlayer.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
	if pItem then
		Item:ChangeEquipToFac(pItem, nFactionId);
	end	
	
	pItem = pPlayer.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_CHOP, 0);
	if pItem then
		Item:ChangeEquipToFac(pItem, nFactionId);
	end
end


-- 返回指定的声望等级和数值
-- 记录不存在的话返回nil
function Faction:GetRepute(pPlayer, nSeries, nCampId, nClassId)
	if (pPlayer.GetTask(self.tbSeriesRecGroupId[nSeries], self.TSKID_IS_REPUTE_RECORD_USED) == 0) then
		return;
	end
	
	local nIndex = nil;
	for i, tbRepute in ipairs(self.tbSeriesRec)do
		if(tbRepute[1] == nCampId and tbRepute[2] == nClassId)then
			nIndex = i;
			break;
		end
	end
	if(not nIndex)then
		return;
	end
	
	local nValue, nLevel, nChangeTime, nWeekDelta = self:__GetReputeRecord(pPlayer, nSeries, nIndex);
	return nValue, nLevel, nChangeTime, nWeekDelta;
end

-- 切换门派
function Faction:SwitchFaction(pPlayer, nFactionId)
	assert(self:IsInit(pPlayer) == 1); --没初始化
	if(self:IsForbidSwitchFaction(pPlayer) == 1)then
		return 0, "Không cho phép chuyển đổi môn phái";
	end
	
	local nResult = self:__GetFactionUseIndex(pPlayer, nFactionId);
	if(nResult <= 0)then
		return 0, "Bạn chưa có môn phái";
	end
	
	if(pPlayer.nTeamId > 0)then
		return 0, "Không thể chuyển đổi môn phái khi đang tổ đội";
	end
	
	local nCurrTime = GetTime();
	
	if(pPlayer.nFightState == 1)then
		return 0, "Không thể đổi môn phái khi đang ở khu luyện công";
	end
	
	if( pPlayer.nMapId ~= 255 and  -- 洗髓岛无cd限制
		pPlayer.GetSkillState(self.SWITCH_FACTION_BUF_ID) > 0
	)then
		return 0, "Chưa hết thời gian giãn cách.";
	end
	
	if( pPlayer.nMapId ~= 255)then -- 洗髓岛
		pPlayer.AddSkillState(self.SWITCH_FACTION_BUF_ID, 1, 1, self.SWITCH_FACTION_CD * Env.GAME_FPS, 1, 1, 1); -- 真实时间，死亡不清
	end
	
	local nPrevFaction = pPlayer.nFaction;
	
	self:__ChangeFaction(pPlayer, nFactionId);
	pPlayer.CallClientScript({"Faction:OnChangeGerneFactionFinished"});
	
	self:WriteLog(Dbg.LOG_INFO, "SwitchFaction", pPlayer.szName, nPrevFaction, nFactionId);
	
	local szMsg = "";
	if (pPlayer.nMapId ~= 255) then
		szMsg = "Chuyển sang %s thành công. Trong 5 phút, không thể chuyển đổi thêm nữa.";
	else
		szMsg = "Chuyển sang %s thành công."
	end
	szMsg = string.format(szMsg, Player.tbFactions[nFactionId].szName);
	pPlayer.Msg(szMsg);
	return 1;
end

-- 是否已经修炼该门派
-- 已经修炼的话返回修炼的是第几个
-- 还没炼就返回 0
function Faction:__GetFactionUseIndex(pPlayer, nFactionId)
	for nTskId = self.TSKID_USED_FACTION_START, self.TSKID_USED_FACTION_START + self.MAX_USED_FACTION - 1 do
		local nUsedFactionId = pPlayer.GetTask(self.TSKGID_FACTION_INFO, nTskId);
		if(nUsedFactionId == nFactionId)then
			return nTskId - self.TSKID_USED_FACTION_START + 1;
		end
	end
	
	return 0;
end

-- 禁用换门派，1表示禁止，0表示不禁止
function Faction:SetForbidSwitchFaction(pPlayer, bForbid)
	self:GetPlayerTempTable(pPlayer).bForbidSwitchFaction	= bForbid;
end

-- 是否禁止换门派
function Faction:IsForbidSwitchFaction(pPlayer)
	if(self:GetPlayerTempTable(pPlayer).bForbidSwitchFaction == 1)then
		return 1;
	else
		return 0;
	end
end

-- 获取当前角色修炼过的所有门派id的数组，按门派1，门派2... 排序（没辅修过就返回空table）
function Faction:GetGerneFactionInfo(pPlayer)
	local tbGerneFaction = {};

	for nTskId = self.TSKID_USED_FACTION_START, self.TSKID_USED_FACTION_START + self.MAX_USED_FACTION - 1 do
		local nUsedFactionId = pPlayer.GetTask(self.TSKGID_FACTION_INFO, nTskId);
		if(nUsedFactionId == 0)then
			break;
		end
		table.insert(tbGerneFaction, nUsedFactionId);
	end

	return tbGerneFaction;
end

-- 检查这个门派能否更换，可以的话返回1，不可以的话返回0及出错信息
function Faction:CheckGenreFaction(pPlayer, nFactionGenre, nFactionId)
	local nCurrFactionId = pPlayer.nFaction;
	if(nCurrFactionId == 0)then
		return 0, "Hãy gia nhập môn phái";
	end
	
	if(self:__GetFactionUseIndex(pPlayer, nFactionId) > 0 or 
		nCurrFactionId == nFactionId)
	then
		return 0, "Không thể chuyển đổi sang môn phái này";
	end
		
	local nChangeFactionIndex = self:GetChangeGenreIndex(pPlayer);
	assert(nChangeFactionIndex >= 1);
	
	if(nChangeFactionIndex >  self.MAX_USED_FACTION)then
		return 0, "Không thể phụ tu thêm";
	end

	-- if (nFactionId == Env.FACTION_ID_GUMU) then
		-- if (self:IsOpenGumuFuXiu() == 0) then
			-- return 0, "Chưa thể phụ tu Cổ Mộ Phái";
		-- end
		
		-- if (pPlayer.nLevel < 100) then
			-- return 0, string.format("Chưa đạt cấp độ 100.");
		-- end
		
		-- local nLevel = pPlayer.GetReputeLevel(self.GUMU_FRIEND_REPUTE_CAMP, self.GUMU_FRIEND_REPUTE_CLASS);
		-- if (nLevel < self.GUMU_FRIEND_REPUTE_CAN_FUXIU_LEVEL) then
			-- return 0, string.format("Danh vọng Cổ Mộ chưa đạt cấp %s, không thể phụ tu!", self.GUMU_FRIEND_REPUTE_CAN_FUXIU_LEVEL);
		-- end
		
	-- end
	
	local nSexLimit = Player.tbFactions[nFactionId].nSexLimit;
	
	if(nSexLimit ~= -1 and nSexLimit ~= pPlayer.nSex)then
		return 0, "Giới tính không phù hợp...";
	end	
	
	return 1;
end

-- 换门派
-- nFactionGenre 1为主修，2为副修1，3为副修2...
-- nFactionId 要换成什么门派
function Faction:ChangeGenreFaction(pPlayer, nFactionGenre, nFactionId)
	assert(nFactionGenre <= self.MAX_USED_FACTION); 
	assert(self:IsInit(pPlayer) == 1); --没初始化
	
	local nResult, szMsg = self:CheckGenreFaction(pPlayer, nFactionGenre, nFactionId);
	if (nResult == 0) then
		return 0, szMsg;
	end
	
	local nCurrFactionId = pPlayer.nFaction;
	local nCurrFactionUsedIdx = self:__GetFactionUseIndex(pPlayer, nCurrFactionId);
	if(nCurrFactionUsedIdx == nFactionGenre)then 
		self:__ChangeFaction(pPlayer, nFactionId);
	end
	
	pPlayer.SetTask(self.TSKGID_FACTION_INFO, self.TSKID_USED_FACTION_START + nFactionGenre - 1, nFactionId);
	
	if(nCurrFactionUsedIdx == nFactionGenre)then 
		pPlayer.CallClientScript({"Faction:OnChangeGerneFactionFinished"});
	end
	
	self:WriteLog(Dbg.LOG_INFO, "ChangeGenreFaction", pPlayer.szName, 
		nFactionGenre, nCurrFactionId, nFactionId);
	
	return 1;
end

-- 根据门派类别获得相应门派
-- 这个类别没修的话就返回0，否则返回门派id
function Faction:Genre2Faction(pPlayer, nFactionGenre)
	assert(nFactionGenre <= Faction.MAX_USED_FACTION);
	return pPlayer.GetTask(self.TSKGID_FACTION_INFO, self.TSKID_USED_FACTION_START + nFactionGenre - 1);
end

-- 获得原始门派
function Faction:GetOriginalFaction(pPlayer)
	return pPlayer.GetTask(Faction.TSKGID_FACTION_INFO, Faction.TSKID_ORIGINAL_FACTION);
end

-- 切换门派完成之后的回调
function Faction:OnChangeGerneFactionFinished()
	
	FightSkill:LoadShortcut(me); -- 重新加载左右键
	UiNotify:OnNotify(UiNotify.emCOREEVENT_CHANGE_FACTION_FINISHED);
end

-- 获取玩家还可以更换多少次辅修
function Faction:GetMaxModifyTimes(pPlayer)
	return self.MAX_MODIFY_TIME	+ pPlayer.GetTask(7, self.TSKID_MODIFY_FACTION_NUM_EX);
end

-- 增加玩家更换辅修次数（即使玩家还没辅修也可以用）
function Faction:AddExtraModifyTimes(pPlayer, nTimes)
	assert(nTimes>0); --减少辅修次数的话还要注意处理原有次数
	local nExTimes = pPlayer.GetTask(7, self.TSKID_MODIFY_FACTION_NUM_EX);
	pPlayer.SetTask(7, self.TSKID_MODIFY_FACTION_NUM_EX, nExTimes+nTimes);
end

-- 获取切换前的门派
function Faction:GetPrevFaction(pPlayer)
	if (self:IsInit(pPlayer) ~= 1) then
		return nil;
	end
	
	return pPlayer.GetTask(self.TSKGID_FACTION_INFO, self.TSKID_PREV_FACTION);
end

-- 获取改变门派的次数
function Faction:GetModifyFactionNum(pPlayer)
	return pPlayer.GetTask(self.TSKGID_FACTION_INFO, self.TSKID_MODIFY_FACTION_NUM);
end

-- 更改改变门派的次数
function Faction:SetModifyFactionNum(pPlayer, nNum)
	pPlayer.SetTask(self.TSKGID_FACTION_INFO, self.TSKID_MODIFY_FACTION_NUM, nNum);
end

function Faction:RE()
	DoScript("\\script\\faction\\changefaction.lua");
	DoScript("\\script\\player\\xisuidao\\xisuidao.lua");
	DoScript("\\script\\player\\xisuidao\\xisuinpc.lua");
	DoScript("\\script\\mission\\mission.lua");
	DoScript("\\script\\mission\\test.lua");
	me.Msg("Reload!!!");
end

-- 测试用，把声望加上指定值
function Faction:AddRepute(pPlayer, tbVal)
	for i, tbRepute in ipairs(self.tbSeriesRec)do
		pPlayer.AddRepute(tbRepute[1], tbRepute[2], tbVal[i]);
	end
end

-- 刷新服务器最大多修数
function Faction:RefreshMaxFaction()
	local nLimit = KGblTask.SCGetDbTaskInt(DBTASK_FACTION_LIMIT);
	if nLimit >= 1 then
		self.MAX_USED_FACTION = nLimit;
	end
end

-- 刀翠改技能修复
function Faction:RepairsDaoCuiYanSkill()
	if me.nFaction == Env.FACTION_ID_CUIYAN and me.nRouteId == 2 then
		if me.IsHaveSkill(115) == 1 then
			local nLevel = me.GetSkillBaseLevel(115);
			me.DelFightSkill(115);
			if me.IsHaveSkill(812) ~= 1 and nLevel > 0 then
				me.AddFightSkill(812, nLevel);
			end 
		end
	end
end

-- 修复门派辅修成就
function Faction:RepairAchievement()
	local tbGerneFaction = Faction:GetGerneFactionInfo(me) or {};
	local nNum = #tbGerneFaction;
	if nNum == 2 then
		Achievement:FinishAchievement(me, 64);
	elseif nNum >= 3 then
		Achievement:FinishAchievement(me, 64);
		Achievement:FinishAchievement(me, 65);
	end
end

function Faction:AchieveTask(pPlayer, nType)
	if (self:IsOpenGumuFuXiuTask() == 0) then
		return 0;
	end

	if (nType == self.TYPE_XOYO) then
		if (Task:GetPlayerTask(pPlayer).tbTasks[self.TASK_DAILY_GAME]) then
			pPlayer.SetTask(self.REPUTETASK_GROUPID, self.REPUTETASK_TASKID_XOYO_DAILY, 1);
		end
	elseif (nType == self.TYPE_YINYANGSHIGUANGDIAN) then
		if (Task:GetPlayerTask(pPlayer).tbTasks[self.TASK_WEEK_GAME]) then
			pPlayer.SetTask(self.REPUTETASK_GROUPID, self.REPUTETASK_TASKID_SHIGUANGDIAN, 1);
		end
	elseif (nType == self.TYPE_CHENCHONGZHEN) then
		if (Task:GetPlayerTask(pPlayer).tbTasks[self.TASK_WEEK_GAME]) then
			pPlayer.SetTask(self.REPUTETASK_GROUPID, self.REPUTETASK_TASKID_CHENCHONGZHEN, 1);
		end
	end
end

function Faction:IsOpenGumuZhuxiu()
	local nIsZhuxiu = KGblTask.SCGetDbTaskInt(DBTASK_OPEN_GUMU_FACTION) or 0;
	return nIsZhuxiu;
end

-- 0 关闭，1 开启
function Faction:SetGumuZhuxiuState(nState)
	KGblTask.SCSetDbTaskInt(DBTASK_OPEN_GUMU_FACTION, nState);
end

function Faction:IsOpenGumuFuXiu()
	local nIsFuxiu = KGblTask.SCGetDbTaskInt(DBTASK_OPEN_GUMU_FUXIU) or 0;
	return nIsFuxiu;
end

-- 0 关闭，1 开启
function Faction:SetGumuFuxiuState(nState)
	KGblTask.SCSetDbTaskInt(DBTASK_OPEN_GUMU_FUXIU, nState);
end

function Faction:IsOpenGumuFuXiuTask()
	local nIsFuxiu = KGblTask.SCGetDbTaskInt(DBTASK_OPEN_GUMU_FUXIU_TASK) or 0;
	return nIsFuxiu;
end

-- 0 关闭，1 开启
function Faction:SetGumuFuxiuTaskState(nState)
	KGblTask.SCSetDbTaskInt(DBTASK_OPEN_GUMU_FUXIU_TASK, nState);
end

function Faction:DailyEvent()
	if (self:IsOpenGumuFuXiuTask() == 0) then
		return 0;
	end	
	local nWeekXoyoCount = me.GetTask(self.REPUTETASK_GROUPID, self.REPUTETASK_TASKID_XOYO_WEEKCOUNT);
	if (nWeekXoyoCount < 5) then
		me.SetTask(self.REPUTETASK_GROUPID, self.REPUTETASK_TASKID_XOYO_DAILY, 0);
	end
end

function Faction:WeekEvent()
	if (self:IsOpenGumuFuXiuTask() == 0) then
		return 0;
	end
	me.SetTask(self.REPUTETASK_GROUPID, self.REPUTETASK_TASKID_XOYO_WEEKCOUNT, 0);
	me.SetTask(self.REPUTETASK_GROUPID, self.REPUTETASK_TASKID_CHENCHONGZHEN, 0);
	me.SetTask(self.REPUTETASK_GROUPID, self.REPUTETASK_TASKID_SHIGUANGDIAN, 0);
	me.SetTask(self.REPUTETASK_GROUPID, self.REPUTETASK_TASKID_XOYO_DAILY, 0);
end

function Faction:GetStoreFactionSkillList(pPlayer, nFactionId)
	if(nFactionId <= 0)then
		return;
	end
	
	local tbSkillList = {};
	
	local nFactionGroupId = self.tbFactionRecGroupId[nFactionId];
	
	if(pPlayer.GetTask(nFactionGroupId, self.TSKID_IS_FACTION_RECORD_USED) == 0)then
		return;
	end
	
	local nRouteId = pPlayer.GetTask(nFactionGroupId, self.TSKID_FACTION_ROUTE);
	
	-- 恢复技能分配(分配技能后系统会自动洗潜能点，所以要先技能后潜能)
	for nSkillTaskId = self.TSKID_SKILL_POINT_START, self.TSKID_SKILL_POINT_END do
		local n_SkillId_Level = pPlayer.GetTask(nFactionGroupId, nSkillTaskId);
		
		if(n_SkillId_Level == 0)then
			break;
		end
		
		local nSkillId = Lib:LoadBits(n_SkillId_Level, 0, 23);
		local nSkillLevel = Lib:LoadBits(n_SkillId_Level, 24, 31); 
		tbSkillList[nSkillId] = nSkillLevel;		
	end
	return tbSkillList, nRouteId;
end

function Faction:GetStoreFactionRoute(pPlayer, nFactionId)
	if(nFactionId <= 0)then
		return 0;
	end
	
	local nFactionGroupId = self.tbFactionRecGroupId[nFactionId];
	
	if(pPlayer.GetTask(nFactionGroupId, self.TSKID_IS_FACTION_RECORD_USED) == 0)then
		return 0;
	end
	
	local nRouteId = pPlayer.GetTask(nFactionGroupId, self.TSKID_FACTION_ROUTE);
	return nRouteId;
end

if(MODULE_GAMESERVER) then

PlayerEvent:RegisterOnLoginEvent(Faction.RepairsDaoCuiYanSkill, Faction);

-- 注册玩家每日事件
PlayerSchemeEvent:RegisterGlobalDailyEvent({Faction.DailyEvent, Faction});

-- 注册每周事件
PlayerSchemeEvent:RegisterGlobalWeekEvent({Faction.WeekEvent, Faction});
	
ServerEvent:RegisterServerStartFunc(Faction.RefreshMaxFaction, Faction);
end
--?pl DoScript("\\script\\faction\\changefaction.lua")
