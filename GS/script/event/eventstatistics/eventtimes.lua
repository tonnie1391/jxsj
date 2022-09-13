-- 文件名  : eventtimes.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-10-20 11:53:39
-- 描述    : 统计每个活动玩家参加的次数

SpecialEvent.tbPJoinEventTimes = SpecialEvent.tbPJoinEventTimes or {};
local tbPJoinEventTimes = SpecialEvent.tbPJoinEventTimes;

tbPJoinEventTimes.TASKGID = 2144;			--任务变量组
tbPJoinEventTimes.TASK_JOIN_BATTLE 		= 1; 	--当天参加宋金次数
tbPJoinEventTimes.TASK_JOIN_BAIHU		= 2; 	--当天参加白虎堂次数
tbPJoinEventTimes.TASK_OVER_BAIHU		= 3; 	--当天通过白虎堂次数
tbPJoinEventTimes.TASK_FINISH_WANTED	= 4; 	--当天完成大盗任务次数
tbPJoinEventTimes.TASK_JOIN_ARMY 		= 5; 	--当天闯军营次数
tbPJoinEventTimes.TASK_OVER_ARMY 		= 6; 	--当天成功闯过军营次数
tbPJoinEventTimes.TASK_JOIN_XOYOGAME 	= 7; 	--当天参加逍遥次数
tbPJoinEventTimes.TASK_OVER_KINGAME 		= 8; 	--当天是否闯过家族关卡
tbPJoinEventTimes.TASK_JOIN_YOULONG		= 9; 	--当天参加游龙阁次数（和芊芊对打的次数）
tbPJoinEventTimes.TASK_KILL_DaDaoBOSS 	= 10;	--当天击杀大盗boss数目
tbPJoinEventTimes.TASK_KILL_WorldBOSS 		= 11;	--当天击杀世界boss
tbPJoinEventTimes.TASK_KILL_QinLinBOSS 	= 12;	--当天击杀秦陵boss

tbPJoinEventTimes.tbEventTimes = {1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12};	--玩家完成数或者参加的次数  (对应到上面的任务变量function_checkparam默认主id都是2144)
tbPJoinEventTimes.tbJoinEvent = {8};	--玩家是否完成或者参加了某些活动 (对应到上面的任务变量function_checkparam默认主id都是2144)

-- 死亡回调
function tbPJoinEventTimes:OnKillNpc(pPlayer, szClassName)
	-- 全局服返回
	if (GLOBAL_AGENT) then
		return;
	end
	if (not pPlayer or not szClassName ) then
		return;
	end
	if  szClassName == "wanted" then
		pPlayer.SetTask(self.TASKGID, self.TASK_KILL_DaDaoBOSS, pPlayer.GetTask(self.TASKGID, self.TASK_KILL_DaDaoBOSS) + 1);
		if pPlayer.nTeamId ~= 0  then
			self:AddTimesTeam(pPlayer, self.TASK_KILL_DaDaoBOSS);
		end
	end
	if szClassName == "uniqueboss"  then
		pPlayer.SetTask(self.TASKGID, self.TASK_KILL_WorldBOSS, pPlayer.GetTask(self.TASKGID, self.TASK_KILL_WorldBOSS) + 1);
		if pPlayer.nTeamId ~= 0  then
			self:AddTimesTeam(pPlayer, self.TASK_KILL_WorldBOSS);
		end
	end
	if szClassName == "boss_qinshihuang" or szClassName == "boss_qinlingsmall" then
		pPlayer.SetTask(self.TASKGID, self.TASK_KILL_QinLinBOSS, pPlayer.GetTask(self.TASKGID, self.TASK_KILL_QinLinBOSS) + 1);
		if pPlayer.nTeamId ~= 0  then
			self:AddTimesTeam(pPlayer, self.TASK_KILL_QinLinBOSS);
		end
	end
end

function tbPJoinEventTimes:AddTimesTeam(pPlayer, nTaskId)
	local tbPlayerList = KTeam.GetTeamMemberList(pPlayer.nTeamId);
	local nMapId = pPlayer.GetWorldPos();
	for i = 1 , #tbPlayerList do		
		local nMapId2= nil;
		local pPlayerEx = KPlayer.GetPlayerObjById(tbPlayerList[i]);
		if pPlayerEx and pPlayerEx.nId ~= pPlayer.nId then
			nMapId2= pPlayerEx.GetWorldPos();
			if nMapId2 == nMapId then
				pPlayerEx.SetTask(self.TASKGID, nTaskId, pPlayerEx.GetTask(self.TASKGID, nTaskId) + 1);
			end
		end
	end
end

function tbPJoinEventTimes:DailyEvent()
	for i = 1, 12 do
		me.SetTask(self.TASKGID, i, 0);
	end
end

PlayerSchemeEvent:RegisterGlobalDailyEvent({tbPJoinEventTimes.DailyEvent, tbPJoinEventTimes});

