-------------------------------------------------------
-- 文件名　：wldh_tuanti_zhunbeiguan.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-09-02 16:24:35
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_def.lua");

local tbNpc	= Npc:GetClass("wldh_tuanti_zhunbeiguan");

function tbNpc:Init()

	if self.tbMapNpc then	
		return;
	end

	-- get npc by mapid
	local tbMapNpc	= {};	
	for nBattleIndex, nMapId in pairs(Wldh.Battle.MAPID_SIGNUP) do
		tbMapNpc[nMapId]= Lib:NewClass(Wldh.Battle.tbNpcBase, nMapId, nBattleIndex);
	end
	
	self.tbMapNpc = tbMapNpc;
end

function tbNpc:OnDialog()
	local tbNpc	= self.tbMapNpc[him.nMapId];
	tbNpc:OnDialog();
end

-- base
local tbNpcBase	= Wldh.Battle.tbNpcBase or {};
Wldh.Battle.tbNpcBase = tbNpcBase;

-- init
function tbNpcBase:init(nMapId, nBattleIndex)
	self.nMapId	= nMapId;
	self.nBattleIndex = nBattleIndex;
end

-- 更新到相应的mission
function tbNpcBase:Refresh()
	
	local tbMission	= Wldh.Battle:GetMission(self.nBattleIndex);
	
	if tbMission then
		self.tbMission = tbMission;
		self.tbCamp = {tbMission.tbCamps[1], tbMission.tbCamps[2]};
	else
		self.tbMission	= nil;
		self.tbCamp = nil;
	end
end

function tbNpcBase:OnDialog()
	
	self:Refresh();
	
	if not self.tbMission then
		Dialog:Say("比赛尚未到时间，请等一会儿。", {{"返回英雄岛", self.OnLeaveHere, self}, {"Ta hiểu rồi"}});
		return;
	end

	local tbOpt = 
	{
		{"我要进入比赛场", self.OnSingleJoin, self},
		{"我要返回英雄岛", self.OnLeaveHere, self},
		{"Để ta suy nghĩ lại"},
	};
	
	Dialog:Say("你好！这里是武林大会团体赛准备场。我可以帮助你进入比赛场地，或者返回英雄岛。", tbOpt);
end

function tbNpcBase:OnLeaveHere()
	
	local nGateWay = Transfer:GetTransferGateway();
	local nMapId = Wldh.Battle.tbLeagueName[nGateWay][2];
	
	if nMapId then
		me.NewWorld(nMapId, 1648, 3377);
	end
end

-- 判断玩家是否有权加入
function tbNpcBase:CheckPlayer(pPlayer, nCampId)
		
	-- 判断是否有战队
	local szLeagueName = League:GetMemberLeague(Wldh.Battle.MATCH_TYPE, pPlayer.szName);
	if not szLeagueName then
		Dialog:Say("你还没有战队，不能加入。");
		return 0;	
	end
	
	-- 判断是否能加入该mission的该阵营
	for i = 1, 2 do
		if szLeagueName == self.tbMission.tbLeagueName[i] then
			if Wldh.Battle.BTPLNUM_HIGHBOUND <= self.tbCamp[i]:GetPlayerCount() then
				Dialog:Say("该方参战人数已达到上限，不能再加入了。");
				return 0;
			end
			return 1, i; 
		end
	end

	Dialog:Say("你所在的战队没有资格参加该场比赛。");
	return 0;
end

-- 进入战场
function tbNpcBase:OnSingleJoin()
	
	self:Refresh();
	
	local bOk, nCampId = self:CheckPlayer(me);
	if bOk == 0 then
		return;
	end
		
	self:DoSingleJoin(me, nCampId);
end

-- 执行真正进入战场操作
function tbNpcBase:DoSingleJoin(pPlayer, nCampId)
		
	-- 这段代码看着比较不爽，先不改了
	if not self.tbMission then
		Dialog:Say("你来晚了，对不起下次再来吧。");
		return;
	
	-- 战局开始
	elseif self.tbMission.nState == 2 then 
		pPlayer.Msg("比赛已经开始了，快进去吧。");
	
	-- 战局还没开始
	else
		Dialog:Say("请在后营稍等片刻，比赛马上就开始了。");
	end
	
	-- 战局开始后才记录玩家阵营,战场key,第几个场地
	if self.tbMission.nState == 2 then 
		pPlayer.SetTask(Wldh.Battle.TASK_GROUP_ID, Wldh.Battle.TASKID_PLAYER_KEY, self.tbMission.nBattleKey);
		pPlayer.SetTask(Wldh.Battle.TASK_GROUP_ID, Wldh.Battle.TASKID_CAMP, nCampId);
		pPlayer.SetTask(Wldh.Battle.TASK_GROUP_ID, Wldh.Battle.TASKID_INDEX, self.nBattleIndex);
	end
	
	self.tbMission:JoinPlayer(pPlayer, nCampId);
end

-- 初始化
tbNpc:Init();
