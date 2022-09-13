-- 文件名　：menter.lua
-- 创建者　：zhaoyu
-- 创建时间：2009/10/26 14:39:01
-- 描  述  ：师徒副本控制

Esport.Mentor = Esport.Mentor or {};
local Mentor = Esport.Mentor;
--Mentor.tbMissList = {};

Require("\\script\\mission\\mentor\\mentor_def.lua");

--重置一个地图到初始状态
function Mentor:ResetMap(nDynMapId)

end

--检测进入副本的条件
--1、队伍人数是2
--2、有师徒关系（徒弟未出师且等级小于师傅）
--3、徒弟副本进度（检测任务变量）
--4、副本地图人数未满
--当满足条件时返回1，否则返回0且显示提示信息
function Mentor:CheckEnterCondition(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local nTeamId = pPlayer.nTeamId;
	local anPlayerId, nPlayerNum = KTeam.GetTeamMemberList(nTeamId);
	if not anPlayerId or not nPlayerNum or nPlayerNum ~= 2 then 
		Dialog:Say("必须由师徒两人组队才能进入！");
		return 0;
	end
	
	--取出队伍中另一成员的Id
	local nOtherPlayerId = (anPlayerId[1] == pPlayer.nId) and anPlayerId[2] or anPlayerId[1];
	local pOtherPlayer = KPlayer.GetPlayerObjById(nOtherPlayerId);
	--判断队伍的两个成员间是否有未出师的师徒关系
	if pOtherPlayer and pPlayer.GetTrainingTeacher(self.RELATIONTYPE_TRAINING) ~= pOtherPlayer.szName 
		and pOtherPlayer.GetTrainingTeacher(self.RELATIONTYPE_TRAINING) ~= pPlayer.szName then	
		Dialog:Say("请确保二人有师徒关系且徒弟还未出师！");
		return 0;
	end
	
	local aLocalPlayer, nLocalPlayerNum = me.GetTeamMemberList()
	if nPlayerNum ~= nLocalPlayerNum or pOtherPlayer.nMapId ~= pPlayer.nMapId then
		Dialog:Say("师傅和徒弟一同前来才能进入副本！！")
		return 0
	end
	
	--判断二者中哪个是徒弟
	local pStudent = (self:CheckApprentice(pPlayer.nId) == 1) and pPlayer or pOtherPlayer;
	local pTeacher = (self:CheckMaster(pPlayer.nId) == 1) and pPlayer or pOtherPlayer;
	
	--徒弟的等级必须小于师傅的等级
	if pStudent.nLevel >= pTeacher.nLevel then
		Dialog:Say("徒弟的等级不能大于师傅的等级！");
		return 0;
	end
	
	--判断徒弟是否还有进度
	if self:GetDegree(pStudent.nId) == 0 then
		Dialog:Say("请确保徒弟当天且当周还有副本进度！");
		return 0;
	end

	--判断副本地图是否已满
	if self:IsMapFull() == 1 then
		Dialog:Say("副本地图人数已满，请呆会儿再来！");
		return 0;
	end
		
	return 1;
end

function Mentor:GetApprentice(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local nTeamId = pPlayer.nTeamId;
	local anPlayerId, nPlayerNum = KTeam.GetTeamMemberList(nTeamId);
	if not anPlayerId or not nPlayerNum or nPlayerNum ~= 2 then 
		--print("队伍人数出了问题")
		return nil;
	end
	
	--取出队伍中另一成员的Id
	local nOtherPlayerId = (anPlayerId[1] == pPlayer.nId) and anPlayerId[2] or anPlayerId[1];
	local pOtherPlayer = KPlayer.GetPlayerObjById(nOtherPlayerId);
	
	if not pOtherPlayer then
		return;
	end
	--判断队伍的两个成员间是否有未出师的师徒关系
	if pPlayer.GetTrainingTeacher(self.RELATIONTYPE_TRAINING) ~= pOtherPlayer.szName 
		and pOtherPlayer.GetTrainingTeacher(self.RELATIONTYPE_TRAINING) ~= pPlayer.szName then	
		--print("师徒关系出了问题")
		return nil;
	end
	
	--判断二者中哪个是徒弟
	local pStudent = (self:CheckApprentice(pPlayer.nId) == 1) and pPlayer or pOtherPlayer;
	
	return pStudent;
end


function Mentor:GetMaster(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local nTeamId = pPlayer.nTeamId;
	local anPlayerId, nPlayerNum = KTeam.GetTeamMemberList(nTeamId);
	if not anPlayerId or not nPlayerNum or nPlayerNum ~= 2 then 
		return nil;
	end
	
	--取出队伍中另一成员的Id
	local nOtherPlayerId = (anPlayerId[1] == pPlayer.nId) and anPlayerId[2] or anPlayerId[1];
	local pOtherPlayer = KPlayer.GetPlayerObjById(nOtherPlayerId);
	
	if not pOtherPlayer then
		return;
	end
	
	--判断队伍的两个成员间是否有未出师的师徒关系
	if pPlayer.GetTrainingTeacher(self.RELATIONTYPE_TRAINING) ~= pOtherPlayer.szName 
		and pOtherPlayer.GetTrainingTeacher(self.RELATIONTYPE_TRAINING) ~= pPlayer.szName then	
		return nil;
	end
	
	--判断二者中哪个是师傅
	local pTeacher = (self:CheckMaster(pPlayer.nId) == 1) and pPlayer or pOtherPlayer;
	
	return pTeacher;
end

--检测是否是队伍中的徒弟
function Mentor:CheckApprentice(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local nTeamId = pPlayer.nTeamId;
	local anPlayerId, nPlayerNum = KTeam.GetTeamMemberList(nTeamId);
	--队伍人数不满足副本需求
	if not anPlayerId or not nPlayerNum or nPlayerNum ~= 2 then
		return 0;
	end
	
	local nOtherPlayerId = anPlayerId[1] == nPlayerId and anPlayerId[2] or anPlayerId[1];
	local pOtherPlayer = KPlayer.GetPlayerObjById(nOtherPlayerId);
	if not pOtherPlayer then 
		return 0;
	end
	
	if pPlayer.GetTrainingTeacher() ~= pOtherPlayer.szName then
		return 0;
	end

	return 1;
end

--检测是否是队伍中的师傅
function Mentor:CheckMaster(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local nTeamId = pPlayer.nTeamId;
	local anPlayerId, nPlayerNum = KTeam.GetTeamMemberList(nTeamId);
	--队伍人数不满足副本需求
	if not anPlayerId or not nPlayerNum or nPlayerNum ~= 2 then
		return 0;
	end
	
	local nOtherPlayerId = anPlayerId[1] == nPlayerId and anPlayerId[2] or anPlayerId[1];
	local pOtherPlayer = KPlayer.GetPlayerObjById(nOtherPlayerId);
	
	if not pOtherPlayer then
		return 0;
	end
	
	if pPlayer.szName ~= pOtherPlayer.GetTrainingTeacher() then
		return 0;
	end
	
	return 1;
end

--获取副本进度，返回1，2，3
--返回0时表示当前不能进入副本
function Mentor:GetDegree(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	
	local bSetDaily, bSetWeekly = 0, 0;	--要不要先更新日/周进度 (1为要，0为不要)
	local nLastDayTime = pPlayer.GetTask(self.nGroupTask, self.nSubLastDayTime);
	local nLastWeekTime = pPlayer.GetTask(self.nGroupTask, self.nSubLastWeekTime);
	
	local nNowTime = GetTime();
	if 0 ~= nLastDayTime then
		local nLastTime_day = Lib:GetLocalDay(nLastDayTime);
		local nNowTime_day	= Lib:GetLocalDay(nNowTime);
		if nNowTime_day - nLastTime_day >= 1 then
			bSetDaily = 1;	
		end
	else
		bSetDaily = 1;
	end
	
	if 0 ~= nLastWeekTime then
		local nLastTime_week = Lib:GetLocalWeek(nLastWeekTime);
		local nNowTime_week = Lib:GetLocalWeek(nNowTime);
		if nNowTime_week - nLastTime_week >= 1 then
			bSetWeekly = 1;
		end
	else
		bSetWeekly = 1;
	end
	
	if bSetDaily == 1 then
		pPlayer.SetTask(self.nGroupTask, self.nSubLastDayTime, nNowTime);
		self:ResetDailyTask(nPlayerId);
	end
	
	if bSetWeekly == 1 then
		pPlayer.SetTask(self.nGroupTask, self.nSubLastWeekTime, nNowTime);
		self:ResetWeeklyTask(nPlayerId);
	end
	
	local nDailyRemain  = pPlayer.GetTask(self.nGroupTask, self.nSubDailyTimes);			--当天剩余次数
	local nWeeklyRemain = pPlayer.GetTask(self.nGroupTask, self.nSubWeeklyTimes);			--本周剩余次数
	local nCurDegree 	= pPlayer.GetTask(self.nGroupTask, self.nSubCurDegree);				--当前周进度
	
	--如果当日或该周的剩余次数为0，不能进入副本 
	if nDailyRemain <= 0 or nWeeklyRemain <= 0 or nCurDegree > self.WEEKLY_SCHEDULE then
		return 0;
	end
	
	
	return pPlayer.GetTask(self.nGroupTask, self.nSubCurDegree);
end

function Mentor:GetMission(pNpc)
	if not pNpc then
		--print("无效的NPC对象")
		return;
	end
	
	local nId = 0;
	if pNpc.nId then		--是玩家对象
		nId = pNpc.nId;
	elseif pNpc.dwId then	--是NPC对象
		nId = pNpc.dwId;
	else					--不会到这里来吧。
		return;
	end
	
	for i = 1, Mentor.MAX_MAP_COUNT do
		if Mentor.tbMissList[i].nApprenticePlayerId == nId 
			or Mentor.tbMissList[i].nMasterPlayerId == nId 
			or Mentor.tbMissList[i].dwProtecNpcId == nId then
				return Mentor.tbMissList[i];
		end
	end
end

function Mentor:SetGame1(tbMission)

end

function Mentor:SetGame2(tbMission)

end

function Mentor:SetGame3(tbMission)

end

function Mentor:GetNpcList(nStep)
	
end

--判断副本开启个数是否已达上限，返回1是，0否
function Mentor:IsMapFull()
	for _, tbMiss in pairs(self.tbMissList) do
		if (tbMiss.nUsed == 0) then
			return 0;
		end
	end
	
	return 1;
end

--每天0点重置FB进度
function Mentor:ResetDailyTask(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	--只有当当前玩家是徒弟（有师傅且未出师）的时候，可以设置任务变量
	if pPlayer.GetTrainingTeacher(self.RELATIONTYPE_TRAINING) then	
		pPlayer.SetTask(self.nGroupTask, self.nSubDailyTimes, self.DAILY_SCHEDULE);	--每天可进FB一次
	end
end

--每周重置FB进度
function Mentor:ResetWeeklyTask(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	--只有当当前玩家是徒弟（有师傅且未出师）的时候，可以设置任务变量
	if pPlayer.GetTrainingTeacher(self.RELATIONTYPE_TRAINING) then
		pPlayer.SetTask(self.nGroupTask, self.nSubWeeklyTimes, self.WEEKLY_SCHEDULE);	--每周可进副本三次
		pPlayer.SetTask(self.nGroupTask, self.nSubCurDegree, 1);		--每周进度重置，都从1开始
	end
end

function Mentor:Init()
	Mentor.tbMissList = {};
	for i = 1, Mentor.MAX_MAP_COUNT do
		local tbMis = Lib:NewClass(Esport.MentorMission);
		if (Map:LoadDynMap(Map.DYNMAP_TREASUREMAP, Mentor.TEMPLATE_MAP_ID, {self.OnLoadMapFinish, self, i}) ~= 1) then
			Dbg:WriteLog("Mentor_shitufuben", "师徒副本地图加载失败。", i);
		else
			table.insert(Mentor.tbMissList, tbMis);
			tbMis.nMisIndex = i;
		end
	end
end

function Mentor:PreStartMission()
	assert(me);
	if self:CheckEnterCondition(me.nId) == 1 then
		local tbMiss = self:AllocMission();
		if tbMiss then
			tbMiss:Open();
			return 1;
		else
			return 0;
		end			
	end
end

function Mentor:AllocMission()
	for _, tbMis in pairs(Mentor.tbMissList) do
		if (tbMis.nUsed == 0) then
			tbMis.nUsed = 1;
			return tbMis;
		end
	end
end

function Mentor:ReleaseMission(tbMis)
	if (tbMis.nUsed == 1) then
		tbMis.nUsed = 0;
	end
end

function Mentor:OnLoadMapFinish(nMisIndex, nDynMapId)
	local tbMis = Mentor.tbMissList[nMisIndex];
	tbMis:OnStart(nDynMapId);
	tbMis.nUsed = 0;
end

function Mentor:LoadSetting()
	Mentor.tbSetting = Lib:LoadTabFile("\\setting\\mission\\mentor\\mentor.txt");
end

Mentor:LoadSetting();

if MODULE_GAMESERVER then
	--注册GS启动事件，同步地图禁用表
	ServerEvent:RegisterServerStartFunc(Mentor.Init, Mentor);
	
	--注册任务变量定时修改回调
	--PlayerSchemeEvent:RegisterGlobalDailyEvent({Mentor.ResetDailyTask, Mentor});	--注册每天重置FB进度的回调
	--PlayerSchemeEvent:RegisterGlobalWeekEvent({Mentor.ResetWeeklyTask, Mentor});	--注册每周重置FB进度的回调
end
